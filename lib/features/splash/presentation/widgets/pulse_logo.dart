import 'package:flutter/material.dart';
import 'package:traker_task/core/constants/app_colors.dart';

class PulseLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  final bool showGlow;
  final Color glowColor;

  const PulseLogo({
    super.key,
    this.size = 96,
    this.borderRadius = 24,
    this.showGlow = false,
    this.glowColor = const Color(0xFF007AFF),
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'assets/images/app_logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.primaryBlue,
            child: Icon(
              Icons.bolt_rounded,
              color: Colors.white,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );

    if (!showGlow) return imageWidget;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size * 1.3,
          height: size * 1.3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius * 1.4),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.4),
                blurRadius: 36,
                spreadRadius: 6,
              ),
            ],
          ),
        ),
        imageWidget,
      ],
    );
  }
}
