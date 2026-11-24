import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import '../design/theme.dart';

class StatusInfo {
  final String name;
  final Color color;
  const StatusInfo({required this.name, required this.color});
}

Color hexToColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  return Color(int.parse('FF$cleaned', radix: 16));
}

/// Маленькая цветная пилюля с числом — как на главном экране.
class StatusCountPill extends StatelessWidget {
  final int count;
  final StatusInfo info;
  const StatusCountPill({
    super.key,
    required this.count,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: info.color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$count',
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: info.color,
        ),
      ),
    );
  }
}

/// Ряд пилюль для набора сотрудников.
/// Показывает только статусы, где count > 0.
class StatusCountRow extends StatelessWidget {
  final List<int> statusIds; // сотрудники в порядке, каком нужно
  final Map<int, StatusInfo> statuses;
  final double spacing;
  const StatusCountRow({
    super.key,
    required this.statusIds,
    required this.statuses,
    this.spacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    final counts = <int, int>{};
    for (final id in statusIds) {
      counts[id] = (counts[id] ?? 0) + 1;
    }
    final sortedIds = statuses.keys.toList()..sort();
    final visible = [
      for (final sid in sortedIds)
        if ((counts[sid] ?? 0) > 0) sid,
    ];
    if (visible.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: spacing,
      runSpacing: 6,
      children: [
        for (final sid in visible)
          StatusCountPill(count: counts[sid]!, info: statuses[sid]!),
      ],
    );
  }
}