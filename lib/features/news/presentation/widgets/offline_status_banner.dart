import 'package:flutter/material.dart'; 
import 'package:traker_task/core/constants/app_colors.dart';

class OfflineStatusBanner extends StatelessWidget {
  final VoidCallback? onRetry;

  const OfflineStatusBanner({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.offlineBannerDarkBg : AppColors.offlineBannerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? AppColors.offlineDarkText : AppColors.offlineText)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 20,
            color: isDark ? AppColors.offlineDarkText : AppColors.offlineText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Offline Mode: Viewing cached articles',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? AppColors.offlineDarkText : AppColors.offlineText,
              ),
            ),
          ),
          if (onRetry != null)
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isDark
                          ? AppColors.offlineDarkText
                          : AppColors.offlineText)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.offlineDarkText
                        : AppColors.offlineText,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
