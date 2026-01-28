import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_state.dart';
import '../utils/app_colors.dart';

class ActionButtons extends StatelessWidget {
  final int playerNumber;
  final bool isInverted;
  final VoidCallback? onCheckmatePressed;
  final VoidCallback? onStalematePressed;
  final VoidCallback? onForfeitPressed;

  const ActionButtons({
    super.key,
    required this.playerNumber,
    required this.isInverted,
    this.onCheckmatePressed,
    this.onStalematePressed,
    this.onForfeitPressed,
  });

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final gameStatus = gameProvider.gameStatus;
    final isPaused = gameStatus == GameStatus.paused;
    final isGameActive = gameStatus == GameStatus.ongoing;

    if (!isGameActive && !isPaused) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top row: Checkmate, Stalemate, Forfeit
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionButton(
              label: 'Checkmate',
              icon: Icons.emoji_events,
              onPressed: isGameActive ? onCheckmatePressed : null,
              color: AppColors.active,
            ),
            const SizedBox(width: 8),
            _ActionButton(
              label: 'Stalemate',
              icon: Icons.handshake,
              onPressed: isGameActive ? onStalematePressed : null,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            _ActionButton(
              label: 'Forfeit',
              icon: Icons.flag,
              onPressed: isGameActive ? onForfeitPressed : null,
              color: AppColors.danger,
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Bottom: Pause button centered
        _ActionButton(
          label: gameProvider.pauseRequestedByPlayer1 && playerNumber == 1 ||
                  gameProvider.pauseRequestedByPlayer2 && playerNumber == 2
              ? 'Pause Requested'
              : isPaused
                  ? 'Resume'
                  : 'Pause',
          icon: isPaused ? Icons.play_arrow : Icons.pause,
          onPressed: () {
            HapticFeedback.mediumImpact();
            if (isPaused) {
              gameProvider.resumeGame();
            } else if (isGameActive) {
              gameProvider.requestPause(playerNumber);
            }
          },
          color: AppColors.textSecondary,
          isHighlighted: (gameProvider.pauseRequestedByPlayer1 && playerNumber == 1) ||
              (gameProvider.pauseRequestedByPlayer2 && playerNumber == 2),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final bool isHighlighted;

  const _ActionButton({
    required this.label,
    required this.icon,
    this.onPressed,
    required this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isHighlighted
            ? AppColors.active.withOpacity(0.3)
            : AppColors.surface,
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
