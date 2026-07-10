import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cidade_destino.dart';


class DestinoApiService {
  final String geonamesUsername = 'anadasilva03';

  Future<List<CidadeDestino>> buscarCidades(String termo) async {
    if (termo.trim().length < 2) return [];

    final uri = Uri.parse(
      'https://secure.geonames.org/searchJSON'
      '?name_startsWith=${Uri.encodeComponent(termo)}'
      '&country=BR'
      '&featureClass=P'
      '&cities=cities1000'
      '&maxRows=10'
      '&lang=pt'
      '&username=$geonamesUsername',
    );

    print('URL GeoNames: $uri');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
        throw Exception(
            'Erro ao buscar cidades. Status: ${response.statusCode}. Body: ${response.body}',
        );
    }

    final data = jsonDecode(response.body);
    final List geonames = data['geonames'] ?? [];

    return geonames.map((item) {
      return CidadeDestino(
        nome: item['name'] ?? '',
        pais: item['countryName'] ?? 'Brasil',
        estado: item['adminName1'] ?? '',
        latitude: double.tryParse(item['lat']?.toString() ?? ''),
        longitude: double.tryParse(item['lng']?.toString() ?? ''),
      );
    }).toList();
  }

Future<String?> buscarFotoCidade(CidadeDestino cidade) async {
  final termosBusca = [
    '${cidade.nome} ${cidade.estado} ${cidade.pais}',
    '${cidade.nome} município',
    '${cidade.nome} cidade',
    cidade.nome,
  ];

  for (final termo in termosBusca) {
    final foto = await _buscarImagemWikipediaMaior(termo);
    if (foto != null) {
      return foto;
    }
  }

  return null;
}

Future<String?> _buscarImagemWikipediaMaior(String termo) async {
  final uri = Uri.https(
    'pt.wikipedia.org',
    '/w/api.php',
    {
      'action': 'query',
      'format': 'json',
      'generator': 'search',
      'gsrsearch': termo,
      'gsrlimit': '3',
      'prop': 'pageimages',
      'piprop': 'thumbnail',
      'pithumbsize': '1200',
      'redirects': '1',
      'origin': '*',
    },
  );

  final response = await http.get(
    uri,
    headers: {
      'User-Agent': 'EasyTravel/1.0 (app academico)',
    },
  );

  if (response.statusCode != 200) {
    return null;
  }

  final data = jsonDecode(response.body);
  final pages = data['query']?['pages'];

  if (pages == null) return null;

  for (final page in pages.values) {
    final thumbnail = page['thumbnail'];

    if (thumbnail != null && thumbnail['source'] != null) {
      return thumbnail['source'];
    }
  }

  return null;
}

Future<CidadeDestino> buscarCidadeComFoto(CidadeDestino cidade) async {
  final fotoUrl = await buscarFotoCidade(cidade);
  return cidade.copyWith(fotoUrl: fotoUrl);
}
}