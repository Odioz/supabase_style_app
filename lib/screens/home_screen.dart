import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/theme.dart';
import '../data/repository.dart';
import '../widgets/content_width.dart';
import 'unit_screen.dart';
import 'search_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = Repository();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<_HomeData> _homeFuture;

  @override
  void initState() {
    super.initState();
    _homeFuture = _loadHome();
  }

  Future<_HomeData> _loadHome() async {
    final results = await Future.wait([
      _repo.loadPodrazdeleniya(),
      _repo.loadStatusy(),
      _repo.loadStatusCounts(),
    ]);
    final statuses = {
      for (final s in results[1] as List<Map<String, dynamic>>)
        s['id'] as int: _StatusInfo(
          name: s['name'] as String,
          color: _hexToColor(s['color'] as String),
        )
    };
    return _HomeData(
      units: results[0] as List<Map<String, dynamic>>,
      statuses: statuses,
      counts: results[2] as Map<int, Map<int, int>>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: SupabaseColors.surface,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: SupabaseColors.emerald,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset('assets/logo.png', fit: BoxFit.contain),
            ),
            const SizedBox(width: 12),
            Text(
              'Пожарка',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: SupabaseColors.emerald,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            icon: const Icon(Icons.menu, color: SupabaseColors.textPrimary),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: SupabaseColors.border),
        ),
      ),
      endDrawer: _buildDrawer(),
      body: FutureBuilder<_HomeData>(
        future: _homeFuture,
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
                message: 'Ошибка загрузки: ${snapshot.error}',
                variant: SupabaseAlertVariant.error,
              ),
            );
          }
          return _buildBody(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildBody(_HomeData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ContentWidth(
        maxWidth: 1100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ПОДРАЗДЕЛЕНИЯ',
              style: GoogleFonts.sourceCodePro(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: SupabaseColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount =
                    width < 600 ? 1 : (width < 1000 ? 2 : 3);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 120,
                  ),
                  itemCount: data.units.length,
                  itemBuilder: (context, i) {
                    final unit = data.units[i];
                    final id = unit['id'] as int;
                    return _UnitCard(
                      id: id,
                      name: unit['name'] as String,
                      statuses: data.statuses,
                      counts: data.counts[id] ?? const {},
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: SupabaseColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text(
                'МЕНЮ',
                style: GoogleFonts.sourceCodePro(
                  fontSize: 11,
                  color: SupabaseColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.search, color: SupabaseColors.emerald),
              title: Text(
                'Поиск сотрудника',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: SupabaseColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop(); // закрыть drawer
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SearchScreen(),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeData {
  final List<Map<String, dynamic>> units;
  final Map<int, _StatusInfo> statuses;
  final Map<int, Map<int, int>> counts;
  _HomeData({
    required this.units,
    required this.statuses,
    required this.counts,
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

class _UnitCard extends StatelessWidget {
  final int id;
  final String name;
  final Map<int, _StatusInfo> statuses;
  final Map<int, int> counts;

  const _UnitCard({
    required this.id,
    required this.name,
    required this.statuses,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    // Сортируем статусы по id, чтобы порядок был стабильным
    final sortedIds = statuses.keys.toList()..sort();
    final total = counts.values.fold<int>(0, (a, b) => a + b);

    return Material(
      color: SupabaseColors.surface,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => UnitScreen(unitId: id, unitName: name),
          ));
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: SupabaseColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: SupabaseColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: SupabaseColors.textSecondary),
                ],
              ),
              const SizedBox(height: 8),
              // Счётчики статусов: только те, где count > 0
              if (total == 0)
                Text(
                  'нет данных',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: SupabaseColors.textSecondary,
                  ),
                )
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final sid in sortedIds)
                      if ((counts[sid] ?? 0) > 0)
                        _StatusCount(
                          count: counts[sid]!,
                          info: statuses[sid]!,
                        ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCount extends StatelessWidget {
  final int count;
  final _StatusInfo info;
  const _StatusCount({required this.count, required this.info});

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