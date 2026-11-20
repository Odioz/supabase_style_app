import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee.dart';

class Repository {
   late List<Map<String, dynamic>>? _podrzCache;
  late List<Map<String, dynamic>>? _doljCache;
  late List<Map<String, dynamic>>? _statusCache;

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
}