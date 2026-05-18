import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../storage_service.dart';
import 'package:medicine_reminder/screens/main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      'emoji': '💊',
      'title': 'Never Miss a Medicine!',
      'subtitle': 'MediCare reminds you to take your medicines on time — every time!',
      'color': const Color(0xFFFFD6E7),
    },
    {
      'emoji': '🔔',
      'title': 'Smart Reminders',
      'subtitle': 'Set your medicine schedule and get notified exactly when it\'s time!',
      'color': const Color(0xFFE8D5FF),
    },
    {
      'emoji': '🌸',
      'title': 'Stay Healthy!',
      'subtitle': 'Track your daily medicine intake and build a healthy habit!',
      'color': const Color(0xFFFFEDD8),
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: SafeArea(
        child: _currentPage < 3
            ? _buildSlidePage()
            : _buildNamePage(),
      ),
    );
  }

  Widget _buildSlidePage() {
    final page = pages[_currentPage];
    return Column(
      children: [
        const SizedBox(height: 40),
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 25 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? const Color(0xFFE8A0BF)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          )),
        ),
        const SizedBox(height: 50),
        // Emoji Circle
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: page['color'],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE8A0BF).withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Center(
            child: Text(
              page['emoji'],
              style: const TextStyle(fontSize: 80),
            ),
          ),
        ),
        const SizedBox(height: 50),
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            page['title'],
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 15),
        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            page['subtitle'],
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.grey.shade500,
              height: 1.6,
            ),
          ),
        ),
        const Spacer(),
        // Next Button
        Padding(
          padding: const EdgeInsets.all(30),
          child: GestureDetector(
            onTap: () => setState(() => _currentPage++),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB6C1), Color(0xFFE8A0BF)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8A0BF).withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _currentPage == 2 ? "Let's Get Started! 🌸" : 'Next →',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNamePage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(25, 50, 25, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFB6C1), Color(0xFFE8A0BF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                const Text('👋', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 15),
                Text(
                  'Welcome to MediCare!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Please tell us your name',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Form
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Name',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Sarah, Ali, Fatima',
                      hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.person_rounded,
                          color: Color(0xFFE8A0BF)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                            color: Color(0xFFE8A0BF), width: 1.5),
                      ),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 40),
                  // Start Button
                  GestureDetector(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        StorageService.saveUserName(_nameController.text.trim());
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MainScreen()),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB6C1), Color(0xFFE8A0BF)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE8A0BF).withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Start My Journey 🌸',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}