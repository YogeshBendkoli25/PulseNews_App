import 'package:flutter/material.dart';

class SplashLoader extends StatelessWidget {
  final String version;

  const SplashLoader({
    super.key,
    this.version = 'v1.0.0',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          version,
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.35),
          ),
        ),
      ],
    );
  }
}
