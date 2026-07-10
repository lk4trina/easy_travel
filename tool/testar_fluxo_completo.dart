import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../lib/models/viagem.dart';
import '../lib/services/destino_api_service.dart';

Future<void> main() async {
  sqfliteFfiInit();

  final dbPath = join(
    Directory.current.path,
    'tool',
    'easy_travel_teste.db',
  );

  await databaseFactoryFfi.deleteDatabase(dbPath);

  final db = await databaseFactoryFfi.openDatabase(
    dbPath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE viagens (
            id TEXT PRIMARY KEY,
            destino TEXT NOT NULL,
            pontoPartida TEXT,
            dataInicio TEXT NOT NULL,
            dataFim TEXT NOT NULL,
            quantidadeViajantes INTEGER NOT NULL,
            despesas TEXT,
            atracoes TEXT,
            acomodacoes TEXT,
            transportes TEXT,
            checkList TEXT,
            cidadeDestino TEXT
          )
        ''');
      },
    ),
  );

  final destinoService = DestinoApiService();

  print('Buscando cidade na API...');

  final cidades = await destinoService.buscarCidades('Floria');

  if (cidades.isEmpty) {
    throw Exception('Nenhuma cidade encontrada.');
  }

  final cidade = await destinoService.buscarCidadeComFoto(cidades.first);

  print('Cidade encontrada: ${cidade.label}');
  print('Foto encontrada: ${cidade.fotoUrl}');

  if (cidade.fotoUrl == null || cidade.fotoUrl!.isEmpty) {
    throw Exception('A cidade veio sem foto.');
  }

  final viagem = Viagem(
    id: 'teste-fluxo-1',
    destino: cidade.label,
    pontoPartida: 'Rio do Sul',
    dataInicio: DateTime(2026, 7, 10),
    dataFim: DateTime(2026, 7, 15),
    quantidadeViajantes: 2,
    despesas: [],
    atracoes: [],
    acomodacoes: [],
    transportes: [],
    checkList: [],
    cidadeDestino: cidade,
  );

  print('\nSalvando viagem no SQLite...');

  await db.insert(
    'viagens',
    viagem.toJson(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  print('Lendo viagem salva...');

  final resultado = await db.query('viagens');

  if (resultado.isEmpty) {
    throw Exception('Nenhuma viagem foi salva.');
  }

  final viagemSalva = Viagem.fromJson(resultado.first);

  print('\nDestino salvo: ${viagemSalva.destino}');
  print('Cidade salva: ${viagemSalva.cidadeDestino?.nome}');
  print('Estado salvo: ${viagemSalva.cidadeDestino?.estado}');
  print('País salvo: ${viagemSalva.cidadeDestino?.pais}');
  print('Foto salva: ${viagemSalva.cidadeDestino?.fotoUrl}');

  if (viagemSalva.cidadeDestino == null) {
    throw Exception('cidadeDestino não foi persistido.');
  }

  if (viagemSalva.cidadeDestino?.fotoUrl != cidade.fotoUrl) {
    throw Exception('A foto salva não bate com a foto buscada.');
  }

  await db.close();

  print('\nFluxo API + SQLite funcionando!');
}