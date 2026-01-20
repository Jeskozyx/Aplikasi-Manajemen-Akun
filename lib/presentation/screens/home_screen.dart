import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'detail_list_screen.dart';
import 'settings_screen.dart';
import '../../data/database/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Logic tetap sama
  int _currentNavIndex = 0;
  Map<String, int> _categoryCounts = {
    'Games': 0,
    'Student': 0,
    'Google': 0,
    'App': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadCategoryCounts();
  }

  Future<void> _loadCategoryCounts() async {
    try {
      final counts = await DatabaseHelper.instance.getCategoryCounts();
      setState(() {
        _categoryCounts = counts;
      });
    } catch (e) {
      debugPrint('Database not initialized: $e');
    }
  }

  void _navigateToDetail(String categoryName) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailListScreen(categoryName: categoryName),
      ),
    );
    if (mounted) _loadCategoryCounts();
  }

  void _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    if (mounted) _loadCategoryCounts();
  }

  // --- UI SECTION ---
  // Palet Warna High Contrast (Mudah Dibaca)
  final Color _bgMain = const Color(0xFFF9FAFB); // Cool White
  final Color _textDark = const Color(0xFF111827); // Hampir Hitam
  final Color _panelColor = const Color(0xFF1F2937); // Dark Grey Panel

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgMain,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),

              _buildDashboardPanel(),
              const SizedBox(height: 32),

              Text(
                "Kategori Password",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700, // Bold Jelas
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 16),

              _buildCategoryList(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Pagi,',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Jenifer',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700, // Bold
                color: _textDark,
                height: 1.2,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white,
          backgroundImage: const NetworkImage(
            'https://i.pravatar.cc/150?img=5',
          ), // Dummy image atau icon
          // Jika tidak ada gambar, pakai icon:
          // child: Icon(Icons.person, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDashboardPanel() {
    int total = _categoryCounts.values.fold(0, (sum, count) => sum + count);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _panelColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF34D399),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Secure Mode",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Total Akun Tersimpan",
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 4),
          Text(
            "$total Akun",
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    final categories = [
      {
        'name': 'Games',
        'icon': Icons.sports_esports_rounded,
        'color': Colors.purple,
      },
      {'name': 'Student', 'icon': Icons.school_rounded, 'color': Colors.blue},
      {
        'name': 'Google',
        'icon': Icons.g_mobiledata_rounded,
        'color': Colors.red,
      },
      {'name': 'App', 'icon': Icons.apps_rounded, 'color': Colors.green},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final cat = categories[index];
        final name = cat['name'] as String;
        final Color color = cat['color'] as Color;
        final count = _categoryCounts[name] ?? 0;

        return GestureDetector(
          onTap: () => _navigateToDetail(name),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(cat['icon'] as IconData, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textDark,
                        ),
                      ),
                      Text(
                        "$count akun",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem(Icons.grid_view_rounded, 0),
            _navItem(Icons.folder_open_rounded, 1),
            // Tombol Add Besar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _textDark,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _textDark.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
            _navItem(Icons.settings_outlined, 2),
            _navItem(Icons.person_outline_rounded, 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    bool isSelected = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 2) _navigateToSettings();
        setState(() => _currentNavIndex = index);
      },
      child: Icon(
        icon,
        size: 28,
        color: isSelected ? _textDark : Colors.grey.shade400,
      ),
    );
  }
}
