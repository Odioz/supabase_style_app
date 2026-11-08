import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee.dart';

class Repository {
  final _db = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> loadPodrazdeleniya() async {
    final data = await _db.from('podrazdeleniya').select().order('id');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> loadDoljnosti() async {
    final data = await _db.from('doljnosti').select().order('id');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> loadStatusy() async {
    final data = await _db.from('statusy').select().order('id');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Employee>> loadEmployees(int podr) async {
    final data = await _db
        .from('personal')
        .select()
        .eq('podr', podr)
        .order('fio');
    return (data as List).map((e) => Employee.fromMap(e)).toList();
  }
}