import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

import 'package:easy_travel/models/cidade_destino.dart';
import 'package:easy_travel/models/viagem.dart';
import 'package:easy_travel/services/database_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('deve salvar e ler uma viagem com cidadeDestino no SQLite', () async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('viagens');

    final cidade = CidadeDestino(
      nome: 'Florianópolis',
      estado: 'Santa Catarina',
      pais: 'Brasil',
      latitude: -27.5945,
      longitude: -48.5477,
      fotoUrl: 'https://upload.wikimedia.org/teste-floripa.jpg',
    );

    final viagem = Viagem(
      id: 'teste-1',
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

    await DatabaseHelper.instance.inserirViagem(viagem);

    final viagens = await DatabaseHelper.instance.lerTodasViagens();

    expect(viagens.length, 1);
    expect(viagens.first.destino, cidade.label);
    expect(viagens.first.cidadeDestino, isNotNull);
    expect(viagens.first.cidadeDestino!.nome, 'Florianópolis');
    expect(viagens.first.cidadeDestino!.estado, 'Santa Catarina');
    expect(viagens.first.cidadeDestino!.pais, 'Brasil');
    expect(
      viagens.first.cidadeDestino!.fotoUrl,
      'https://upload.wikimedia.org/teste-floripa.jpg',
    );
  });
}