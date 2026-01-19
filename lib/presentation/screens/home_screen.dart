import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/category_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/hero_banner.dart';
import 'detail_list_screen.dart';
import '../../data/database/database_helper.dart';

/// The main home screen of the Password Manager app.
///
/// Features:
/// - Header with greeting
/// - Search bar
/// - Hero banner with security messaging
/// - 2x2 grid of password categories
/// - Bottom navigation with floating action button
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      // Database not initialized yet, use default counts
      debugPrint('Database not initialized: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Search Bar
              const SearchBarWidget(),
              const SizedBox(height: 24),

              // Hero Banner
              const HeroBanner(),
              const SizedBox(height: 28),

              // Category Section Title
              Text(
                'Password Categories',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 16),

              // Category Grid
              _buildCategoryGrid(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi User! 👋',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Welcome back',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF718096),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {
        'name': 'Games',
        'icon': Icons.games_rounded,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'name': 'Student',
        'icon': Icons.school_rounded,
        'color': const Color(0xFF3B82F6),
      },
      {
        'name': 'Google',
        'icon': Icons.g_mobiledata_rounded,
        'color': const Color(0xFFEF4444),
      },
      {
        'name': 'App',
        'icon': Icons.apps_rounded,
        'color': const Color(0xFF10B981),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryName = category['name'] as String;

        return CategoryCard(
          categoryName: categoryName,
          icon: category['icon'] as IconData,
          iconColor: category['color'] as Color,
          itemCount: _categoryCounts[categoryName] ?? 0,
          onTap: () => _navigateToDetail(categoryName),
        );
      },
    );
  }

  void _navigateToDetail(String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailListScreen(categoryName: categoryName),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 16,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Left side items
            _buildNavItem(0, Icons.home_rounded, 'Home'),
            _buildNavItem(1, Icons.folder_rounded, 'Categories'),

            // Center space for FAB
            const SizedBox(width: 48),

            // Right side items
            _buildNavItem(2, Icons.settings_rounded, 'Settings'),
            _buildNavItem(3, Icons.person_rounded, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentNavIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _currentNavIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF6C63FF)
                  : const Color(0xFF718096),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF6C63FF)
                    : const Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // TODO: Navigate to add new password screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Add New Password', style: GoogleFonts.poppins()),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      backgroundColor: const Color(0xFF6C63FF),
      elevation: 4,
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
    );
  }
}
