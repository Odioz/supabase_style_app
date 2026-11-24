import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../design/theme.dart';
import '../utils/platform.dart';

class PhoneAction extends StatelessWidget {
  final String? tel;
  const PhoneAction({super.key, required this.tel});

  bool get _hasPhone => tel != null && tel!.isNotEmpty;

  Future<void> _call() async {
    if (!_hasPhone) return;
    final uri = Uri(scheme: 'tel', path: tel);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _copy(BuildContext context) async {
    if (!_hasPhone) return;
    await Clipboard.setData(ClipboardData(text: tel!));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Номер скопирован: $tel',
          style: GoogleFonts.inter(fontSize: 14, color: SupabaseColors.textPrimary),
        ),
        backgroundColor: SupabaseColors.surface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPhone) {
      // Нет номера — показываем неактивную иконку, как раньше
      return IconButton(
        onPressed: null,
        icon: const Icon(Icons.phone_outlined),
        color: SupabaseColors.textSecondary,
        tooltip: 'Номер не указан',
      );
    }

    if (isMobileDevice) {
      // Мобильный: только иконка звонка
      return IconButton(
        onPressed: _call,
        icon: const Icon(Icons.phone_outlined),
        color: SupabaseColors.emerald,
        tooltip: 'Позвонить',
      );
    }

    // Десктоп/веб: номер текстом + копирование
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatPhone(tel!),
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: SupabaseColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: () => _copy(context),
          icon: const Icon(Icons.copy_outlined, size: 18),
          color: SupabaseColors.emerald,
          tooltip: 'Скопировать номер',
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
String formatPhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 11 && digits.startsWith('7')) {
    return '+7 ${digits.substring(1, 4)} ${digits.substring(4, 7)}-${digits.substring(7, 9)}-${digits.substring(9, 11)}';
  }
  if (digits.length == 11 && digits.startsWith('8')) {
    final d = '7${digits.substring(1)}';
    return '+7 ${d.substring(1, 4)} ${d.substring(4, 7)}-${d.substring(7, 9)}-${d.substring(9, 11)}';
  }
  return raw; // fallback — как есть
}