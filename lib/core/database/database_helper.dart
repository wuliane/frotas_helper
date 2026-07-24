import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../models/vehicle_model.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  static void initializeDatabaseFactory() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'frotas_helper.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plate TEXT NOT NULL,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER NOT NULL,
        color TEXT NOT NULL,
        currentKm INTEGER NOT NULL,
        purchaseValue REAL NOT NULL,
        rentalValue REAL NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertVehicle(VehicleModel vehicle) async {
    final db = await database;

    final data = vehicle.toMap();
    data.remove('id');

    return db.insert(
      'vehicles',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<VehicleModel>> getVehicles() async {
    final db = await database;

    final maps = await db.query(
      'vehicles',
      orderBy: 'brand ASC, model ASC',
    );

    return maps.map(VehicleModel.fromMap).toList();
  }

  Future<int> updateVehicle(VehicleModel vehicle) async {
    if (vehicle.id == null) {
      throw ArgumentError('O veículo precisa possuir um ID.');
    }

    final db = await database;

    return db.update(
      'vehicles',
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<int> deleteVehicle(int id) async {
    final db = await database;

    return db.delete(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}