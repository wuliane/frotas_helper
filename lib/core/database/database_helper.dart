import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../models/rental_model.dart';
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
      version: 3,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createVehiclesTable(db);
    await _createRentersTable(db);
    await _createRentalsTable(db);
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createRentersTable(db);
    }

    if (oldVersion < 3) {
      await _createRentalsTable(db);
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

  Future<void> _createRentalsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS rentals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER NOT NULL,
        renterId INTEGER NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT,
        fullValue REAL NOT NULL,
        discountedValue REAL NOT NULL,
        paymentFrequency TEXT NOT NULL,
        paymentWeekday INTEGER NOT NULL,
        depositValue REAL NOT NULL,
        depositReceived REAL NOT NULL,
        initialKm INTEGER NOT NULL,
        currentKm INTEGER NOT NULL,
        kmClosingDay INTEGER NOT NULL,
        kmLimitPerCycle INTEGER NOT NULL,
        excessKmValue REAL NOT NULL,
        status TEXT NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (vehicleId) REFERENCES vehicles (id),
        FOREIGN KEY (renterId) REFERENCES renters (id)
      )
    ''');
  }

  // VEÍCULOS

  Future<int> insertVehicle(VehicleModel vehicle) async {
    final db = await database;
    final data = vehicle.toMap();
    data.remove('id');

    return db.insert(
      'vehicles',
      data,
      conflictAlgorithm: ConflictAlgorithm.abort,
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

  Future<VehicleModel?> getVehicleById(int id) async {
    final db = await database;

    final maps = await db.query(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return VehicleModel.fromMap(maps.first);
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

  // LOCATÁRIOS

  Future<int> insertRenter(RenterModel renter) async {
    final db = await database;
    final data = renter.toMap();
    data.remove('id');

    return db.insert(
      'renters',
      data,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<RenterModel>> getRenters() async {
    final db = await database;

    final maps = await db.query(
      'renters',
      orderBy: 'name ASC',
    );

    return maps.map(RenterModel.fromMap).toList();
  }

  Future<RenterModel?> getRenterById(int id) async {
    final db = await database;

    final maps = await db.query(
      'renters',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return RenterModel.fromMap(maps.first);
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

  // LOCAÇÕES

  Future<int> insertRental(RentalModel rental) async {
    final db = await database;
    final data = rental.toMap();
    data.remove('id');

    return db.transaction((transaction) async {
      final activeRental = await transaction.query(
        'rentals',
        columns: ['id'],
        where: 'vehicleId = ? AND status = ?',
        whereArgs: [rental.vehicleId, 'Ativa'],
        limit: 1,
      );

      if (activeRental.isNotEmpty) {
        throw StateError(
          'Este veículo já possui uma locação ativa.',
        );
      }

      final rentalId = await transaction.insert(
        'rentals',
        data,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      await transaction.update(
        'vehicles',
        {
          'status': 'Alugado',
          'currentKm': rental.currentKm,
        },
        where: 'id = ?',
        whereArgs: [rental.vehicleId],
      );

      return rentalId;
    });
  }

  Future<List<RentalModel>> getRentals() async {
    final db = await database;

    final maps = await db.query(
      'rentals',
      orderBy: 'startDate DESC',
    );

    return maps.map(RentalModel.fromMap).toList();
  }

  Future<List<RentalModel>> getActiveRentals() async {
    final db = await database;

    final maps = await db.query(
      'rentals',
      where: 'status = ?',
      whereArgs: ['Ativa'],
      orderBy: 'startDate DESC',
    );

    return maps.map(RentalModel.fromMap).toList();
  }

  Future<RentalModel?> getRentalById(int id) async {
    final db = await database;

    final maps = await db.query(
      'rentals',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return RentalModel.fromMap(maps.first);
  }

  Future<int> updateRental(RentalModel rental) async {
    if (rental.id == null) {
      throw ArgumentError('A locação precisa possuir um ID.');
    }

    final db = await database;

    return db.update(
      'rentals',
      rental.toMap(),
      where: 'id = ?',
      whereArgs: [rental.id],
    );
  }

  Future<void> updateRentalCurrentKm({
    required RentalModel rental,
    required int currentKm,
  }) async {
    if (rental.id == null) {
      throw ArgumentError('A locação precisa possuir um ID.');
    }

    if (currentKm < rental.currentKm) {
      throw ArgumentError(
        'O novo KM não pode ser menor que o KM atual.',
      );
    }

    final db = await database;

    await db.transaction((transaction) async {
      await transaction.update(
        'rentals',
        {
          'currentKm': currentKm,
        },
        where: 'id = ?',
        whereArgs: [rental.id],
      );

      await transaction.update(
        'vehicles',
        {
          'currentKm': currentKm,
        },
        where: 'id = ?',
        whereArgs: [rental.vehicleId],
      );
    });
  }

  Future<void> finishRental({
    required RentalModel rental,
    required int finalKm,
  }) async {
    if (rental.id == null) {
      throw ArgumentError('A locação precisa possuir um ID.');
    }

    if (finalKm < rental.currentKm) {
      throw ArgumentError(
        'O KM final não pode ser menor que o KM atual.',
      );
    }

    final db = await database;

    await db.transaction((transaction) async {
      await transaction.update(
        'rentals',
        {
          'status': 'Encerrada',
          'currentKm': finalKm,
          'endDate': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [rental.id],
      );

      await transaction.update(
        'vehicles',
        {
          'status': 'Disponível',
          'currentKm': finalKm,
        },
        where: 'id = ?',
        whereArgs: [rental.vehicleId],
      );
    });
  }

  Future<int> deleteRental(int id) async {
    final db = await database;

    final rental = await getRentalById(id);

    if (rental?.status == 'Ativa') {
      throw StateError(
        'Encerre a locação antes de excluí-la.',
      );
    }

    return db.delete(
      'rentals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}