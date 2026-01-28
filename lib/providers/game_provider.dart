import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/player.dart';
import '../models/game_state.dart';

class GameProvider extends ChangeNotifier {
  Player player1 = Player(
    name: 'Player 1',
    playerNumber: 1,
    timeRemaining: const Duration(minutes: 5),
  );
  
  Player player2 = Player(
    name: 'Player 2',
    playerNumber: 2,
    timeRemaining: const Duration(minutes: 5),
  );

  int currentPlayer = 1;
  GameStatus gameStatus = GameStatus.notStarted;
  Timer? timer;
  
  bool pauseRequestedByPlayer1 = false;
  bool pauseRequestedByPlayer2 = false;
  bool swapped = false;
  bool confirmationActive = false; // Track if confirmation overlay is showing
  
  int initialMinutes = 5;
  int incrementSeconds = 0;
  
  int? winner;
  String? endCondition;

  void setPlayerName(int playerNumber, String name) {
    if (playerNumber == 1) {
      player1 = player1.copyWith(name: name.isEmpty ? 'Player 1' : name);
    } else {
      player2 = player2.copyWith(name: name.isEmpty ? 'Player 2' : name);
    }
    notifyListeners();
  }

  void randomizeFirstPlayer() {
    final random = DateTime.now().millisecondsSinceEpoch % 2;
    swapped = random == 1;
    notifyListeners();
  }

  void initializeGame(int minutes, int increment) {
    initialMinutes = minutes;
    incrementSeconds = increment;
    player1 = player1.copyWith(
      timeRemaining: Duration(minutes: minutes),
      isActive: false,
    );
    player2 = player2.copyWith(
      timeRemaining: Duration(minutes: minutes),
      isActive: false,
    );
    currentPlayer = 1;
    gameStatus = GameStatus.notStarted;
    pauseRequestedByPlayer1 = false;
    pauseRequestedByPlayer2 = false;
    confirmationActive = false;
    winner = null;
    endCondition = null;
    notifyListeners();
  }

  void startGame() {
    if (gameStatus == GameStatus.notStarted) {
      gameStatus = GameStatus.ongoing;
      player1 = player1.copyWith(isActive: true);
      player2 = player2.copyWith(isActive: false);
      currentPlayer = 1;
      startTimer();
      notifyListeners();
    }
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (gameStatus != GameStatus.ongoing || confirmationActive) {
        timer.cancel();
        return;
      }

      if (currentPlayer == 1) {
        if (player1.timeRemaining.inMilliseconds <= 0) {
          handleTimeout();
          return;
        }
        player1 = player1.copyWith(
          timeRemaining: player1.timeRemaining - const Duration(milliseconds: 100),
        );
      } else {
        if (player2.timeRemaining.inMilliseconds <= 0) {
          handleTimeout();
          return;
        }
        player2 = player2.copyWith(
          timeRemaining: player2.timeRemaining - const Duration(milliseconds: 100),
        );
      }
      notifyListeners();
    });
  }

  void switchTurn() {
    if (gameStatus != GameStatus.ongoing) return;

    timer?.cancel();

    // Add increment to current player
    if (currentPlayer == 1) {
      player1 = player1.copyWith(
        timeRemaining: player1.timeRemaining + Duration(seconds: incrementSeconds),
      );
    } else {
      player2 = player2.copyWith(
        timeRemaining: player2.timeRemaining + Duration(seconds: incrementSeconds),
      );
    }

    // Switch active player
    currentPlayer = currentPlayer == 1 ? 2 : 1;
    player1 = player1.copyWith(isActive: currentPlayer == 1);
    player2 = player2.copyWith(isActive: currentPlayer == 2);

    startTimer();
    notifyListeners();
  }

  void pauseForConfirmation() {
    if (gameStatus == GameStatus.ongoing) {
      confirmationActive = true;
      timer?.cancel();
      notifyListeners();
    }
  }

  void resumeAfterConfirmation() {
    if (gameStatus == GameStatus.ongoing && confirmationActive) {
      confirmationActive = false;
      startTimer();
      notifyListeners();
    }
  }

  void requestPause(int player) {
    if (gameStatus != GameStatus.ongoing) return;

    if (player == 1) {
      pauseRequestedByPlayer1 = true;
    } else {
      pauseRequestedByPlayer2 = true;
    }

    if (pauseRequestedByPlayer1 && pauseRequestedByPlayer2) {
      gameStatus = GameStatus.paused;
      timer?.cancel();
    }
    notifyListeners();
  }

  void resumeGame() {
    if (gameStatus == GameStatus.paused) {
      gameStatus = GameStatus.ongoing;
      pauseRequestedByPlayer1 = false;
      pauseRequestedByPlayer2 = false;
      startTimer();
      notifyListeners();
    }
  }

  void cancelPause() {
    if (gameStatus == GameStatus.paused) {
      pauseRequestedByPlayer1 = false;
      pauseRequestedByPlayer2 = false;
      gameStatus = GameStatus.ongoing;
      startTimer();
    } else {
      pauseRequestedByPlayer1 = false;
      pauseRequestedByPlayer2 = false;
    }
    notifyListeners();
  }

  void handleCheckmate(int player) {
    if (gameStatus != GameStatus.ongoing) return;
    endGame('checkmate', player);
  }

  void handleStalemate() {
    if (gameStatus != GameStatus.ongoing) return;
    endGame('stalemate', null);
  }

  void handleForfeit(int player) {
    if (gameStatus != GameStatus.ongoing) return;
    // Opponent wins
    int winner = player == 1 ? 2 : 1;
    endGame('forfeit', winner);
  }

  void handleTimeout() {
    if (gameStatus != GameStatus.ongoing) return;
    // Current player loses, opponent wins
    int winner = currentPlayer == 1 ? 2 : 1;
    endGame('timeout', winner);
  }

  void endGame(String condition, int? winnerPlayer) {
    timer?.cancel();
    gameStatus = _getGameStatusFromCondition(condition);
    winner = winnerPlayer;
    endCondition = condition;
    player1 = player1.copyWith(isActive: false);
    player2 = player2.copyWith(isActive: false);
    
    // Haptic feedback
    HapticFeedback.mediumImpact();
    
    notifyListeners();
  }

  GameStatus _getGameStatusFromCondition(String condition) {
    switch (condition) {
      case 'checkmate':
        return GameStatus.checkmate;
      case 'stalemate':
        return GameStatus.stalemate;
      case 'forfeit':
        return GameStatus.forfeit;
      case 'timeout':
        return GameStatus.timeout;
      default:
        return GameStatus.ongoing;
    }
  }

  void swapPositions() {
    swapped = !swapped;
    notifyListeners();
  }

  void resetGame() {
    timer?.cancel();
    initializeGame(initialMinutes, incrementSeconds);
  }

  bool get isLowTime {
    if (currentPlayer == 1) {
      return player1.timeRemaining.inSeconds < 10;
    } else {
      return player2.timeRemaining.inSeconds < 10;
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
