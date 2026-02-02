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
import '../models/match_history.dart';
import '../services/history_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  ConfirmationType? _activeConfirmation;
  int? _confirmationPlayerNumber;
  bool _saveScheduled = false;

  @override
  void initState() {
    super.initState();
    // Enable full screen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
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
        final player1 = gameProvider.swapped
            ? gameProvider.player2
            : gameProvider.player1;
        final player2 = gameProvider.swapped
            ? gameProvider.player1
            : gameProvider.player2;
        final isGameEnded =
            gameProvider.gameStatus == GameStatus.checkmate ||
            gameProvider.gameStatus == GameStatus.stalemate ||
            gameProvider.gameStatus == GameStatus.forfeit ||
            gameProvider.gameStatus == GameStatus.timeout;
        final isPaused = gameProvider.gameStatus == GameStatus.paused;
        final showConfirmation =
            _activeConfirmation != null && _confirmationPlayerNumber != null;

        // Save match in background when game ends (once), without blocking UI
        if (isGameEnded && !_saveScheduled) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted || _saveScheduled) return;
            _saveScheduled = true;
            setState(() {});
            final gp = gameProvider;
            final match = MatchHistory(
              id: '${DateTime.now().millisecondsSinceEpoch}_${gp.totalMoveCount}',
              player1Name: gp.player1.name,
              player2Name: gp.player2.name,
              minutes: gp.initialMinutes,
              increment: gp.incrementSeconds,
              winner: gp.winner,
              endCondition: gp.endCondition ?? '',
              moveCount: gp.totalMoveCount,
              playedAt: DateTime.now(),
            );
            await HistoryService().addMatch(match);
          });
        }

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
                                transform: Matrix4.rotationZ(
                                  3.14159,
                                ), // 180 degrees
                                child: PlayerHalf(
                                  player: player2,
                                  isSwapped: gameProvider.swapped,
                                  isInverted: true,
                                  onCheckmateRequested: () {
                                    setState(() {
                                      _activeConfirmation =
                                          ConfirmationType.checkmate;
                                      _confirmationPlayerNumber =
                                          player2.playerNumber;
                                    });
                                  },
                                  onStalemateRequested: () {
                                    setState(() {
                                      _activeConfirmation =
                                          ConfirmationType.stalemate;
                                      _confirmationPlayerNumber =
                                          player2.playerNumber;
                                    });
                                  },
                                  onForfeitRequested: () {
                                    setState(() {
                                      _activeConfirmation =
                                          ConfirmationType.forfeit;
                                      _confirmationPlayerNumber =
                                          player2.playerNumber;
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
                                    _activeConfirmation =
                                        ConfirmationType.checkmate;
                                    _confirmationPlayerNumber =
                                        player1.playerNumber;
                                  });
                                },
                                onStalemateRequested: () {
                                  gameProvider.pauseForConfirmation();
                                  setState(() {
                                    _activeConfirmation =
                                        ConfirmationType.stalemate;
                                    _confirmationPlayerNumber =
                                        player1.playerNumber;
                                  });
                                },
                                onForfeitRequested: () {
                                  gameProvider.pauseForConfirmation();
                                  setState(() {
                                    _activeConfirmation =
                                        ConfirmationType.forfeit;
                                    _confirmationPlayerNumber =
                                        player1.playerNumber;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        // Overlay: swap button centered (48px tall → center at half - 24)
                        Positioned(
                          left: 0,
                          right: 0,
                          // Adjust 'top' to account for the extra margin you're adding
                          // If margin is 16, subtract 16 from the original top to keep the button centered
                          top: (constraints.maxHeight / 2 - 24) - 16,
                          height:
                              48 +
                              32, // Original height (48) + top/bottom margin (16 + 16)
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ), // This creates the "push"
                            child: Center(child: SwapButton()),
                          ),
                        ),
                        // Move counter: bottom-left for player 1 (down half)
                        if (gameProvider.gameStatus == GameStatus.ongoing ||
                            gameProvider.gameStatus == GameStatus.paused)
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: _MoveCounterBadge(
                              count: gameProvider.player1Moves,
                            ),
                          ),
                        // Move counter: top-right for player 2 (upper half)
                        if (gameProvider.gameStatus == GameStatus.ongoing ||
                            gameProvider.gameStatus == GameStatus.paused)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationZ(
                                3.14159,
                              ), // 180 degrees
                              child: _MoveCounterBadge(
                                count: gameProvider.player2Moves,
                              ),
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
                      child: EndGameOverlay(
                        gameStatus: gameProvider.gameStatus,
                        winner: gameProvider.winner,
                        endCondition: gameProvider.endCondition,
                        moveCount: gameProvider.totalMoveCount,
                        onReset: () async {
                          gameProvider.resetGame();
                        },
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

class _MoveCounterBadge extends StatelessWidget {
  final int count;

  const _MoveCounterBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        '$count ${count == 1 ? "move" : "moves"}',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
