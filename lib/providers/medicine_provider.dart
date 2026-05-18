import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../medicine_model.dart';

class MedicineProvider extends ChangeNotifier {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<Medicine> _medicines = [];
  bool _isLoading = false;
  bool _isOnline = true;
  String _error = '';

  MedicineProvider() {
    _loadFromHive();
  }

  void refresh() {
    _loadFromHive();
    notifyListeners();
  }

  Future<void> markAsTakenByNotification(int rawId, String name) async {
    var index = -1;
    for (int i = 0; i < _medicines.length; i++) {
      if (_medicines[i].notificationId == rawId || 
          _medicines[i].name.toLowerCase().trim() == name.toLowerCase().trim()) {
        index = i;
        break;
      }
    }

    if (index != -1) {
      _medicines[index].taken = true;
      
      try {
        if (_userId != null && _medicines[index].id.isNotEmpty) {
          final ref = _database
              .ref('users/$_userId/medicines/${_medicines[index].id}');
          await ref.update({'taken': true});
        }
      } catch (_) {}
      
      _saveToHive();
      notifyListeners();
    }
  }

  Future<void> syncPendingTakenToFirebase() async {
    final box = Hive.box('medicines');
    final List pending =
        List.from(box.get('pending_taken', defaultValue: []) as List);
    if (pending.isEmpty) return;
    
    var changed = false;
    for (final name in pending) {
      final cleanName = name.toString().toLowerCase().trim();
      for (int i = 0; i < _medicines.length; i++) {
        if (_medicines[i].name.toLowerCase().trim() == cleanName && !_medicines[i].taken) {
          _medicines[i].taken = true;
          changed = true;
          try {
            if (_userId != null && _medicines[i].id.isNotEmpty) {
              final ref = _database
                  .ref('users/$_userId/medicines/${_medicines[i].id}');
              await ref.update({'taken': true});
            }
          } catch (_) {}
        }
      }
    }
    
    if (changed) {
      _saveToHive();
      await box.put('pending_taken', []);
      notifyListeners();
    }
  }

  List<Medicine> get medicines => _medicines;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  String get error => _error;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  // ===== LOAD MEDICINES =====
  Future<void> loadMedicines() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    // 1. Process any pending taken status from notifications before fetching final list
    try {
      final box = Hive.box('medicines');
      final List pending = List.from(box.get('pending_taken', defaultValue: []) as List);
      if (pending.isNotEmpty) {
        final cleanPending = pending.map((e) => e.toString().toLowerCase().trim()).toList();
        _loadFromHive(); // ensure we have latest local state loaded
        var changed = false;
        for (final med in _medicines) {
          if (cleanPending.contains(med.name.toLowerCase().trim()) && !med.taken) {
            med.taken = true;
            changed = true;
            if (_userId != null && med.id.isNotEmpty) {
              try {
                final ref = _database.ref('users/$_userId/medicines/${med.id}');
                await ref.update({'taken': true});
              } catch (_) {}
            }
          }
        }
        if (changed) {
          _saveToHive();
          await box.put('pending_taken', []);
        }
      }
    } catch (_) {}

    try {
      if (_userId != null) {
        // Online — Firebase se load
        final ref = _database.ref('users/$_userId/medicines');
        final snapshot = await ref.get().timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Connection timeout!'),
        );

        if (snapshot.exists) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          _medicines = data.entries.map((e) {
            final map = Map<String, dynamic>.from(e.value as Map);
            map['id'] = e.key;
            return Medicine.fromMap(map);
          }).toList();

          // Local backup
          final box = Hive.box('medicines');
          box.put('list', _medicines.map((m) => m.toMap()).toList());
        } else {
          _medicines = [];
        }
        _isOnline = true;
      } else {
        _loadFromHive();
      }
    } catch (e) {
      _error = 'No internet! Showing offline data.';
      _isOnline = false;
      _loadFromHive();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _loadFromHive() {
    final box = Hive.box('medicines');
    final data = box.get('list', defaultValue: []);
    _medicines = (data as List)
        .map((item) =>
        Medicine.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  // ===== ADD MEDICINE =====
  Future<void> addMedicine(Medicine medicine) async {
    try {
      if (_userId != null) {
        final ref =
        _database.ref('users/$_userId/medicines').push();
        await ref.set(medicine.toMap());
        medicine.id = ref.key ?? '';
      }
    } catch (e) {
      _error = 'Saved offline only!';
    }

    _medicines.add(medicine);
    _saveToHive();
    notifyListeners();
  }

  // ===== UPDATE MEDICINE =====
  Future<void> updateMedicine(int index, Medicine updated) async {
    try {
      if (_userId != null && _medicines[index].id.isNotEmpty) {
        final ref = _database
            .ref('users/$_userId/medicines/${_medicines[index].id}');
        await ref.update(updated.toMap());
      }
    } catch (e) {
      _error = 'Updated offline only!';
    }

    _medicines[index] = updated;
    _saveToHive();
    notifyListeners();
  }

  // ===== UPDATE TAKEN STATUS =====
  Future<void> updateTaken(int index, bool taken) async {
    _medicines[index].taken = taken;

    try {
      if (_userId != null && _medicines[index].id.isNotEmpty) {
        final ref = _database
            .ref('users/$_userId/medicines/${_medicines[index].id}');
        await ref.update({'taken': taken});
      }
    } catch (e) {
      _error = 'Updated offline only!';
    }

    _saveToHive();
    notifyListeners();
  }

  // ===== DELETE MEDICINE =====
  Future<void> deleteMedicine(int index) async {
    try {
      if (_userId != null && _medicines[index].id.isNotEmpty) {
        final ref = _database
            .ref('users/$_userId/medicines/${_medicines[index].id}');
        await ref.remove();
      }
    } catch (e) {
      _error = 'Deleted offline only!';
    }

    _medicines.removeAt(index);
    _saveToHive();
    notifyListeners();
  }

  void _saveToHive() {
    final box = Hive.box('medicines');
    box.put('list', _medicines.map((m) => m.toMap()).toList());
  }
}