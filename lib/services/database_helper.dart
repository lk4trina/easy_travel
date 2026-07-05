import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/viagem.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('easy_travel.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE viagens (
  id $idType,
  destino $textType,
  pontoPartida TEXT,
  dataInicio $textType,
  dataFim $textType,
  quantidadeViajantes $integerType,
  despesas TEXT,
  atracoes TEXT -- Armazena a lista de atrações locais do usuário
)
''');
  }

  Future<void> inserirViagem(Viagem viagem) async {
    final db = await instance.database;
    await db.insert(
      'viagens',
      viagem.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Viagem>> lerTodasViagens() async {
    final db = await instance.database;
    final result = await db.query('viagens');
    return result.map((json) => Viagem.fromJson(json)).toList();
  }

  Future<void> atualizarViagem(Viagem viagem) async {
    final db = await instance.database;
    await db.update(
      'viagens',
      viagem.toJson(),
      where: 'id = ?',
      whereArgs: [viagem.id],
    );
  }
}