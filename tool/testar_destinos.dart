import '../lib/services/destino_api_service.dart';

Future<void> main() async {
  final service = DestinoApiService();

  print('Buscando cidades...');

  final cidades = await service.buscarCidades('Floria');

  print('Cidades encontradas: ${cidades.length}');

  for (final cidade in cidades) {
    print('- ${cidade.label}');
  }

  if (cidades.isNotEmpty) {
    print('\nBuscando foto da primeira cidade...');

    final cidadeComFoto = await service.buscarCidadeComFoto(cidades.first);

    print('Cidade: ${cidadeComFoto.label}');
    print('Foto: ${cidadeComFoto.fotoUrl}');
  }
}