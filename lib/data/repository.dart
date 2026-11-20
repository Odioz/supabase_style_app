import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee.dart';

class Repository {
  List<Map<String, dynamic>>? _podrzCache;
  List<Map<String, dynamic>>? _doljCache;
  List<Map<String, dynamic>>? _statusCache;

  final _db = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> loadPodrazdeleniya() async {
    if (_podrzCache != null) return _podrzCache!;
    final data = await _db.from('podrazdeleniya').select().order('id', ascending: true );
    _podrzCache = List<Map<String, dynamic>>.from(data);
    return _podrzCache!;
  }

  Future<List<Map<String, dynamic>>> loadDoljnosti() async {
    if (_doljCache != null) return _doljCache!;
    final data = await _db.from('doljnosti').select().order('id', ascending: true );
    _doljCache = List<Map<String, dynamic>>.from(data);
    return _doljCache!;
  }

  Future<List<Map<String, dynamic>>> loadStatusy() async {
    if (_statusCache != null) return _statusCache!;
    final data = await _db.from('statusy').select().order('id', ascending: true );
    _statusCache = List<Map<String, dynamic>>.from(data);
    return _statusCache!;
  }

  Future<List<Employee>> loadEmployees(int podr) async {
    final data = await _db
        .from('personal')
        .select()
        .eq('podr', podr)
        .order('id',  ascending: true );
    return (data as List).map((e) => Employee.fromMap(e)).toList();
  }

  // Счётчики статусов по каждому подразделению: { podr: { statusId: count } }
  Future<Map<int, Map<int, int>>> loadStatusCounts() async {
   final data = await _db.from('personal').select('podr, status');
   final result = <int, Map<int, int>>{};
   for (final row in (data as List)) {
     final podr = row['podr'] as int;
     final status = row['status'] as int;
     result.putIfAbsent(podr, () => {});
     result[podr]![status] = (result[podr]![status] ?? 0) + 1;
   }
   return result;
 }

  // Поиск сотрудников по ФИО по всему отряду
  Future<List<Employee>> searchEmployees(String query) async {
    final data = await _db
      .from('personal')
      .select()
      .ilike('fio', '%$query%')
      .order('fio')
      .limit(50);
  return (data as List).map((e) => Employee.fromMap(e)).toList();
 }
}