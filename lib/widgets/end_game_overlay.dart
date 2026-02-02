import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../utils/app_colors.dart';

class EndGameOverlay extends StatelessWidget {
  final GameStatus gameStatus;
  final int? winner;
  final String? endCondition;
  final int moveCount;
  final Future<void> Function() onReset;

  const EndGameOverlay({
    super.key,
    required this.gameStatus,
    this.winner,
    this.endCondition,
    this.moveCount = 0,
    required this.onReset,
  });

  String _getResultText() {
    switch (gameStatus) {
      case GameStatus.checkmate:
        return 'Player $winner wins by Checkmate!';
      case GameStatus.forfeit:
        return 'Player $winner wins by Forfeit!';
      case GameStatus.timeout:
        return 'Player $winner wins by Time Out!';
      case GameStatus.stalemate:
        return 'Draw by Stalemate!';
      default:
        return '';
    }
  }

  IconData _getResultIcon() {
    switch (gameStatus) {
      case GameStatus.checkmate:
        return Icons.emoji_events;
      case GameStatus.forfeit:
        return Icons.flag;
      case GameStatus.timeout:
        return Icons.timer_off;
      case GameStatus.stalemate:
        return Icons.handshake;
      default:
        return Icons.info;
    }
  }

  Color _getResultColor() {
    switch (gameStatus) {
      case GameStatus.checkmate:
      case GameStatus.forfeit:
      case GameStatus.timeout:
        return AppColors.active;
      case GameStatus.stalemate:
        return AppColors.textSecondary;
      default:
        return AppColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // This ensures the background is dimmed
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Material(
                // Material moved here to only wrap the dialog
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _getResultColor(), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getResultIcon(),
                        size: 64,
                        color: _getResultColor(),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _getResultText(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getResultColor(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () async {
                          SystemChrome.setEnabledSystemUIMode(
                            SystemUiMode.edgeToEdge,
                          );
                          await onReset();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/settings',
                              (route) => false,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.active,
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'New Game',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
