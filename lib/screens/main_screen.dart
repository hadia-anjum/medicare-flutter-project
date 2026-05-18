import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';
import '../app_colors.dart';
import '../theme_manager.dart';
import '../notification_service.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'add_medicine_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  List<Widget> get _screens => [
    const HomeScreen(),
    const HistoryScreen(),
    const AddMedicineScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ThemeManager().addListener(_onThemeChanged);
    // Register the callback to refresh when user taps notification actions in foreground
    NotificationService().onNotificationActionTapped = () {
      Provider.of<MedicineProvider>(context, listen: false).loadMedicines();
    };
    // Load fresh medicines from Firebase/Hive on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MedicineProvider>(context, listen: false).loadMedicines();
    });
  }

  void _onThemeChanged() => setState(() {});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Provider.of<MedicineProvider>(context, listen: false).loadMedicines();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ThemeManager().removeListener(_onThemeChanged);
    NotificationService().onNotificationActionTapped = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.isDark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.isDark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_rounded),
              activeIcon: Icon(Icons.add_circle_rounded),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}