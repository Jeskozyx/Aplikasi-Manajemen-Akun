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
  // ===========================================================================
  // 1. LOGIC SECTION
  // ===========================================================================
  int _currentNavIndex = 0;
  List<Map<String, dynamic>> _categories = [];
  Map<String, int> _categoryCounts = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final categories = await DatabaseHelper.instance.getAllCategories();
      final counts = await DatabaseHelper.instance.getCategoryCounts();
      setState(() {
        _categories = categories;
        _categoryCounts = counts;
      });
    } catch (e) {
      debugPrint('Database error: $e');
    }
  }

  void _navigateToDetail(
    String categoryName,
    int? colorValue,
    int? iconCode,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailListScreen(
          categoryName: categoryName,
          colorValue: colorValue,
          iconCodePoint: iconCode,
        ),
      ),
    );
    if (mounted) _loadData();
  }

  void _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    if (mounted) _loadData();
  }

  // ===========================================================================
  // 2. UI SECTION (DARK MODE THEME)
  // ===========================================================================

  // Palet Warna Gelap (Dark Theme)
  final Color _bgDark = const Color(
    0xFF050505,
  ); // Hitam pekat (Hampir pure black)
  final Color _surfaceColor = const Color(
    0xFF121212,
  ); // Abu sangat gelap untuk panel/bar
  final Color _textWhite = const Color(0xFFFFFFFF);
  final Color _textGrey = const Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark, // Background Hitam
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildWelcomeBanner(),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Brankas Saya",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _textWhite, // Teks Putih
                    ),
                  ),
                  Icon(Icons.sort, color: _textGrey),
                ],
              ),
              const SizedBox(height: 16),

              _buildFolderGrid(),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // --- WIDGET PENDUKUNG ---

  Widget _buildFolderGrid() {
    if (_categories.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 48),
            Icon(Icons.folder_open_rounded, size: 64, color: _surfaceColor),
            const SizedBox(height: 16),
            Text(
              "Belum ada kategori",
              style: GoogleFonts.inter(color: _textGrey),
            ),
            const SizedBox(height: 8),
            Text(
              "Tekan tombol + untuk membuat",
              style: GoogleFonts.inter(color: _textGrey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        final name = cat['name'] as String;
        final count = _categoryCounts[name] ?? 0;
        final colorValue = cat['color_value'] as int?;
        final color = colorValue != null ? Color(colorValue) : Colors.blue;
        final iconCode = cat['icon_code_point'] as int?;
        final icon = iconCode != null
            ? IconData(
                iconCode,
                fontFamily: 'MaterialIcons',
              ) // Default fontFamily for standard icons
            : Icons.folder_rounded;

        return GestureDetector(
          onTap: () => _navigateToDetail(name, colorValue, iconCode),
          child: _buildRealisticFolderCard(
            title: name,
            count: count,
            icon: icon,
            color: color,
          ),
        );
      },
    );
  }

  Widget _buildRealisticFolderCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // 1. Tab Belakang (Lebih gelap)
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: 70,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.3), // Transparan di dark mode
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 1,
              ), // Stroke tipis biar neon
            ),
          ),
        ),

        // 2. Body Folder (Utama)
        Container(
          margin: const EdgeInsets.only(top: 15),
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            // Gradient Dark Mode (Hitam ke Warna Folder)
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.2), // Sedikit warna
                const Color(0xFF1A1A1A), // Kembali ke gelap
              ],
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
              topLeft: Radius.circular(0),
            ),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ), // Border neon effect
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1), // Glow effect tipis
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20), // Icon berwarna
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _textWhite,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(
                      "$count Files",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: _textGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
              'Hi Jenifer!',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: _textWhite, // Teks Putih
              ),
            ),
            Text(
              'Mode Rahasia Aktif',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _surfaceColor, // Surface gelap
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444), // Red notification dot
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _surfaceColor, // Surface gelap
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10), // Border tipis
      ),
      child: TextField(
        enabled: false,
        style: TextStyle(color: _textWhite),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: _textGrey),
          hintText: "Cari password...",
          hintStyle: GoogleFonts.inter(color: _textGrey),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Sedikit lebih terang dari hitam bg
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12), // Border subtle
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF10B981,
                    ).withOpacity(0.2), // Green tint
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    "ENCRYPTED",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF34D399),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Brankas Digital.",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Data Anda terlindungi sepenuhnya",
                  style: GoogleFonts.inter(fontSize: 12, color: _textGrey),
                ),
              ],
            ),
          ),
          Icon(
            Icons.lock_outline_rounded,
            size: 60,
            color: Colors.white.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      color: _surfaceColor, // Surface Gelap
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 0,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.folder_copy_rounded, "Brankas", 0),
            _navItem(Icons.shield_outlined, "Audit", 1),
            const SizedBox(width: 48), // Space untuk FAB
            _navItem(Icons.cloud_sync_rounded, "Sync", 2),
            _navItem(Icons.settings_rounded, "Setting", 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = _currentNavIndex == index;
    final Color itemColor = isSelected ? _textWhite : const Color(0xFF525252);

    return GestureDetector(
      onTap: () {
        if (index == 3) _navigateToSettings();
        setState(() => _currentNavIndex = index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: itemColor, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: itemColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    return GestureDetector(
      onTap: _showAddCategoryDialog,
      child: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          color: _textWhite, // Tombol Putih Kontras
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _textWhite.withOpacity(0.2), // Glow putih
              blurRadius: 20,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.black, size: 32),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController _categoryController = TextEditingController();

    // Palet warna sederhana untuk dipilih (atau di-random)
    final List<Color> _colors = [
      const Color(0xFFEF4444), // Red
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF10B981), // Emerald
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFFEC4899), // Pink
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: _surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Buat Kategori Baru",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _textWhite,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _categoryController,
                style: TextStyle(color: _textWhite),
                decoration: InputDecoration(
                  hintText: "Nama Kategori (misal: Kantor)",
                  hintStyle: TextStyle(color: _textGrey),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = _categoryController.text.trim();
                    if (name.isNotEmpty) {
                      // Pilih warna random dari palet
                      final color =
                          _colors[DateTime.now().second % _colors.length];

                      await DatabaseHelper.instance.insertCategory(
                        name,
                        colorValue: color.value,
                        iconCodePoint:
                            Icons.folder_rounded.codePoint, // Default icon
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        _loadData();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Buat Kategori",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
