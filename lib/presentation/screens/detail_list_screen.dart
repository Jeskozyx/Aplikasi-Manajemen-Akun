import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/subfolder_card.dart';
import '../widgets/account_card.dart';
import '../../data/models/subfolder_model.dart';
import '../../data/models/password_model.dart';
import '../../data/database/database_helper.dart';
import 'add_subfolder_screen.dart';
import 'add_account_screen.dart';
import 'subfolder_detail_screen.dart';

/// Screen to display passwords and subfolders for a specific category.
class DetailListScreen extends StatefulWidget {
  final String categoryName;

  const DetailListScreen({super.key, required this.categoryName});

  @override
  State<DetailListScreen> createState() => _DetailListScreenState();
}

class _DetailListScreenState extends State<DetailListScreen> {
  List<SubfolderModel> _subfolders = [];
  List<PasswordModel> _directAccounts = [];
  Map<int, int> _subfolderCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final subfolders = await DatabaseHelper.instance.getSubfoldersByCategory(
        widget.categoryName,
      );
      final accounts = await DatabaseHelper.instance.getPasswordsByCategory(
        widget.categoryName,
      );

      // Get account counts for each subfolder
      final counts = <int, int>{};
      for (final subfolder in subfolders) {
        if (subfolder.id != null) {
          counts[subfolder.id!] = await DatabaseHelper.instance
              .getSubfolderAccountCount(subfolder.id!);
        }
      }

      setState(() {
        _subfolders = subfolders;
        _directAccounts = accounts;
        _subfolderCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _navigateToAddSubfolder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSubfolderScreen(category: widget.categoryName),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _navigateToAddAccount() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAccountScreen(category: widget.categoryName),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _navigateToSubfolder(SubfolderModel subfolder) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubfolderDetailScreen(subfolder: subfolder),
      ),
    );

    if (result == true) {
      _loadData();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
      floatingActionButton: _buildFABs(),
    );
  }

  Widget _buildContent() {
    if (_subfolders.isEmpty && _directAccounts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subfolders section
            if (_subfolders.isNotEmpty) ...[
              Text(
                'Sub-Judul',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 12),
              ..._subfolders.map(
                (subfolder) => SubfolderCard(
                  name: subfolder.name,
                  accountCount: _subfolderCounts[subfolder.id] ?? 0,
                  onTap: () => _navigateToSubfolder(subfolder),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Direct accounts section
            if (_directAccounts.isNotEmpty) ...[
              Text(
                'Akun Langsung',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 12),
              ..._directAccounts.map(
                (account) => AccountCard(
                  title: account.title,
                  accountName: account.accountName,
                  email: account.email,
                  username: account.username,
                  password: account.password,
                  isActive: account.isActive,
                ),
              ),
            ],

            // Bottom padding for FABs
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCategoryIcon(widget.categoryName),
            size: 64,
            color: _getCategoryColor(
              widget.categoryName,
            ).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan sub-judul atau akun\ndengan tombol di bawah',
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

  Widget _buildFABs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Add Subfolder FAB
        FloatingActionButton.extended(
          heroTag: 'subfolder',
          onPressed: _navigateToAddSubfolder,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF6C63FF),
          elevation: 4,
          icon: const Icon(Icons.create_new_folder_rounded),
          label: Text(
            'Sub-Judul',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 12),
        // Add Account FAB
        FloatingActionButton.extended(
          heroTag: 'account',
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
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Games':
        return Icons.games_rounded;
      case 'Student':
        return Icons.school_rounded;
      case 'Google':
        return Icons.g_mobiledata_rounded;
      case 'App':
        return Icons.apps_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Games':
        return const Color(0xFF8B5CF6);
      case 'Student':
        return const Color(0xFF3B82F6);
      case 'Google':
        return const Color(0xFFEF4444);
      case 'App':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6C63FF);
    }
  }
}
