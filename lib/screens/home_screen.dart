import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';
import '../storage_service.dart';
import '../medicine_model.dart';
import '../notification_service.dart';
import 'add_medicine_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<Medicine> medicines = [];
  String userName = '';

  final Map<String, Color> colorMap = {
    'Pink': const Color(0xFFFFD6E7),
    'Peach': const Color(0xFFFFEDD8),
    'Lavender': const Color(0xFFE8D5FF),
    'Mint': const Color(0xFFD5F5E3),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Register the callback to refresh when user taps notification actions in foreground
    NotificationService().onNotificationActionTapped = () {
      _loadData();
    };
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NotificationService().onNotificationActionTapped = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  void _loadData() async {
    // Apply any "Mark as Done" taps that happened while app was in background
    StorageService.applyPendingTakenFromNotifications();

    // Sync other components (like HistoryScreen using MedicineProvider) with Firebase and Hive state
    try {
      if (mounted) {
        final prov = Provider.of<MedicineProvider>(context, listen: false);
        await prov.syncPendingTakenToFirebase();
        prov.refresh();
      }
    } catch (_) {}

    // Cancel scheduled alarms for any medicine now marked as taken
    // (covers both in-app toggle AND notification button taps)
    final all = StorageService.getAllMedicines();
    for (final med in all) {
      if (med.taken && med.notificationId != 0) {
        await NotificationService().cancelNotification(med.notificationId);
      }
    }

    setState(() {
      medicines = StorageService.getAllMedicines();
      userName = StorageService.getUserName();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final taken = medicines.where((m) => m.taken).length;
    final total = medicines.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: SafeArea(
        child: medicines.isEmpty
            ? _buildEmptyState()
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildProgressCard(taken, total),
              _buildTodaySection(),
              _buildMedicineList(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💊', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 20),
          Text(
            'No Medicines Yet!',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap the button below to add\nyour first medicine reminder!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade400,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddMedicineScreen()),
              );
              _loadData();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB6C1), Color(0xFFE8A0BF)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8A0BF).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                'Add Medicine 💊',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 30, 25, 30),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()}, $userName! 🌸',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Time to take your medicines!',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text('💊',
                    style: TextStyle(fontSize: 28)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Date Row
          Row(
            children: List.generate(5, (index) {
              final date = now.add(Duration(days: index - 4));
              final isToday = date.day == now.day &&
                  date.month == now.month &&
                  date.year == now.year;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isToday
                        ? Colors.white
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getDayName(date.weekday),
                        style: GoogleFonts.poppins(
                          color: isToday
                              ? const Color(0xFFE8A0BF)
                              : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${date.day}',
                        style: GoogleFonts.poppins(
                          color: isToday
                              ? const Color(0xFFE8A0BF)
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(int taken, int total) {
    final progress = total == 0 ? 0.0 : taken / total;
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 20, 25, 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8A0BF).withOpacity(0.15),
            blurRadius: 20,
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
              Text(
                "Today's Progress",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '$taken/$total taken',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFE8A0BF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: const Color(0xFFF5E6FF),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFE8A0BF),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            progress == 1.0
                ? '🎉 All medicines taken! Great job!'
                : '💪 Keep it up! $taken out of $total done!',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 15, 25, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Today's Medicines 🌷",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
            child: Text(
              'See History',
              style: GoogleFonts.poppins(
                color: const Color(0xFFE8A0BF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        final med = medicines[index];
        final cardColor =
            colorMap[med.color] ?? const Color(0xFFFFD6E7);
        final timeStr =
            '${med.hour.toString().padLeft(2, '0')}:${med.minute.toString().padLeft(2, '0')}';

        return Dismissible(
          key: Key('$index${med.name}'),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(22),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_rounded,
                color: Colors.white, size: 28),
          ),
          onDismissed: (_) {
            // Cancel scheduled notification
            NotificationService().cancelNotification(med.notificationId);
            
            // Delete from persistent storage
            StorageService.deleteMedicine(index);
            
            // Synchronously remove from the local list so the widget tree updates immediately
            setState(() {
              medicines.removeAt(index);
            });
            
            // Reload rest of the data in background
            _loadData();
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${med.name} removed!',
                    style: GoogleFonts.poppins()),
                backgroundColor: const Color(0xFFE8A0BF),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    med.icon,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: med.taken
                              ? TextDecoration.lineThrough
                              : null,
                          color: med.taken
                              ? Colors.grey.shade400
                              : Colors.black87,
                        ),
                      ),
                      Text(
                        '${med.dose} • $timeStr',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        med.frequency,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFE8A0BF),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final markTaken = !med.taken;
                    StorageService.updateMedicineTaken(index, markTaken);
                    if (markTaken) {
                      await NotificationService()
                          .cancelNotification(med.notificationId);
                    }
                    _loadData();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: med.taken
                          ? const Color(0xFFE8A0BF)
                          : const Color(0xFFF5E6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      med.taken
                          ? Icons.check_rounded
                          : Icons.circle_outlined,
                      color: med.taken
                          ? Colors.white
                          : const Color(0xFFE8A0BF),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8A0BF).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AddMedicineScreen()),
          );
          _loadData();
        },
        backgroundColor: const Color(0xFFE8A0BF),
        elevation: 0,
        icon: const Icon(Icons.add_rounded,
            color: Colors.white, size: 26),
        label: Text(
          'Add Medicine',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}