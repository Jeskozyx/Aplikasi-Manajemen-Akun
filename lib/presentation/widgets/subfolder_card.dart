import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A card widget representing a subfolder (group of accounts).
class SubfolderCard extends StatelessWidget {
  final String name;
  final int accountCount;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const SubfolderCard({
    super.key,
    required this.name,
    required this.accountCount,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0A000000),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Folder icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.folder_rounded,
                color: Color(0xFF6C63FF),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Name and count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$accountCount Akun',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
            // Arrow icon
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF718096)),
          ],
        ),
      ),
    );
  }
}
