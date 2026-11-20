import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_style_app/widgets/content_width.dart';
import 'package:url_launcher/url_launcher.dart';
import '../design/theme.dart';
import '../data/repository.dart';
import '../models/employee.dart';

class UnitScreen extends StatefulWidget {
  final int unitId;
  final String unitName;
  const UnitScreen({super.key, required this.unitId, required this.unitName});

  @override
  State<UnitScreen> createState() => _UnitScreenState();
}

class _UnitScreenState extends State<UnitScreen> {
  final _repo = Repository();
  late Future<_UnitData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadAll();
  }

  Future<_UnitData> _loadAll() async {
    final results = await Future.wait([
      _repo.loadDoljnosti(),
      _repo.loadStatusy(),
      _repo.loadEmployees(widget.unitId),
    ]);
    final doljMap = {
      for (final d in results[0] as List<Map<String, dynamic>>)
        d['id'] as int: d['name'] as String
    };
    final statusMap = {
      for (final s in results[1] as List<Map<String, dynamic>>)
        s['id'] as int: _StatusInfo(
          name: s['name'] as String,
          color: _hexToColor(s['color'] as String),
        )
    };
    return _UnitData(
      employees: results[2] as List<Employee>,
      doljMap: doljMap,
      statusMap: statusMap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: SupabaseColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: SupabaseColors.emerald),
        title: Text(
          widget.unitName,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: SupabaseColors.emerald,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: SupabaseColors.border),
        ),
      ),
      body: FutureBuilder<_UnitData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: SupabaseColors.emerald),
            );
          }
          if (snapshot.hasError) {
                   return Padding(
                      padding: const EdgeInsets.all(20),
                      child: SupabaseAlert(
                        message: 'Ошибка: ${snapshot.error}',
                        variant: SupabaseAlertVariant.error,
                        ),
                      );
                  }
          final data = snapshot.data!;
          if (data.employees.isEmpty) {
            return const Center(
              child: Text(
                'Нет данных по личному составу',
                style: TextStyle(color: SupabaseColors.textSecondary),
              ),
            );
          }
          return ContentWidth(
            maxWidth: 800,
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: data.employees.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final e = data.employees[i];
                return _EmployeeTile(
                  employee: e,
                  doljnost: data.doljMap[e.dolj] ?? '—',
                  status: data.statusMap[e.status],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _UnitData {
  final List<Employee> employees;
  final Map<int, String> doljMap;
  final Map<int, _StatusInfo> statusMap;
  _UnitData({
    required this.employees,
    required this.doljMap,
    required this.statusMap,
  });
}

class _StatusInfo {
  final String name;
  final Color color;
  _StatusInfo({required this.name, required this.color});
}

Color _hexToColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  return Color(int.parse('FF$cleaned', radix: 16));
}

class _EmployeeTile extends StatelessWidget {
  final Employee employee;
  final String doljnost;
  final _StatusInfo? status;

  const _EmployeeTile({
    required this.employee,
    required this.doljnost,
    required this.status,
  });

  Future<void> _call() async {
    if (employee.tel == null || employee.tel!.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: employee.tel);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = status?.color ?? SupabaseColors.textSecondary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SupabaseColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: SupabaseColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Аватар с инициалами
          // Container(
          //   width: 44,
          //   height: 44,
          //   decoration: BoxDecoration(
          //     color: SupabaseColors.surfaceRaised,
          //     borderRadius: BorderRadius.circular(10),
          //   ),
          //   alignment: Alignment.center,
          //   child: Text(
          //     _initials(employee.fio),
          //     style: GoogleFonts.inter(
          //       fontSize: 14,
          //       fontWeight: FontWeight.w600,
          //       color: SupabaseColors.textPrimary,
          //     ),
          //   ),
          // ),
          //const SizedBox(width: 16),
          // ФИО + должность
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.fio,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: SupabaseColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doljnost,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: SupabaseColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                // Статус-пилюля
                if (status != null && status!.name.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(9999),
                      border:
                          Border.all(color: statusColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      status!.name,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Кнопка звонка
          IconButton(
            onPressed: employee.tel != null && employee.tel!.isNotEmpty
                ? _call
                : null,
            icon: const Icon(Icons.phone_outlined),
            color: SupabaseColors.emerald,
            tooltip: 'Позвонить',
          ),
        ],
      ),
    );
  }

}