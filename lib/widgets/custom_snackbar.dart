import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    required SnackBarType type,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case SnackBarType.error:
        backgroundColor = const Color(0xFFE53E3E);
        textColor = Colors.white;
        icon = Icons.error_outline;
        break;
      case SnackBarType.warning:
        backgroundColor = const Color(0xFFED8936);
        textColor = Colors.white;
        icon = Icons.warning_outlined;
        break;
      case SnackBarType.success:
        backgroundColor = const Color(0xFF38A169);
        textColor = Colors.white;
        icon = Icons.check_circle_outline;
        break;
      case SnackBarType.info:
        backgroundColor = const Color(0xFF3182CE);
        textColor = Colors.white;
        icon = Icons.info_outline;
        break;
    }

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: textColor,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              onPressed: onAction,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showError(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.error,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.warning,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(context: context, message: message, type: SnackBarType.success);
  }

  static void showInfo(BuildContext context, String message) {
    show(context: context, message: message, type: SnackBarType.info);
  }
}

enum SnackBarType { error, warning, success, info }
