import 'package:flutter/material.dart';

void showAnimatedConnectivitySnackBar(
  BuildContext context, {
  required bool isOnline,
}) {
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      key: ValueKey<String>(
        'connectivity_snackbar_${isOnline ? "online" : "offline"}',
      ),
      duration: const Duration(milliseconds: 2500),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF282828),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      dismissDirection: DismissDirection.horizontal,
      content: AnimatedConnectivitySnackBarContent(isOnline: isOnline),
    ),
  );
}

class AnimatedConnectivitySnackBarContent extends StatelessWidget {
  final bool isOnline;

  const AnimatedConnectivitySnackBarContent({
    super.key,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
          color: isOnline ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
          size: 20,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            isOnline ? 'You are online' : 'You are offline',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ],
    );
  }
}
