import 'package:hilo/models/number.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:sembast/sembast_io.dart';

class NumberDB {
  // Singleton pattern to ensure only one instance of the database helper exists
  static final NumberDB _instance = NumberDB._internal();
  factory NumberDB() => _instance;
  NumberDB._internal();

  Database? _db;
  final String _dbName = 'hilo.db';
  final StoreRef<int, Map<String, dynamic>> _customStore = intMapStoreFactory
      .store('numbers');

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _openDatabase();
    return _db!;
  }

  Future<Database> _openDatabase() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDirectory.path, _dbName);
    DatabaseFactory dbFactory = databaseFactoryIo;
    return await dbFactory.openDatabase(dbLocation);
  }

  // Insert data
  Future<int> InsertData(Numbers number) async {
    final dbClient = await database;
    return await _customStore.add(dbClient, {'value': number.value});
  }

  // Load all data (sorted by ID descending - newest saved first)
  Future<List<Numbers>> LoadAllData() async {
    final dbClient = await database;
    // Sort by key descending so newest records (highest IDs) come first
    final finder = Finder(sortOrders: [SortOrder(Field.key, false)]);
    final records = await _customStore.find(dbClient, finder: finder);

    return records.map((snapshot) {
      return Numbers(snapshot.value['value'] as int, id: snapshot.key);
    }).toList();
  }

  // Delete data
  Future<void> DeleteData(int id) async {
    final dbClient = await database;
    await _customStore.record(id).delete(dbClient);
  }

  // Update data
  Future<void> UpdateData(Numbers number) async {
    if (number.id == null) return; // Cannot update without ID
    final dbClient = await database;
    await _customStore.record(number.id!).update(dbClient, {
      'value': number.value,
    });
  }
}
