/// Represents a completed match saved in history.
class MatchHistory {
  final String id;
  final String player1Name;
  final String player2Name;
  final int minutes;
  final int increment;
  final int? winner; // 1, 2, or null for draw
  final String endCondition; // checkmate, stalemate, forfeit, timeout
  final int moveCount;
  final DateTime playedAt;
  final bool isFavourite;

  const MatchHistory({
    required this.id,
    required this.player1Name,
    required this.player2Name,
    required this.minutes,
    required this.increment,
    this.winner,
    required this.endCondition,
    required this.moveCount,
    required this.playedAt,
    this.isFavourite = false,
  });

  String get timeControlDisplay {
    if (increment == 0) {
      return '$minutes min';
    }
    return '$minutes + $increment';
  }

  String get resultSummary {
    if (winner == null) {
      return 'Draw (Stalemate)';
    }
    final winnerName = winner == 1 ? player1Name : player2Name;
    switch (endCondition) {
      case 'checkmate':
        return '$winnerName wins by Checkmate';
      case 'forfeit':
        return '$winnerName wins by Forfeit';
      case 'timeout':
        return '$winnerName wins by Time Out';
      case 'stalemate':
        return 'Draw by Stalemate';
      default:
        return '$winnerName wins';
    }
  }

  String get endConditionDisplay {
    switch (endCondition) {
      case 'checkmate':
        return 'Checkmate';
      case 'forfeit':
        return 'Forfeit';
      case 'timeout':
        return 'Time Out';
      case 'stalemate':
        return 'Stalemate';
      default:
        return endCondition;
    }
  }

  MatchHistory copyWith({
    String? id,
    String? player1Name,
    String? player2Name,
    int? minutes,
    int? increment,
    int? winner,
    String? endCondition,
    int? moveCount,
    DateTime? playedAt,
    bool? isFavourite,
  }) {
    return MatchHistory(
      id: id ?? this.id,
      player1Name: player1Name ?? this.player1Name,
      player2Name: player2Name ?? this.player2Name,
      minutes: minutes ?? this.minutes,
      increment: increment ?? this.increment,
      winner: winner ?? this.winner,
      endCondition: endCondition ?? this.endCondition,
      moveCount: moveCount ?? this.moveCount,
      playedAt: playedAt ?? this.playedAt,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player1Name': player1Name,
      'player2Name': player2Name,
      'minutes': minutes,
      'increment': increment,
      'winner': winner,
      'endCondition': endCondition,
      'moveCount': moveCount,
      'playedAt': playedAt.toIso8601String(),
      'isFavourite': isFavourite,
    };
  }

  factory MatchHistory.fromJson(Map<String, dynamic> json) {
    return MatchHistory(
      id: json['id'] as String,
      player1Name: json['player1Name'] as String,
      player2Name: json['player2Name'] as String,
      minutes: json['minutes'] as int,
      increment: json['increment'] as int,
      winner: json['winner'] as int?,
      endCondition: json['endCondition'] as String,
      moveCount: json['moveCount'] as int,
      playedAt: DateTime.parse(json['playedAt'] as String),
      isFavourite: json['isFavourite'] as bool? ?? false,
    );
  }
}
