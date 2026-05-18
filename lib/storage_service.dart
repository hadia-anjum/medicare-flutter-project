import 'package:hive_flutter/hive_flutter.dart';
import 'medicine_model.dart';

class StorageService {
  static final Box _box = Hive.box('medicines');
  static final Box _userBox = Hive.box('user');

  // ===== USER =====
  static void saveUserName(String name) {
    _userBox.put('name', name);
  }

  static String getUserName() {
    return _userBox.get('name', defaultValue: '');
  }

  static bool isUserRegistered() {
    return _userBox.get('name', defaultValue: '') != '';
  }

  // ===== RINGTONE =====
  static void saveRingtone(String ringtone) {
    _userBox.put('ringtone', ringtone);
  }

  static String getRingtone() {
    return _userBox.get('ringtone', defaultValue: 'Default Ringtone 🎵');
  }

  // ===== MEDICINES =====
  static void saveMedicine(Medicine medicine) {
    final medicines = getAllMedicines();
    medicines.add(medicine);
    _box.put('list', medicines.map((m) => m.toMap()).toList());
  }

  static List<Medicine> getAllMedicines() {
    final data = _box.get('list', defaultValue: []);
    return (data as List)
        .map((item) => Medicine.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  static void updateMedicineTaken(int index, bool taken) {
    final medicines = getAllMedicines();
    medicines[index].taken = taken;
    _box.put('list', medicines.map((m) => m.toMap()).toList());
  }

  static void markMedicineTakenByNotificationId(int notificationId) {
    final medicines = getAllMedicines();
    for (final medicine in medicines) {
      if (medicine.notificationId == notificationId) {
        medicine.taken = true;
        _box.put('list', medicines.map((m) => m.toMap()).toList());
        return;
      }
    }
  }

  /// Applies "Mark as Done" from notification buttons (pending_taken list).
  static void applyPendingTakenFromNotifications() {
    final raw = _box.get('pending_taken', defaultValue: []) as List;
    final pending =
    raw.map((e) => e.toString().toLowerCase().trim()).toList();
    if (pending.isEmpty) return;

    final medicines = getAllMedicines();
    var changed = false;
    for (final med in medicines) {
      if (pending.contains(med.name.toLowerCase().trim())) {
        med.taken = true;
        changed = true;
      }
    }
    if (changed) {
      _box.put('list', medicines.map((m) => m.toMap()).toList());
      _box.put('pending_taken', []);
    }
  }

  static void deleteMedicine(int index) {
    final medicines = getAllMedicines();
    medicines.removeAt(index);
    _box.put('list', medicines.map((m) => m.toMap()).toList());
  }
}