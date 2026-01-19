import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A card widget representing a password account entry.
class AccountCard extends StatefulWidget {
  final String title;
  final String accountName;
  final String? email;
  final String? username;
  final String password;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AccountCard({
    super.key,
    required this.title,
    required this.accountName,
    this.email,
    this.username,
    required this.password,
    required this.isActive,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
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
          border: Border.all(
            color: widget.isActive
                ? const Color(0xFF10B981).withValues(alpha: 0.3)
                : const Color(0xFFEF4444).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Account icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.isActive
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: widget.isActive
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Title and account name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        widget.accountName,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isActive
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.isActive ? 'Aktif' : 'Nonaktif',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: widget.isActive
                          ? const Color(0xFF059669)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Details
            if (widget.email != null && widget.email!.isNotEmpty) ...[
              _buildInfoRow(Icons.email_outlined, widget.email!),
              const SizedBox(height: 6),
            ],
            if (widget.username != null && widget.username!.isNotEmpty) ...[
              _buildInfoRow(Icons.alternate_email, widget.username!),
              const SizedBox(height: 6),
            ],
            // Password row
            Row(
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: Color(0xFF718096),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _showPassword ? widget.password : '••••••••',
                    style: _showPassword
                        ? GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF718096),
                          )
                        : const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF718096),
                            fontFamily: 'monospace',
                            letterSpacing: 2,
                          ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                  child: Icon(
                    _showPassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 20,
                    color: const Color(0xFF6C63FF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF718096)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF718096),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
