import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/medicine_provider.dart';
import 'theme_manager.dart';
import 'screens/edit_medicine_screen.dart'; // Import added
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/add_medicine_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('medicines');
  await Hive.openBox('user');
  await Firebase.initializeApp();
  await NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeManager _themeManager = ThemeManager();

  @override
  void initState() {
    super.initState();
    _themeManager.addListener(_onThemeChanged);
  }

  void _onThemeChanged() => setState(() {});

  @override
  void dispose() {
    _themeManager.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
      ],
      child: MaterialApp(
        title: 'MediCare',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/main': (context) => const MainScreen(),
          '/add': (context) => const AddMedicineScreen(),
          '/history': (context) => const HistoryScreen(),
          '/profile': (context) => const ProfileScreen(),
          // New /edit route with arguments handling
          '/edit': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
            as Map<String, dynamic>;
            return EditMedicineScreen(
              medicine: args['medicine'],
              index: args['index'],
            );
          },
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    final theme = _themeManager.currentTheme;
    final isDark = theme == 'Dark';

    Map<String, Color> colors = {
      'Pastel': const Color(0xFFE8A0BF),
      'Dark': const Color(0xFFBB86FC),
      'Nature': const Color(0xFF4CAF50),
      'Ocean': const Color(0xFF2196F3),
    };

    Map<String, Color> backgrounds = {
      'Pastel': const Color(0xFFFFF0F5),
      'Dark': const Color(0xFF121212),
      'Nature': const Color(0xFFF1F8E9),
      'Ocean': const Color(0xFFE3F2FD),
    };

    final primaryColor = colors[theme] ?? const Color(0xFFE8A0BF);
    final bgColor = backgrounds[theme] ?? const Color(0xFFFFF0F5);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      scaffoldBackgroundColor: bgColor,
      textTheme: GoogleFonts.poppinsTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
    );
  }
}