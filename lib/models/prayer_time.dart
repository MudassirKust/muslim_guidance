class PrayerTime {
  final String name;
  final String time;
  final String icon;
  final bool isCurrent;
  final String? key;

  PrayerTime({
    required this.name,
    required this.time,
    required this.icon,
    this.isCurrent = false,
    this.key,
  });

  PrayerTime copyWith({
    String? name,
    String? time,
    String? icon,
    bool? isCurrent,
    String? key,
  }) {
    return PrayerTime(
      name: name ?? this.name,
      time: time ?? this.time,
      icon: icon ?? this.icon,
      isCurrent: isCurrent ?? this.isCurrent,
      key: key ?? this.key,
    );
  }

  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    return PrayerTime(
      name: json['name'] ?? '',
      time: json['time'] ?? '',
      icon: json['icon'] ?? '',
      isCurrent: json['isCurrent'] ?? false,
      key: json['key'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'time': time,
      'icon': icon,
      'isCurrent': isCurrent,
      if (key != null) 'key': key,
    };
  }
}
