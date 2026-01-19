import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/account_card.dart';
import '../../data/models/subfolder_model.dart';
import '../../data/models/password_model.dart';
import '../../data/database/database_helper.dart';
import 'add_account_screen.dart';
import 'add_subfolder_screen.dart';
import 'bulk_import_screen.dart';

/// Screen to display accounts within a specific subfolder.
class SubfolderDetailScreen extends StatefulWidget {
  final SubfolderModel subfolder;

  const SubfolderDetailScreen({super.key, required this.subfolder});

  @override
  State<SubfolderDetailScreen> createState() => _SubfolderDetailScreenState();
}

class _SubfolderDetailScreenState extends State<SubfolderDetailScreen> {
  List<PasswordModel> _accounts = [];
  bool _isLoading = true;
  late SubfolderModel _currentSubfolder;

  @override
  void initState() {
    super.initState();
    _currentSubfolder = widget.subfolder;
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);

    try {
      if (_currentSubfolder.id != null) {
        final accounts = await DatabaseHelper.instance.getPasswordsBySubfolder(
          _currentSubfolder.id!,
        );

        // Refresh subfolder data in case it was edited
        final updatedSubfolder = await DatabaseHelper.instance.getSubfolderById(
          _currentSubfolder.id!,
        );

        setState(() {
          _accounts = accounts;
          if (updatedSubfolder != null) {
            _currentSubfolder = updatedSubfolder;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading accounts: $e');
      setState(() => _isLoading = false);
    }
  }

  void _navigateToAddAccount() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAccountScreen(
          category: _currentSubfolder.category,
          subfolderId: _currentSubfolder.id,
          subfolderName: _currentSubfolder.name,
        ),
      ),
    );

    if (result == true) {
      _loadAccounts();
    }
  }

  void _navigateToEditAccount(PasswordModel account) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAccountScreen(
          category: _currentSubfolder.category,
          subfolderId: _currentSubfolder.id,
          subfolderName: _currentSubfolder.name,
          existingAccount: account,
        ),
      ),
    );

    if (result == true) {
      _loadAccounts();
    }
  }

  void _navigateToEditSubfolder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSubfolderScreen(
          category: _currentSubfolder.category,
          existingSubfolder: _currentSubfolder,
        ),
      ),
    );

    if (result == true) {
      // Check if subfolder was deleted
      final exists = await DatabaseHelper.instance.getSubfolderById(
        _currentSubfolder.id!,
      );

      if (exists == null && mounted) {
        // Subfolder was deleted, go back
        Navigator.pop(context, true);
      } else {
        _loadAccounts();
      }
    }
  }

  void _navigateToBulkImport() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BulkImportScreen(
          category: _currentSubfolder.category,
          subfolderId: _currentSubfolder.id,
          subfolderName: _currentSubfolder.name,
        ),
      ),
    );

    if (result == true) {
      _loadAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Color(0xFF2D3748),
          ),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Column(
          children: [
            Text(
              _currentSubfolder.name,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
            Text(
              _currentSubfolder.category,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF718096),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Color(0xFF6C63FF)),
            onPressed: _navigateToEditSubfolder,
            tooltip: 'Edit Sub-Judul',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'import',
            onPressed: _navigateToBulkImport,
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            elevation: 4,
            child: const Icon(Icons.upload_rounded, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: _navigateToAddAccount,
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.person_add_rounded),
            label: Text(
              'Tambah Akun',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_accounts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadAccounts,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _accounts.length + 2, // +1 for header, +1 for bottom padding
        itemBuilder: (context, index) {
          if (index == 0) {
            // Header with hint
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Akun',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  Text(
                    'Tap untuk edit',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            );
          }

          if (index == _accounts.length + 1) {
            return const SizedBox(height: 80); // Padding for FAB
          }

          final account = _accounts[index - 1];
          return AccountCard(
            title: account.title,
            accountName: account.accountName,
            email: account.email,
            username: account.username,
            password: account.password,
            isActive: account.isActive,
            onTap: () => _navigateToEditAccount(account),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 64,
            color: const Color(0xFF6C63FF).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada akun',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan akun ke ${_currentSubfolder.name}',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }
}
