import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

enum ConfirmationType {
  checkmate,
  stalemate,
  forfeit,
}

class ConfirmationOverlay extends StatefulWidget {
  final ConfirmationType type;
  final int playerNumber;
  final String playerName; // Name of the player who clicked the button
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool showOnTop; // If true, shows on top half (player 2), else bottom (player 1)

  const ConfirmationOverlay({
    super.key,
    required this.type,
    required this.playerNumber,
    required this.playerName,
    required this.onConfirm,
    required this.onCancel,
    required this.showOnTop,
  });

  @override
  State<ConfirmationOverlay> createState() => _ConfirmationOverlayState();
}

class _ConfirmationOverlayState extends State<ConfirmationOverlay> {
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    // Auto-close after 5 seconds
    _autoCloseTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        widget.onCancel();
      }
    });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  String _getTitle() {
    switch (widget.type) {
      case ConfirmationType.checkmate:
        return 'Confirm Checkmate';
      case ConfirmationType.stalemate:
        return 'Confirm Stalemate';
      case ConfirmationType.forfeit:
        return 'Confirm Forfeit';
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ConfirmationType.checkmate:
        return Icons.emoji_events;
      case ConfirmationType.stalemate:
        return Icons.handshake;
      case ConfirmationType.forfeit:
        return Icons.flag;
    }
  }

  Color _getColor() {
    switch (widget.type) {
      case ConfirmationType.checkmate:
        return AppColors.active;
      case ConfirmationType.stalemate:
        return AppColors.textSecondary;
      case ConfirmationType.forfeit:
        return AppColors.danger;
    }
  }

  String _getSubtitle() {
    switch (widget.type) {
      case ConfirmationType.checkmate:
        return 'This declares ${widget.playerName} the WINNER';
      case ConfirmationType.stalemate:
        return 'This declares the game a draw';
      case ConfirmationType.forfeit:
        return 'Are you sure you want to forfeit';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onCancel, // Close on outside tap
      child: Material(
        color: Colors.black.withOpacity(0.5),
        child: Align(
          alignment: widget.showOnTop ? Alignment.topCenter : Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // Prevent taps on container from closing
            child: Transform.rotate(
              angle: widget.showOnTop ? 3.14159 : 0.0, // Rotate 180 degrees when on top
              child: Container(
                margin: EdgeInsets.only(
                  top: widget.showOnTop ? 80 : 0,
                  bottom: widget.showOnTop ? 0 : 80,
                  left: 24,
                  right: 24,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _getColor(), width: 2),
                ),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getIcon(), size: 48, color: _getColor()),
                  const SizedBox(height: 16),
                  Text(
                    _getTitle(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getColor(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getSubtitle(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _autoCloseTimer?.cancel();
                          widget.onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getColor(),
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Confirm'),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () {
                          _autoCloseTimer?.cancel();
                          widget.onCancel();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: const BorderSide(color: AppColors.textSecondary),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }
}
