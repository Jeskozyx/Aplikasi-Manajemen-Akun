import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// IMPORT: Sesuaikan dengan struktur folder project Anda
import '../../data/models/subfolder_model.dart';
import '../../data/models/password_model.dart';
import '../../data/database/database_helper.dart';
import '../widgets/account_card.dart'; // Import card yang baru dibuat di atas
import 'add_account_screen.dart';
import 'add_subfolder_screen.dart';
import 'bulk_import_screen.dart';

class SubfolderDetailScreen extends StatefulWidget {
  final SubfolderModel subfolder;

  const SubfolderDetailScreen({super.key, required this.subfolder});

  @override
  State<SubfolderDetailScreen> createState() => _SubfolderDetailScreenState();
}

class _SubfolderDetailScreenState extends State<SubfolderDetailScreen> {
  // ===========================================================================
  // SECTION 1: LOGIC (TIDAK BERUBAH)
  // Logic pengambilan data dan navigasi tetap sama persis
  // ===========================================================================

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
    if (result == true && mounted) _loadAccounts();
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
    if (result == true && mounted) _loadAccounts();
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
    if (result == true && mounted) {
      final exists = await DatabaseHelper.instance.getSubfolderById(
        _currentSubfolder.id!,
      );
      if (exists == null && mounted) {
        Navigator.pop(context, true);
      } else if (mounted) {
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
    if (result == true && mounted) _loadAccounts();
  }

  // ===========================================================================
  // SECTION 2: UI (REFACTORED MATCHING IMAGE 2)
  // Menggunakan style Dark Panel & Clean List
  // ===========================================================================

  // Definisi Warna sesuai Referensi
  final Color _bgLight = const Color(0xFFF2F2F7); // Background abu-abu muda
  final Color _darkPanel = const Color(0xFF1C1C1E); // Panel Hitam/Gelap
  final Color _textMain = const Color(0xFF000000); // Teks Hitam

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // A. Custom Top Navigation Bar
            _buildTopNavBar(),

            // B. Konten Scrollable
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildScrollableContent(),
            ),
          ],
        ),
      ),
      // C. Floating Action Button (Disesuaikan tema)
      floatingActionButton: _buildModernFABs(),
    );
  }

  Widget _buildTopNavBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Back
          _buildCircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context, true),
          ),

          Text(
            "Detail Folder",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textMain,
            ),
          ),

          // Tombol Edit Folder (Titik tiga)
          _buildCircleButton(
            icon: Icons.more_horiz_rounded,
            onTap: _navigateToEditSubfolder,
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // 1. HEADER PANEL HITAM (Mirip referensi "Custom panel")
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _darkPanel,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon kecil & Kategori
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.folder_open,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _currentSubfolder.category.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Nama Folder Besar
                Text(
                  _currentSubfolder.name,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle status
                Text(
                  _accounts.isEmpty
                      ? "Folder is empty"
                      : "${_accounts.length} Accounts secured",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 2. LIST ITEMS
          if (_accounts.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: _buildEmptyState(),
            )
          else
            ListView.builder(
              // Menggunakan builder agar efisien
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _accounts.length,
              itemBuilder: (context, index) {
                final account = _accounts[index];
                // Panggil Widget AccountCard yang sudah kita update
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

          const SizedBox(height: 100), // Spasi bawah agar tidak tertutup FAB
        ],
      ),
    );
  }

  // Widget Helper: Tombol Bulat Navigasi
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
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: _darkPanel),
      ),
    );
  }

  // Widget Helper: Tampilan Kosong
  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(Icons.folder_off_outlined, size: 50, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(
          "Belum ada akun",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[400],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Widget FAB (Tombol Tambah)
  Widget _buildModernFABs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Tombol Import
        FloatingActionButton.small(
          heroTag: 'import',
          onPressed: _navigateToBulkImport,
          backgroundColor: Colors.white,
          foregroundColor: _darkPanel,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.file_upload_outlined),
        ),
        const SizedBox(height: 12),
        // Tombol Add New Account (Hitam Besar sesuai tema)
        SizedBox(
          height: 56,
          child: FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: _navigateToAddAccount,
            backgroundColor: _darkPanel,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              'New Account',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
