class TimePreset {
  final String name;
  final int minutes;
  final int increment;

  const TimePreset({
    required this.name,
    required this.minutes,
    required this.increment,
  });

  String get displayName => increment > 0 ? '$minutes + $increment' : '$minutes min';
}

class TimePresetCategory {
  final String category;
  final List<TimePreset> presets;

  const TimePresetCategory({
    required this.category,
    required this.presets,
  });
}
