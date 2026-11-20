import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_style_app/widgets/content_width.dart';
import 'package:url_launcher/url_launcher.dart';
import '../design/theme.dart';
import '../data/repository.dart';
import '../models/employee.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _repo = Repository();
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  bool _loading = false;
  List<Employee> _results = [];
  Map<int, String> _units = {};
  Map<int, String> _dolj = {};
  Map<int, _StatusInfo> _statuses = {};

  @override
  void initState() {
    super.initState();
    _preloadDictionaries();
  }

  Future<void> _preloadDictionaries() async {
    final results = await Future.wait([
      _repo.loadPodrazdeleniya(),
      _repo.loadDoljnosti(),
      _repo.loadStatusy(),
    ]);
    if (!mounted) return;
    setState(() {
      _units = {
        for (final u in results[0])
          u['id'] as int: u['name'] as String
      };
      _dolj = {
        for (final d in results[1])
          d['id'] as int: d['name'] as String
      };
      _statuses = {
      for (final s in results[2])
        s['id'] as int: _StatusInfo(
          name: s['name'] as String,
          color: _hexToColor(s['color'] as String),
        )
    };
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(value.trim());
    });
  }

  Future<void> _runSearch(String query) async {
    if (query.length < 2) {
      setState(() {
        _query = query;
        _results = [];
      });
      return;
    }
    setState(() {
      _query = query;
      _loading = true;
    });
    try {
      final res = await _repo.searchEmployees(query);
      if (!mounted) return;
      setState(() {
        _results = res;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка поиска: $e')),
      );
    }
  }

  Future<void> _call(String? tel) async {
    if (tel == null || tel.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: tel);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: SupabaseColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: SupabaseColors.emerald),
        title: Text(
          'Поиск сотрудника',
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: ContentWidth(
              maxWidth: 800,
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                autofocus: true,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: SupabaseColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'Введите фамилию (минимум 2 символа)...',
                  prefixIcon: Icon(Icons.search,
                      size: 20, color: SupabaseColors.textSecondary),
                ),
              ),
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: SupabaseColors.emerald),
            )
          else if (_query.length < 2)
            _hint('Введите минимум 2 символа для поиска')
          else if (_results.isEmpty)
            _hint('Ничего не найдено по запросу «$_query»')
          else
            Expanded(
              child: ContentWidth(
                maxWidth: 800,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: _results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final e = _results[i];
                    return _SearchResultTile(
                      employee: e,
                      unitName: _units[e.podr] ?? '—',
                      doljnost: _dolj[e.dolj] ?? '—',
                      status: _statuses[e.status],
                      onCall: () => _call(e.tel),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _hint(String text) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: SupabaseColors.textSecondary,
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final Employee employee;
  final String unitName;
  final String doljnost;
  final _StatusInfo? status;
  final VoidCallback onCall;

  const _SearchResultTile({
    required this.employee,
    required this.unitName,
    required this.doljnost,
    required this.status,
    required this.onCall,
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
                // Должность · Подразделение — в поиске это важно
                Text(
                  '$doljnost · $unitName',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: SupabaseColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                if (status != null && status!.name.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                          color: statusColor.withValues(alpha: 0.4)),
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
          IconButton(
            onPressed:
                employee.tel != null && employee.tel!.isNotEmpty
                    ? onCall
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

class _StatusInfo {
  final String name;
  final Color color;
  _StatusInfo({required this.name, required this.color});
}

Color _hexToColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  return Color(int.parse('FF$cleaned', radix: 16));
}