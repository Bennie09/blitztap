import 'package:blitztap/models/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../providers/game_provider.dart';
import '../utils/app_colors.dart';
import 'timer_display.dart';
import 'action_buttons.dart';

class PlayerHalf extends StatelessWidget {
  final Player player;
  final bool isSwapped;
  final bool isInverted;
  final VoidCallback? onCheckmateRequested;
  final VoidCallback? onStalemateRequested;
  final VoidCallback? onForfeitRequested;

  const PlayerHalf({
    super.key,
    required this.player,
    required this.isSwapped,
    required this.isInverted,
    this.onCheckmateRequested,
    this.onStalemateRequested,
    this.onForfeitRequested,
  });

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final isActive = player.isActive;
    final isLowTime = gameProvider.isLowTime && isActive;

    Color backgroundColor = isActive ? AppColors.active : AppColors.inactive;
    if (isLowTime && isActive) {
      backgroundColor = AppColors.danger;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      color: backgroundColor,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Only allow tapping if this player is active
            if (gameProvider.gameStatus == GameStatus.ongoing && isActive) {
              HapticFeedback.lightImpact();
              gameProvider.switchTurn();
            }
          },
          splashColor: AppColors.ripple,
          // ignore: deprecated_member_use
          highlightColor: AppColors.ripple.withOpacity(0.3),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Action buttons at top
                ActionButtons(
                  playerNumber: player.playerNumber,
                  isInverted: isInverted,
                  onCheckmatePressed: onCheckmateRequested,
                  onStalematePressed: onStalemateRequested,
                  onForfeitPressed: onForfeitRequested,
                ),
                const Spacer(),
                // Player name
                Text(
                  player.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                // Timer display
                TimerDisplay(
                  timeRemaining: player.timeRemaining,
                  isActive: isActive,
                  isLowTime: isLowTime,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
