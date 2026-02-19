import 'package:flutter/material.dart';
import 'package:hajj_app/helpers/styles.dart';

enum AppPopupType { info, success, warning, error }

class _PopupThemeData {
  final Color accent;
  final IconData icon;
  final String title;

  const _PopupThemeData({
    required this.accent,
    required this.icon,
    required this.title,
  });
}

_PopupThemeData _popupTheme(AppPopupType type) {
  switch (type) {
    case AppPopupType.success:
      return const _PopupThemeData(
        accent: ColorSys.darkBlue,
        icon: Icons.check_circle_rounded,
        title: 'Berhasil',
      );
    case AppPopupType.warning:
      return const _PopupThemeData(
        accent: ColorSys.warning,
        icon: Icons.warning_amber_rounded,
        title: 'Perhatian',
      );
    case AppPopupType.error:
      return const _PopupThemeData(
        accent: ColorSys.error,
        icon: Icons.error_rounded,
        title: 'Terjadi Kesalahan',
      );
    case AppPopupType.info:
      return const _PopupThemeData(
        accent: ColorSys.info,
        icon: Icons.info_rounded,
        title: 'Informasi',
      );
  }
}

Future<void> showAppPopup(
  BuildContext context, {
  required String message,
  AppPopupType type = AppPopupType.info,
  String? title,
  String buttonText = 'OK',
  bool barrierDismissible = true,
  Color? accentOverride,
}) async {
  final popup = _popupTheme(type);
  final accent = accentOverride ?? popup.accent;

  await showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 26),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.12),
                ),
                child: Icon(
                  popup.icon,
                  color: accent,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title ?? popup.title,
                textAlign: TextAlign.center,
                style: textStyle(
                  fontSize: 18,
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textStyle(
                  fontSize: 13,
                  color: ColorSys.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    buttonText,
                    style: textStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<bool> showAppConfirmPopup(
  BuildContext context, {
  required String message,
  AppPopupType type = AppPopupType.warning,
  String? title,
  String confirmText = 'Lanjut',
  String cancelText = 'Batal',
  bool barrierDismissible = true,
  Color? accentOverride,
}) async {
  final popup = _popupTheme(type);
  final accent = accentOverride ?? popup.accent;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 26),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.12),
                ),
                child: Icon(
                  popup.icon,
                  color: accent,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title ?? popup.title,
                textAlign: TextAlign.center,
                style: textStyle(
                  fontSize: 18,
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textStyle(
                  fontSize: 13,
                  color: ColorSys.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        cancelText,
                        style: textStyle(
                          fontSize: 14,
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        confirmText,
                        style: textStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  return result == true;
}

Future<void> showAppPopupFromNavigator(
  NavigatorState navigator, {
  required String message,
  AppPopupType type = AppPopupType.info,
  String? title,
  String buttonText = 'OK',
  bool barrierDismissible = true,
  Color? accentOverride,
}) {
  return showAppPopup(
    navigator.context,
    message: message,
    type: type,
    title: title,
    buttonText: buttonText,
    barrierDismissible: barrierDismissible,
    accentOverride: accentOverride,
  );
}
