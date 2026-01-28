class Player {
  Duration timeRemaining;
  bool isActive;
  final String name;
  final int playerNumber;

  Player({
    required this.timeRemaining,
    this.isActive = false,
    required this.name,
    required this.playerNumber,
  });

  Player copyWith({
    Duration? timeRemaining,
    bool? isActive,
    String? name,
    int? playerNumber,
  }) {
    return Player(
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isActive: isActive ?? this.isActive,
      name: name ?? this.name,
      playerNumber: playerNumber ?? this.playerNumber,
    );
  }
}
