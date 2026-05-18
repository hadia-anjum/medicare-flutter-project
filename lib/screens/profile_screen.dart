import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/medicine_provider.dart';
import '../storage_service.dart';
import '../theme_manager.dart';
import '../notification_service.dart';
import '../app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    ThemeManager().addListener(_onThemeChanged);
  }

  void _onThemeChanged() => setState(() {});

  @override
  void dispose() {
    ThemeManager().removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, MedicineProvider>(
      builder: (context, auth, medicineProvider, _) {
        final userName = auth.user?.displayName ?? 'My Profile';
        final medicines = medicineProvider.medicines;
        final medicineCount = medicines.length;
        final takenCount = medicines.where((m) => m.taken).length;
        final percentage = medicineCount == 0
            ? 0.0
            : (takenCount / medicineCount) * 100;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(userName),
                  _buildStatsRow(medicineCount, takenCount, percentage),
                  _buildSettingsSection(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 30, 25, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                )
              ],
            ),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: AppColors.card,
              child: const Text('🌸', style: TextStyle(fontSize: 45)),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            userName,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Staying healthy everyday 💊',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () => _showEditNameDialog(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Edit Name ✏️',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final controller =
    TextEditingController(text: auth.user?.displayName ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25)),
        title: Text('Edit Name',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: GoogleFonts.poppins(color: Colors.grey),
            prefixIcon:
            Icon(Icons.person_rounded, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide:
              BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await auth.user
                    ?.updateDisplayName(controller.text.trim());
                StorageService.saveUserName(controller.text.trim());
                if (mounted) {
                  setState(() {});
                  Navigator.pop(context);
                }
              }
            },
            child: Text('Save 🌸',
                style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
      int medicineCount, int takenCount, double percentage) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(
        children: [
          _buildStatCard('💊', '$medicineCount', 'Medicines\nActive'),
          const SizedBox(width: 12),
          _buildStatCard('✅',
              '${percentage.toStringAsFixed(0)}%', 'Taken\nToday'),
          const SizedBox(width: 12),
          _buildStatCard(
            '🌸',
            takenCount == medicineCount && medicineCount > 0
                ? '100%'
                : '$takenCount/$medicineCount',
            'Progress',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.isDark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 5),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.primary,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings ⚙️',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 15),
          _buildSettingTile(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'English',
            onTap: () => _showLanguageDialog(),
          ),
          _buildSettingTile(
            icon: Icons.color_lens_rounded,
            title: 'Theme',
            subtitle: '${ThemeManager().currentTheme} Theme',
            onTap: () => _showThemeDialog(),
          ),
          _buildSettingTile(
            icon: Icons.star_rounded,
            title: 'Rate App',
            subtitle: 'Love MediCare? Rate us! ⭐',
            onTap: () => _showRateDialog(),
          ),
          _buildSettingTile(
            icon: Icons.info_rounded,
            title: 'About',
            subtitle: 'MediCare v1.0.0',
            onTap: () => _showAboutAppDialog(),
          ),
          _buildSettingTile(
            icon: Icons.logout_rounded,
            title: 'Logout',
            subtitle: 'Sign out of MediCare',
            onTap: () => _showLogoutDialog(),
            isRed: true,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isRed = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.isDark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isRed
                    ? Colors.red.shade50
                    : AppColors.card.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: isRed ? Colors.redAccent : AppColors.primary,
                  size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isRed ? Colors.redAccent : null)),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          color: Colors.grey.shade400,
                          fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade300, size: 16),
          ],
        ),
      ),
    );
  }

  // ✅ Urdu Remove — Sirf English
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25)),
        title: Text('Select Language 🌍',
            style:
            GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇬🇧',
                  style: TextStyle(fontSize: 24)),
              title: Text('English', style: GoogleFonts.poppins()),
              trailing: const Icon(Icons.check_rounded,
                  color: Colors.green),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)),
          title: Text('Choose Theme 🎨',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption('', 'Pastel',
                  const Color(0xFFE8A0BF), setDialogState),
              _buildThemeOption('', 'Dark',
                  const Color(0xFFBB86FC), setDialogState),
              _buildThemeOption('', 'Nature',
                  const Color(0xFF4CAF50), setDialogState),
              _buildThemeOption('', 'Ocean',
                  const Color(0xFF2196F3), setDialogState),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Done',
                  style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
      String emoji, String name, Color color, StateSetter setDialogState) {
    final isSelected = ThemeManager().currentTheme == name;
    return GestureDetector(
      onTap: () {
        ThemeManager().setTheme(name);
        setDialogState(() {});
        setState(() {});
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name theme applied! $emoji',
                style: GoogleFonts.poppins()),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                  child: Text(emoji,
                      style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            Text(name,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 15)),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: color, size: 24),
          ],
        ),
      ),
    );
  }

  void _showRateDialog() {
    int selectedStars = 0;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 10),
              Text('Rate MediCare!',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              const SizedBox(height: 5),
              Text('How would you rate our app?',
                  style: GoogleFonts.poppins(
                      color: Colors.grey.shade500,
                      fontSize: 13)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                      (i) => GestureDetector(
                    onTap: () => setDialogState(
                            () => selectedStars = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        i < selectedStars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: AppColors.primary,
                        size: 35,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style:
                  GoogleFonts.poppins(color: Colors.grey)),
            ),
            TextButton(
              onPressed: selectedStars > 0
                  ? () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Thank you for $selectedStars stars! ',
                        style: GoogleFonts.poppins()),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12)),
                  ),
                );
              }
                  : null,
              child: Text('Submit',
                  style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutAppDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💊', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 10),
            Text('MediCare',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            Text('Version 1.0.0',
                style: GoogleFonts.poppins(
                    color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 10),
            Text(
              'Never miss a medicine again!\nStay healthy, stay happy ',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close',
                style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👋', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 10),
            Text('Logout?',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            Text(
              'Are you sure you want to logout?',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<AuthProvider>(context,
                  listen: false)
                  .logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              }
            },
            child: Text('Logout',
                style: GoogleFonts.poppins(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}