import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';

class CountdownOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const CountdownOverlay({super.key, required this.onComplete});

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _count = 3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _animateCount();
    });
  }

  void _animateCount() {
    if (_count > 0) {
      HapticFeedback.mediumImpact();
      _controller.forward(from: 0.0).then((_) {
        _controller.reverse();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() {
              _count--;
            });
            if (_count > 0) {
              _animateCount();
            } else {
              // Show "GO!" with smooth animation
              HapticFeedback.heavyImpact();
              _controller.forward(from: 0.0).then((_) {
                // Keep it at full scale, then fade out smoothly
                Future.delayed(const Duration(milliseconds: 150), () {
                  if (mounted) {
                    widget.onComplete();
                  }
                });
              });
            }
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // ignore: deprecated_member_use
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // For "GO!", keep it at full scale without reverse animation
            final isGo = _count == 0;
            final scale = isGo
                ? 1.0 + (_controller.value * 0.3) // Only scale up for GO
                : (_controller.value == 0
                    ? 0.5
                    : 1.0 + (_controller.value * 0.3));
            final opacity = isGo
                ? 1.0 // Keep GO fully visible
                : (_controller.value == 0 ? 0.3 : 1.0);
            
            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Text(
                  _count > 0 ? '$_count' : 'GO!',
                  style: TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    color: _count > 0 ? AppColors.active : AppColors.danger,
                    shadows: [
                      Shadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
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
