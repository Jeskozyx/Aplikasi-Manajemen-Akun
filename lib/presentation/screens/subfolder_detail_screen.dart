import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/account_card.dart';
import '../../data/models/subfolder_model.dart';
import '../../data/models/password_model.dart';
import '../../data/database/database_helper.dart';
import 'add_account_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);

    try {
      if (widget.subfolder.id != null) {
        final accounts = await DatabaseHelper.instance.getPasswordsBySubfolder(
          widget.subfolder.id!,
        );
        setState(() {
          _accounts = accounts;
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
          category: widget.subfolder.category,
          subfolderId: widget.subfolder.id,
          subfolderName: widget.subfolder.name,
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
              widget.subfolder.name,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
            Text(
              widget.subfolder.category,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF718096),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
      floatingActionButton: FloatingActionButton.extended(
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
        itemCount: _accounts.length + 1, // +1 for bottom padding
        itemBuilder: (context, index) {
          if (index == _accounts.length) {
            return const SizedBox(height: 80); // Padding for FAB
          }

          final account = _accounts[index];
          return AccountCard(
            title: account.title,
            accountName: account.accountName,
            email: account.email,
            username: account.username,
            password: account.password,
            isActive: account.isActive,
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
            'Tambahkan akun ke ${widget.subfolder.name}',
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
