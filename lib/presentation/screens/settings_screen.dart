import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/database/database_helper.dart';

/// Settings screen with app configuration options.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  // Dark Theme Colors
  final Color _bgDark = const Color(0xFF050505);
  final Color _surfaceColor = const Color(0xFF121212);
  final Color _textWhite = const Color(0xFFFFFFFF);
  final Color _textGrey = const Color(0xFF9CA3AF);

  Future<void> _resetDatabase() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white10),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Color(0xFFEF4444)),
            const SizedBox(width: 8),
            Text(
              'Hapus Semua Data',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: _textWhite,
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus SEMUA data?\n\n'
          '• Semua akun password akan dihapus\n'
          '• Semua sub-judul akan dihapus\n\n'
          'Tindakan ini tidak dapat dibatalkan!',
          style: GoogleFonts.poppins(color: _textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.poppins(color: _textWhite)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              'Hapus Semua',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Second confirmation
    final confirmAgain = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF7F1D1D), // Dark Red
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Konfirmasi Terakhir',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Ketik "HAPUS" untuk mengkonfirmasi penghapusan semua data.',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
          _DeleteConfirmButton(
            onConfirmed: () => Navigator.pop(context, true),
            isDark: true,
          ),
        ],
      ),
    );

    if (confirmAgain != true) return;

    setState(() => _isLoading = true);

    try {
      await DatabaseHelper.instance.resetDatabase();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Semua data berhasil dihapus',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: _textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pengaturan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _textWhite,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Info Section
            Text(
              'Tentang Aplikasi',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Nama Aplikasi', 'Password Manager'),
                  const Divider(height: 24),
                  _buildInfoRow('Versi', '1.0.0'),
                  const Divider(height: 24),
                  _buildInfoRow('Database', 'SQLCipher (Encrypted)'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Data Management Section
            Text(
              'Manajemen Data',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textGrey,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  // Reset Database
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7F1D1D).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Hapus Semua Data',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    subtitle: Text(
                      'Reset database dan hapus semua akun',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _textGrey,
                      ),
                    ),
                    trailing: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFEF4444),
                            ),
                          )
                        : Icon(Icons.chevron_right_rounded, color: _textGrey),
                    onTap: _isLoading ? null : _resetDatabase,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Warning message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Data yang dihapus tidak dapat dikembalikan. '
                      'Pastikan Anda sudah mencatat password penting sebelum menghapus.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _textGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, color: _textGrey)),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _textWhite,
          ),
        ),
      ],
    );
  }
}

/// Widget for delete confirmation with text input
class _DeleteConfirmButton extends StatefulWidget {
  final VoidCallback onConfirmed;
  final bool isDark;

  const _DeleteConfirmButton({required this.onConfirmed, this.isDark = false});

  @override
  State<_DeleteConfirmButton> createState() => _DeleteConfirmButtonState();
}

class _DeleteConfirmButtonState extends State<_DeleteConfirmButton> {
  final _controller = TextEditingController();
  bool _isValid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80,
          height: 36,
          child: TextField(
            controller: _controller,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: widget.isDark ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'HAPUS',
              hintStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: widget.isDark ? Colors.white54 : Colors.grey,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: widget.isDark ? Colors.white24 : Colors.grey,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: widget.isDark ? Colors.white24 : Colors.grey,
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _isValid = value.toUpperCase() == 'HAPUS';
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: _isValid ? widget.onConfirmed : null,
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
            disabledForegroundColor: Colors.grey,
          ),
          child: Text(
            'Konfirmasi',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
