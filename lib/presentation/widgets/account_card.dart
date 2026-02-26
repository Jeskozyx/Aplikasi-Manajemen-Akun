import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountCard extends StatefulWidget {
  final String title;
  final String accountName;
  final String? email;
  final String? username;
  final String password;
  final bool isActive;
  final VoidCallback? onTap;

  const AccountCard({
    super.key,
    required this.title,
    required this.accountName,
    this.email,
    this.username,
    required this.password,
    required this.isActive,
    this.onTap,
  });

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  bool _isPasswordVisible = false;

  // Warna yang kontras agar mudah dibaca
  // Warna yang kontras agar mudah dibaca
  final Color _textMain = const Color(0xFFFFFFFF); // Putih
  final Color _textSub = const Color(0xFF9CA3AF); // Abu-abu terang (Grey 400)
  final Color _accentColor = const Color(0xFF3B82F6); // Blue 500

  @override
  Widget build(BuildContext context) {
    final String subtitle =
        (widget.username != null && widget.username!.isNotEmpty)
        ? widget.username!
        : (widget.email ?? 'No identity');

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF121212), // Dark Surface
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon + Judul
            Row(
              children: [
                // Icon Shield Biru
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    color: _accentColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),

                // Judul Akun (Poppins Bold - Sangat Jelas)
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700, // Tebal
                      color: _textMain,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Status Dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isActive
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.white10),
            const SizedBox(height: 12),

            // Info Username (Inter - Mudah dibaca untuk teks kecil)
            Text(
              "USERNAME / EMAIL",
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280), // Grey 500
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _textSub,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),

            // Password Section
            Text(
              "PASSWORD",
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280), // Grey 500
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _isPasswordVisible ? widget.password : "••••••••••••",
                      style: _isPasswordVisible
                          ? GoogleFonts.robotoMono(
                              // Monospace agar huruf 'l' dan '1' beda
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _textMain,
                            )
                          : GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: _textMain,
                              letterSpacing: 2,
                            ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
