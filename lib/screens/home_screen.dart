import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/theme.dart';
import '../data/repository.dart';
import 'unit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = Repository();
  late Future<List<Map<String, dynamic>>> _unitsFuture;

  @override
  void initState() {
    super.initState();
    _unitsFuture = _repo.loadPodrazdeleniya();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Image.asset('assets/logo.png', fit: BoxFit.contain ),
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
            onPressed: () => Scaffold.of(context).openEndDrawer(),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
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
              FutureBuilder(
                future: _unitsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: SupabaseColors.emerald,
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text(
                      'Ошибка загрузки: ${snapshot.error}',
                      style: const TextStyle(color: SupabaseColors.error),
                    );
                  }
                  final units = snapshot.data ?? [];
                  return _buildUnitGrid(units);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitGrid(List<Map<String, dynamic>> units) {
    // Адаптивная сетка: 1 колонка на телефоне, 2 на планшете, 3 на десктопе
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width < 600 ? 1 : (width < 1000 ? 2 : 3);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 84,
          ),
          itemCount: units.length,
          itemBuilder: (context, i) {
            final unit = units[i];
            return _UnitCard(
              id: unit['id'] as int,
              name: unit['name'] as String,
            );
          },
        );
      },
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
              padding: const EdgeInsets.all(20),
              child: Text(
                'МЕНЮ',
                style: GoogleFonts.sourceCodePro(
                  fontSize: 11,
                  color: SupabaseColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            // Здесь позже можно добавить пункты меню
          ],
        ),
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final int id;
  final String name;
  const _UnitCard({required this.id, required this.name});

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: SupabaseColors.border),
          ),
          child: Row(
            children: [
              // Container(
              //   width: 44,
              //   height: 44,
              //   decoration: BoxDecoration(
              //     color: SupabaseColors.emerald.withValues(alpha: 0.15),
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //   child: const Icon(Icons.home_work_outlined,
              //       color: SupabaseColors.emerald, size: 22),
              // ),
              // const SizedBox(width: 16),
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
        ),
      ),
    );
  }
}