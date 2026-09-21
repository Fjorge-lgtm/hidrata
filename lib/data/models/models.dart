import 'package:isar/isar.dart';

part 'models.g.dart';

@collection
class UserModel {
  Id id = Isar.autoIncrement;

  late String name;
  int age = 0;
  bool biometricEnabled = false;
}

@collection
class MedicineModel {
  Id id = Isar.autoIncrement;

  late String name;
  String dosage = '';
  List<DateTime> scheduleTimes = [];
  bool isActive = true;

  @Index()
  int? userId;
}

@collection
class AlarmModel {
  Id id = Isar.autoIncrement;

  late String label;
  late int hour;
  late int minute;

  /// Dias da semana em que o alarme repete (1=segunda .. 7=domingo,
  /// convenção de [DateTime.weekday]). Vazio significa alarme único.
  List<int> repeatDays = [];
  bool isEnabled = true;

  @Index()
  int? userId;
}
