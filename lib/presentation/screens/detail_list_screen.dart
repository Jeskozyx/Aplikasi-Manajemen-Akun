import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// IMPORT: Pastikan path ini sesuai project kamu
import '../widgets/subfolder_card.dart';
import '../widgets/account_card.dart';
import '../../data/models/subfolder_model.dart';
import '../../data/models/password_model.dart';
import '../../data/database/database_helper.dart';
import 'add_subfolder_screen.dart';
import 'add_account_screen.dart';
import 'subfolder_detail_screen.dart';
import 'bulk_import_screen.dart';

class DetailListScreen extends StatefulWidget {
  final String categoryName;
  final int? colorValue;
  final int? iconCodePoint;

  const DetailListScreen({
    super.key,
    required this.categoryName,
    this.colorValue,
    this.iconCodePoint,
  });

  @override
  State<DetailListScreen> createState() => _DetailListScreenState();
}

class _DetailListScreenState extends State<DetailListScreen> {
  // ===========================================================================
  // 1. LOGIC SECTION (TIDAK BERUBAH)
  // ===========================================================================

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

  // Navigasi-navigasi (Keep Existing Logic)
  void _navigateToAddSubfolder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSubfolderScreen(category: widget.categoryName),
      ),
    );
    if (result == true && mounted) _loadData();
  }

  void _navigateToEditSubfolder(SubfolderModel subfolder) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSubfolderScreen(
          category: widget.categoryName,
          existingSubfolder: subfolder,
        ),
      ),
    );
    if (result == true && mounted) _loadData();
  }

  void _navigateToAddAccount() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAccountScreen(category: widget.categoryName),
      ),
    );
    if (result == true && mounted) _loadData();
  }

  void _navigateToEditAccount(PasswordModel account) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAccountScreen(
          category: widget.categoryName,
          existingAccount: account,
        ),
      ),
    );
    if (result == true && mounted) _loadData();
  }

  void _navigateToSubfolder(SubfolderModel subfolder) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubfolderDetailScreen(subfolder: subfolder),
      ),
    );
    if (result == true && mounted) _loadData();
  }

  void _navigateToBulkImport() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BulkImportScreen(category: widget.categoryName),
      ),
    );
    if (result == true && mounted) _loadData();
  }

  // ===========================================================================
  // 2. UI SECTION (REFACTORED TO MATCH DARK THEME)
  // ===========================================================================

  final Color _bgDark = const Color(0xFF050505);
  final Color _surfaceColor = const Color(0xFF121212);
  final Color _textWhite = const Color(0xFFFFFFFF);
  final Color _textGrey = const Color(0xFF9CA3AF);

  // Helper untuk mendapatkan warna tema berdasarkan kategori
  Color _getThemeColor() {
    if (widget.colorValue != null) {
      return Color(widget.colorValue!);
    }
    return _getCategoryColor(widget.categoryName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // A. Custom Navigation Bar (Top)
            _buildCustomNavBar(),

            // B. Scrollable Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            // Header Panel Hitam
                            _buildDarkHeaderPanel(),

                            const SizedBox(height: 30),

                            // Isi Halaman (Folders & Accounts)
                            _buildMainContent(),

                            // Padding Bawah untuk FAB
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildModernFABs(),
    );
  }

  Widget _buildCustomNavBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          Text(
            widget.categoryName, // Bisa diganti "Details" jika ingin statis
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textWhite,
            ),
          ),
          // Placeholder button untuk balance layout (atau bisa jadi tombol search)
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildDarkHeaderPanel() {
    // Hitung total item
    int totalItems = _subfolders.length + _directAccounts.length;
    IconData catIcon = widget.iconCodePoint != null
        ? IconData(widget.iconCodePoint!, fontFamily: 'MaterialIcons')
        : _getCategoryIcon(widget.categoryName);
    Color themeColor = _getThemeColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Label Kecil
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(catIcon, color: themeColor, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                "CATEGORY",
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Judul Besar
          Text(
            widget.categoryName,
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),

          // Statistik
          Text(
            "$totalItems items managed",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_subfolders.isEmpty && _directAccounts.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. SECTION FOLDERS
        if (_subfolders.isNotEmpty) ...[
          _buildSectionHeader("Subfolders"),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _subfolders.length,
            itemBuilder: (context, index) {
              final subfolder = _subfolders[index];
              return SubfolderCard(
                name: subfolder.name,
                accountCount: _subfolderCounts[subfolder.id] ?? 0,
                onTap: () => _navigateToSubfolder(subfolder),
                onLongPress: () => _navigateToEditSubfolder(subfolder),
              );
            },
          ),
          const SizedBox(height: 24),
        ],

        // 2. SECTION ACCOUNTS
        if (_directAccounts.isNotEmpty) ...[
          _buildSectionHeader("Direct Accounts"),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _directAccounts.length,
            itemBuilder: (context, index) {
              final account = _directAccounts[index];
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
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF8E8E93), // iOS Section Grey
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Icon(Icons.dashboard_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No data available",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget: Tombol Bulat
  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _surfaceColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: _textWhite),
      ),
    );
  }

  // FAB yang Modern
  Widget _buildModernFABs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 1. Bulk Import (Putih Kecil)
        FloatingActionButton.small(
          heroTag: 'import',
          onPressed: _navigateToBulkImport,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF10B981),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.upload_rounded),
        ),
        const SizedBox(height: 12),

        // 2. Add Folder (Putih Kecil)
        FloatingActionButton.small(
          heroTag: 'subfolder',
          onPressed: _navigateToAddSubfolder,
          backgroundColor: _surfaceColor,
          foregroundColor: _getThemeColor(),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white10),
          ),
          child: const Icon(Icons.create_new_folder_outlined),
        ),
        const SizedBox(height: 12),

        // 3. Add Account (Hitam Besar / Theme Color Besar)
        SizedBox(
          height: 56,
          child: FloatingActionButton.extended(
            heroTag: 'account',
            onPressed: _navigateToAddAccount,
            backgroundColor: _textWhite, // Putih agar kontras
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            icon: const Icon(Icons.person_add_rounded, color: Colors.black),
            label: Text(
              'New Account',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Utilities Warna & Icon
  IconData _getCategoryIcon(String category) {
    // Fallback if no icon passed
    return Icons.folder_rounded;
  }

  Color _getCategoryColor(String category) {
    // Fallback if no color passed
    return const Color(0xFF6C63FF);
  }
}
