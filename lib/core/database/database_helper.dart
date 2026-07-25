import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../models/renter_model.dart';
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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createVehiclesTable(db);
    await _createRentersTable(db);
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createRentersTable(db);
    }
  }

  Future<void> _createVehiclesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS vehicles (
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

  Future<void> _createRentersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS renters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cpf TEXT NOT NULL,
        rg TEXT NOT NULL DEFAULT '',
        cnh TEXT NOT NULL,
        cnhCategory TEXT NOT NULL DEFAULT '',
        cnhExpiration TEXT NOT NULL DEFAULT '',
        phone TEXT NOT NULL,
        email TEXT NOT NULL DEFAULT '',
        address TEXT NOT NULL DEFAULT '',
        emergencyContact TEXT NOT NULL DEFAULT '',
        notes TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  Future<int> insertVehicle(VehicleModel vehicle) async {
    final db = await database;
    final data = vehicle.toMap();
    data.remove('id');

    return db.insert('vehicles', data);
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

  Future<int> insertRenter(RenterModel renter) async {
    final db = await database;
    final data = renter.toMap();
    data.remove('id');

    return db.insert('renters', data);
  }

  Future<List<RenterModel>> getRenters() async {
    final db = await database;

    final maps = await db.query(
      'renters',
      orderBy: 'name ASC',
    );

    return maps.map(RenterModel.fromMap).toList();
  }

  Future<int> updateRenter(RenterModel renter) async {
    if (renter.id == null) {
      throw ArgumentError('O locatário precisa possuir um ID.');
    }

    final db = await database;

    return db.update(
      'renters',
      renter.toMap(),
      where: 'id = ?',
      whereArgs: [renter.id],
    );
  }

  Future<int> deleteRenter(int id) async {
    final db = await database;

    return db.delete(
      'renters',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}