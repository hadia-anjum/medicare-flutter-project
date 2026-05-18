class Medicine {
  String id;
  String name;
  String dose;
  String icon;
  String color;
  String frequency;
  int hour;
  int minute;
  bool taken;
  int notificationId;

  Medicine({
    this.id = '',
    required this.name,
    required this.dose,
    required this.icon,
    required this.color,
    required this.frequency,
    required this.hour,
    required this.minute,
    this.taken = false,
    this.notificationId = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dose': dose,
      'icon': icon,
      'color': color,
      'frequency': frequency,
      'hour': hour,
      'minute': minute,
      'taken': taken,
      'notificationId': notificationId,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      dose: map['dose'] ?? '',
      icon: map['icon'] ?? '💊',
      color: map['color'] ?? 'Pink',
      frequency: map['frequency'] ?? 'Once a day',
      hour: map['hour'] ?? 8,
      minute: map['minute'] ?? 0,
      taken: map['taken'] ?? false,
      notificationId: map['notificationId'] ?? 0,
    );
  }
}