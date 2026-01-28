import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_state.dart';
import '../utils/app_colors.dart';
import '../widgets/player_half.dart';
import '../widgets/swap_button.dart';
import '../widgets/end_game_overlay.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/confirmation_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  ConfirmationType? _activeConfirmation;
  int? _confirmationPlayerNumber;

  @override
  void initState() {
    super.initState();
    // Enable full screen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore system UI when leaving game screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  /// Calculates whether the confirmation overlay should appear on top (player2 side) or bottom (player1 side)
  /// Takes into account swap state and inverted orientation
  bool _calculateConfirmationPosition(
    ConfirmationType type,
    int clickedPlayerNumber,
    bool isSwapped,
  ) {
    // Determine which visual side the clicked player is on
    // When swapped: player1 is visually on top, player2 is visually on bottom
    // When not swapped: player1 is visually on bottom, player2 is visually on top
    final clickedPlayerOnTop = isSwapped
        ? clickedPlayerNumber == 1
        : clickedPlayerNumber == 2;

    if (type == ConfirmationType.forfeit) {
      // For forfeit: show on the same visual side as the player who clicked
      return clickedPlayerOnTop;
    } else {
      // For checkmate/stalemate: show on the opponent's visual side
      return !clickedPlayerOnTop;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final player1 = gameProvider.swapped ? gameProvider.player2 : gameProvider.player1;
        final player2 = gameProvider.swapped ? gameProvider.player1 : gameProvider.player2;
        final isGameEnded = gameProvider.gameStatus == GameStatus.checkmate ||
            gameProvider.gameStatus == GameStatus.stalemate ||
            gameProvider.gameStatus == GameStatus.forfeit ||
            gameProvider.gameStatus == GameStatus.timeout;
        final isPaused = gameProvider.gameStatus == GameStatus.paused;
        final showConfirmation = _activeConfirmation != null && _confirmationPlayerNumber != null;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Main timer layout - fixed size, never changes
                  Positioned.fill(
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            // Player 2 (Top) - Inverted
                            Expanded(
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationZ(3.14159), // 180 degrees
                                child: PlayerHalf(
                                  player: player2,
                                  isSwapped: gameProvider.swapped,
                                  isInverted: true,
                                  onCheckmateRequested: () {
                                    setState(() {
                                      _activeConfirmation = ConfirmationType.checkmate;
                                      _confirmationPlayerNumber = player2.playerNumber;
                                    });
                                  },
                                  onStalemateRequested: () {
                                    setState(() {
                                      _activeConfirmation = ConfirmationType.stalemate;
                                      _confirmationPlayerNumber = player2.playerNumber;
                                    });
                                  },
                                  onForfeitRequested: () {
                                    setState(() {
                                      _activeConfirmation = ConfirmationType.forfeit;
                                      _confirmationPlayerNumber = player2.playerNumber;
                                    });
                                  },
                                ),
                              ),
                            ),
                            // Player 1 (Bottom) - Normal
                            Expanded(
                              child: PlayerHalf(
                                player: player1,
                                isSwapped: gameProvider.swapped,
                                isInverted: false,
                                onCheckmateRequested: () {
                                  gameProvider.pauseForConfirmation();
                                  setState(() {
                                    _activeConfirmation = ConfirmationType.checkmate;
                                    _confirmationPlayerNumber = player1.playerNumber;
                                  });
                                },
                                onStalemateRequested: () {
                                  gameProvider.pauseForConfirmation();
                                  setState(() {
                                    _activeConfirmation = ConfirmationType.stalemate;
                                    _confirmationPlayerNumber = player1.playerNumber;
                                  });
                                },
                                onForfeitRequested: () {
                                  gameProvider.pauseForConfirmation();
                                  setState(() {
                                    _activeConfirmation = ConfirmationType.forfeit;
                                    _confirmationPlayerNumber = player1.playerNumber;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        // Overlay swap button in the middle
                        Positioned(
                          left: 0,
                          right: 0,
                          top: constraints.maxHeight / 2 - 24,
                          child: Center(
                            child: SwapButton(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Overlays - positioned absolutely, don't affect timer layout
                  if (isPaused)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {}, // Prevent taps from passing through
                        child: PauseOverlay(
                          onResume: () => gameProvider.resumeGame(),
                          onCancel: () => gameProvider.cancelPause(),
                        ),
                      ),
                    ),
                  if (isGameEnded)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {}, // Prevent taps from passing through
                        child: EndGameOverlay(
                          gameStatus: gameProvider.gameStatus,
                          winner: gameProvider.winner,
                          endCondition: gameProvider.endCondition,
                          onReset: () {
                            gameProvider.resetGame();
                            // UI restoration is handled by dispose() and EndGameOverlay navigation
                          },
                        ),
                      ),
                    ),
                  // Confirmation overlay
                  if (showConfirmation)
                    Positioned.fill(
                      child: ConfirmationOverlay(
                        type: _activeConfirmation!,
                        playerNumber: _confirmationPlayerNumber!,
                        playerName: _confirmationPlayerNumber == 1
                            ? gameProvider.player1.name
                            : gameProvider.player2.name,
                        showOnTop: _calculateConfirmationPosition(
                          _activeConfirmation!,
                          _confirmationPlayerNumber!,
                          gameProvider.swapped,
                        ),
                        onConfirm: () {
                          // Store values before clearing state
                          final type = _activeConfirmation;
                          final playerNum = _confirmationPlayerNumber;
                          setState(() {
                            _activeConfirmation = null;
                            _confirmationPlayerNumber = null;
                          });
                          // Resume timer after confirmation closes
                          gameProvider.resumeAfterConfirmation();
                          // Execute the action
                          if (type != null && playerNum != null) {
                            switch (type) {
                              case ConfirmationType.checkmate:
                                gameProvider.handleCheckmate(playerNum);
                                break;
                              case ConfirmationType.stalemate:
                                gameProvider.handleStalemate();
                                break;
                              case ConfirmationType.forfeit:
                                gameProvider.handleForfeit(playerNum);
                                break;
                            }
                          }
                        },
                        onCancel: () {
                          setState(() {
                            _activeConfirmation = null;
                            _confirmationPlayerNumber = null;
                          });
                          // Resume timer after confirmation closes
                          gameProvider.resumeAfterConfirmation();
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
