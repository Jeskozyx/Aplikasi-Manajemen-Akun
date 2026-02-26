import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  // Fungsi pintar untuk menebak URL Logo
  String _getLogoUrl(String folderName) {
    // 1. Bersihkan nama
    String cleanName = folderName.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      '',
    );

    // 2. Mapping Manual untuk nama umum yang mungkin domainnya beda
    // Bisa ditambahkan sesuai kebutuhan user
    Map<String, String> domainMap = {
      'mobilelegends': 'mobilelegends.com',
      'valorant': 'playvalorant.com',
      'pubame': 'pubgmobile.com',
      'genshinimpact': 'genshin.hoyoverse.com',
      'codm': 'callofduty.com',
      // Tambahkan lainnya di sini
    };

    String domain = domainMap[cleanName] ?? '$cleanName.com';

    // 3. Gunakan Google Favicon API (Lebih stabil & jarang keno blokir DNS)
    // sz=128 untuk ukuran resolusi lumayan tinggi
    return 'https://www.google.com/s2/favicons?sz=128&domain=$domain';
  }

  @override
  Widget build(BuildContext context) {
    // Generate URL sekali di sini agar bisa dipakai di listener debug
    final logoUrl = _getLogoUrl(name);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF121212), // Surface Dark
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // --- BAGIAN ICON (YANG DIUBAH) ---
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A), // Darker placeholder
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: logoUrl,
                  fit: BoxFit.cover,
                  // Tambahkan memCacheWidth/Height untuk performa jika perlu, tapi
                  // untuk icon kecil tidak wajib.

                  // Tampilan saat Loading:
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(14.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),

                  // LISTENER ERROR (PENTING UNTUK DEBUGGING)
                  errorListener: (value) {
                    debugPrint(
                      '>> ERROR LOADING LOGO for "$name" ($logoUrl): $value',
                    );
                  },

                  // Tampilan jika Error (Logo tidak ketemu atau Offline):
                  // Fallback ke Inisial Nama Folder (Avatar style)
                  errorWidget: (context, url, error) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50, // Background lembut
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ---------------------------------
            const SizedBox(width: 16),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$accountCount item disimpan',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
