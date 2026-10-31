import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// --- Определение дизайн-токенов Supabase ---
class SupabaseColors {
  static const Color canvas = Color(0xFF171717);
  static const Color surface = Color(0xFF1C1C1C);
  static const Color surfaceRaised = Color(0xFF272727);
  static const Color emerald = Color(0xFF3ECF8E);
  static const Color emeraldLink = Color(0xFF00C573);
  static const Color textPrimary = Color(0xFFEDEDED);
  static const Color textSecondary = Color(0xFFA1A1A1);
  static const Color border = Color(0xFF2E2E2E);
    // --- Семантические цвета ---
  // Error / Destructive (Radix Red)
  static const Color error = Color(0xFFE5484D);
  static const Color errorSurface = Color(0xFF3B1219);
  static const Color onError = Color(0xFFFFD1D6);

  // Warning (Radix Amber)
  static const Color warning = Color(0xFFFFB224);
  static const Color warningSurface = Color(0xFF2F1E00);
  static const Color onWarning = Color(0xFFFFE7B3);

  // Success (совпадает с фирменным зелёным)
  static const Color success = Color(0xFF3ECF8E);
  static const Color successSurface = Color(0xFF0F291E);
  static const Color onSuccess = Color(0xFFC9F5DE);

  // Info (Radix Blue)
  static const Color info = Color(0xFF3E9EE5);
  static const Color infoSurface = Color(0xFF0D1E2E);
  static const Color onInfo = Color(0xFFC9E2F5);
}
enum SupabaseAlertVariant { error, warning, success, info }

class SupabaseAlert extends StatelessWidget {
  final String message;
  final SupabaseAlertVariant variant;
  final VoidCallback? onDismiss;

  const SupabaseAlert({
    super.key,
    required this.message,
    this.variant = SupabaseAlertVariant.error,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(variant);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border(
          left: BorderSide(color: colors.accent, width: 3),
        ),
      ),
      child: Row(
        children: [
          Icon(colors.icon, size: 18, color: colors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: colors.text,
                height: 1.4,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 12),
            InkWell(
              onTap: onDismiss,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(Icons.close, size: 16, color: colors.text),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _AlertColors _resolveColors(SupabaseAlertVariant variant) {
    switch (variant) {
      case SupabaseAlertVariant.error:
        return _AlertColors(
          accent: SupabaseColors.error,
          surface: SupabaseColors.errorSurface,
          text: SupabaseColors.onError,
          icon: Icons.error_outline,
        );
      case SupabaseAlertVariant.warning:
        return _AlertColors(
          accent: SupabaseColors.warning,
          surface: SupabaseColors.warningSurface,
          text: SupabaseColors.onWarning,
          icon: Icons.warning_amber_outlined,
        );
      case SupabaseAlertVariant.success:
        return _AlertColors(
          accent: SupabaseColors.success,
          surface: SupabaseColors.successSurface,
          text: SupabaseColors.onSuccess,
          icon: Icons.check_circle_outline,
        );
      case SupabaseAlertVariant.info:
        return _AlertColors(
          accent: SupabaseColors.info,
          surface: SupabaseColors.infoSurface,
          text: SupabaseColors.onInfo,
          icon: Icons.info_outline,
        );
    }
  }
}

class _AlertColors {
  final Color accent;
  final Color surface;
  final Color text;
  final IconData icon;
  const _AlertColors({
    required this.accent,
    required this.surface,
    required this.text,
    required this.icon,
  });
}

class SupabaseTheme {
  static ThemeData get dark {
    final baseTextTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SupabaseColors.canvas,
      primaryColor: SupabaseColors.emerald,
      colorScheme: const ColorScheme.dark(
        primary: SupabaseColors.emerald,
        surface: SupabaseColors.surface,
        onSurface: SupabaseColors.textPrimary,
          // Семантические состояния:
        error: SupabaseColors.error,
        onError: SupabaseColors.onError,
        errorContainer: SupabaseColors.errorSurface,
        onErrorContainer: SupabaseColors.onError,
      ),
      textTheme: TextTheme(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: 56,
          fontWeight: FontWeight.w700,
          color: SupabaseColors.textPrimary,
          height: 1.1,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 15,
          color: SupabaseColors.textSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SupabaseColors.surfaceRaised,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: SupabaseColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: SupabaseColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: SupabaseColors.emerald, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: SupabaseColors.textSecondary),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: SupabaseColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: SupabaseColors.error, width: 1.5),
        ),
        errorStyle: GoogleFonts.inter(
          fontSize: 12,
          color: SupabaseColors.error,
        ),
      ),
    );
  }
}
