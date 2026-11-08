class Employee {
  final int id;
  final int podr;
  final String fio;
  final int dolj;
  final String? tel;
  final int status;

  const Employee({
    required this.id,
    required this.podr,
    required this.fio,
    required this.dolj,
    this.tel,
    required this.status,
  });

  factory Employee.fromMap(Map<String, dynamic> m) => Employee(
        id: m['id'] as int,
        podr: m['podr'] as int,
        fio: m['fio'] as String,
        dolj: m['dolj'] as int,
        tel: m['tel'] as String?,
        status: m['status'] as int,
      );
}
class Podrazdelenie {
  final int id;
  final String name;

  const Podrazdelenie({
    required this.id,
    required this.name,
  });

  factory Podrazdelenie.fromMap(Map<String, dynamic> m) => Podrazdelenie(
        id: m['id'] as int,
        name: m['name'] as String,
      );
}

class Doljnost {
  final int id;
  final String name;

  const Doljnost({
    required this.id,
    required this.name,
  });

  factory Doljnost.fromMap(Map<String, dynamic> m) => Doljnost(
        id: m['id'] as int,
        name: m['name'] as String,
      );
}

class Status {
  final int id;
  final String name;
  final String? color;

  const Status({
    required this.id,
    required this.name,
    this.color,
  });

  factory Status.fromMap(Map<String, dynamic> m) => Status(
        id: m['id'] as int,
        name: m['name'] as String,
        color: m['color'] as String?,
      );
}