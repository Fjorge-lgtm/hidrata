import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/models.dart';

class IsarService {
  static Isar? _isar;

  Future<void> init() async {
    if (_isar != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [UserModelSchema, MedicineModelSchema, AlarmModelSchema],
      directory: dir.path,
    );
  }

  Isar get _db {
    final isar = _isar;
    if (isar == null) {
      throw StateError('IsarService.init() must be called before use.');
    }
    return isar;
  }

  Future<UserModel?> getUser() async {
    return _db.userModels.where().findFirst();
  }

  Future<UserModel?> getUserById(int id) async {
    return _db.userModels.get(id);
  }

  Future<int> saveUser(UserModel user) async {
    return _db.writeTxn(() => _db.userModels.put(user));
  }

  Future<List<MedicineModel>> getAllMedicines(int userId) async {
    return _db.medicineModels.filter().userIdEqualTo(userId).findAll();
  }

  Future<int> saveMedicine(MedicineModel medicine) async {
    return _db.writeTxn(() => _db.medicineModels.put(medicine));
  }

  Future<void> deleteMedicine(int id) async {
    await _db.writeTxn(() => _db.medicineModels.delete(id));
  }

  Future<List<AlarmModel>> getAllAlarms(int userId) async {
    return _db.alarmModels.filter().userIdEqualTo(userId).findAll();
  }

  Future<AlarmModel?> getAlarmById(int id) async {
    return _db.alarmModels.get(id);
  }

  Future<int> saveAlarm(AlarmModel alarm) async {
    return _db.writeTxn(() => _db.alarmModels.put(alarm));
  }

  Future<void> deleteAlarm(int id) async {
    await _db.writeTxn(() => _db.alarmModels.delete(id));
  }
}
