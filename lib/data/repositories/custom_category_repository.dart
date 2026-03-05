import 'package:isar/isar.dart';
import 'package:nook/data/models/custom_category.dart';
import 'package:nook/data/models/transaction.dart';
import 'package:path_provider/path_provider.dart';

class CustomCategoryRepository {
  Isar? _isar;

  Future<Isar> get _db async {
    if (_isar != null && _isar!.isOpen) return _isar!;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [TransactionSchema, CustomCategorySchema],
      directory: dir.path,
    );
    return _isar!;
  }

  Future<int> insert(CustomCategory category) async {
    final isar = await _db;
    return isar.writeTxn(() async {
      return isar.customCategorys.put(category);
    });
  }

  Future<List<CustomCategory>> getByType(String type) async {
    final isar = await _db;
    return isar.customCategorys
        .where()
        .typeEqualTo(type)
        .findAll();
  }

  Future<List<CustomCategory>> getAll() async {
    final isar = await _db;
    return isar.customCategorys.where().findAll();
  }

  Future<bool> delete(int id) async {
    final isar = await _db;
    return isar.writeTxn(() async {
      return isar.customCategorys.delete(id);
    });
  }

  Future<void> clearAll() async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.customCategorys.clear();
    });
  }
}
