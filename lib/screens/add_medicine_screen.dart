import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../medicine_model.dart';
import '../notification_service.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';
import '../app_colors.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();

  String selectedIcon = '💊';
  String selectedFrequency = 'Once a day';
  TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
  String selectedColor = 'Pink';
  bool _isSaving = false;

  final List<String> frequencies = [
    'Once a day',
    'Twice a day',
    'Three times a day',
    'Every week',
  ];


  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNameField(),
                      const SizedBox(height: 15),
                      _buildDoseField(),
                      const SizedBox(height: 15),
                      _buildFrequencyPicker(),
                      const SizedBox(height: 15),
                      _buildTimePicker(context),
                      const SizedBox(height: 30),
                      _buildSaveButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Medicine 💊',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Set your reminder schedule',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Medicine Name',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: _inputDecoration(
              'e.g. Panadol, Vitamin C', Icons.medication_rounded),
          validator: (v) =>
          v!.isEmpty ? 'Please enter medicine name' : null,
        ),
      ],
    );
  }

  Widget _buildDoseField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dosage',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _doseController,
          decoration: _inputDecoration(
              'e.g. 500mg, 1 Tablet, 2 Capsules',
              Icons.colorize_rounded),
          validator: (v) =>
          v!.isEmpty ? 'Please enter dosage' : null,
        ),
      ],
    );
  }

  Widget _buildFrequencyPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frequency',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedFrequency,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary),
              items: frequencies
                  .map((f) => DropdownMenuItem(
                value: f,
                child: Text(f, style: GoogleFonts.poppins()),
              ))
                  .toList(),
              onChanged: (val) =>
                  setState(() => selectedFrequency = val!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reminder Time',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: selectedTime,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() => selectedTime = picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.access_time_rounded,
                    color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  selectedTime.format(context),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Tap to change',
                    style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveMedicine,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          'Save & Set Reminder 🔔',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
          color: Colors.grey.shade400, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Future<void> _saveMedicine() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      // Generate a stable unique notification ID and attach it to the medicine
      // so we can cancel its notifications reliably later.
      final notifId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final medicine = Medicine(
        name: _nameController.text.trim(),
        dose: _doseController.text.trim(),
        icon: selectedIcon,
        color: selectedColor,
        frequency: selectedFrequency,
        hour: selectedTime.hour,
        minute: selectedTime.minute,
        taken: false,
        notificationId: notifId,   // ← saved so cancel works later
      );

      await Provider.of<MedicineProvider>(context, listen: false)
          .addMedicine(medicine);

      await NotificationService().scheduleMedicineReminder(
        id: notifId,               // ← same ID used for scheduling
        medicineName: medicine.name,
        dose: medicine.dose,
        hour: medicine.hour,
        minute: medicine.minute,
      );

      setState(() => _isSaving = false);

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔔', style: TextStyle(fontSize: 50)),
                const SizedBox(height: 10),
                Text('Reminder Set!',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                Text(
                  '${_nameController.text} reminder set for ${selectedTime.format(context)}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Done ',
                    style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    }
  }
}