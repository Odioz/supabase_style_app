import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_style_app/widgets/content_width.dart';
import '../design/theme.dart';
import '../widgets/status_count.dart';
import '../data/repository.dart';
import '../models/employee.dart';
import '../widgets/phone_action.dart';

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
        s['id'] as int: StatusInfo(
          name: s['name'] as String,
          color: hexToColor(s['color'] as String),
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
          if (widget.unitId == 2) {
            return _buildKaraulList(data);
          }
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

Widget _buildKaraulList(_UnitData data) {
  // 0 = "ПЧ-1 (все)" — сотрудники без привязки к караулу
  final groups = <int, List<Employee>>{
    0: [],
    1: [],
    2: [],
    3: [],
    4: [],
  };
  for (final e in data.employees) {
    // Всё, что не 1..4, кладём в "ПЧ-1 (все)"
    if (e.karaul >= 1 && e.karaul <= 4) {
      groups[e.karaul]!.add(e);
    } else {
      groups[0]!.add(e);
    }
  }

  final labels = {
    0: 'ПЧ-1 (все)',
    1: '1 караул',
    2: '2 караул',
    3: '3 караул',
    4: '4 караул',
  };

  return ContentWidth(
    maxWidth: 800,
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final k in [0, 1, 2, 3, 4])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _KaraulSection(
              title: labels[k]!,
              employees: groups[k]!,
              doljMap: data.doljMap,
              statusMap: data.statusMap,
              //initiallyExpanded: k == 0, // первый раскрыт по умолчанию
            ),
          ),
      ],
    ),
  );
}

class _KaraulSection extends StatelessWidget {
  final String title;
  final List<Employee> employees;
  final Map<int, String> doljMap;
  final Map<int, StatusInfo> statusMap;
  final bool initiallyExpanded;

  const _KaraulSection({
    required this.title,
    required this.employees,
    required this.doljMap,
    required this.statusMap,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SupabaseColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: SupabaseColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // Убираем стандартные разделители ExpansionTile
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: SupabaseColors.emerald,
          collapsedIconColor: SupabaseColors.textSecondary,
          title: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisSize: MainAxisSize.min,
  children: [
    Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: SupabaseColors.textPrimary,
            ),
          ),
        ),
        // Общий счётчик — как раньше
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: SupabaseColors.emerald.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: SupabaseColors.emerald.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            '${employees.length}',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: SupabaseColors.emerald,
            ),
          ),
        ),
      ],
    ),
    // Счётчики статусов — новая строка
    if (employees.isNotEmpty) ...[
      const SizedBox(height: 6),
      StatusCountRow(
        statusIds: [for (final e in employees) e.status],
        statuses: statusMap,
      ),
    ],
  ],
),
          children: [
            if (employees.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Нет сотрудников',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: SupabaseColors.textSecondary,
                  ),
                ),
              )
            else
              for (var i = 0; i < employees.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _EmployeeTile(
                  employee: employees[i],
                  doljnost: doljMap[employees[i].dolj] ?? '—',
                  status: statusMap[employees[i].status],
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class _UnitData {
  final List<Employee> employees;
  final Map<int, String> doljMap;
  final Map<int, StatusInfo> statusMap;
  _UnitData({
    required this.employees,
    required this.doljMap,
    required this.statusMap,
  });
}

class _EmployeeTile extends StatelessWidget {
  final Employee employee;
  final String doljnost;
  final StatusInfo? status;

  const _EmployeeTile({
    required this.employee,
    required this.doljnost,
    required this.status,
  });

  
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
          PhoneAction(tel: employee.tel),
        ],
      ),
    );
  }

}