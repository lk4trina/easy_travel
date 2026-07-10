class CidadeDestino {
  final String nome;
  final String pais;
  final String estado;
  final double? latitude;
  final double? longitude;
  final String? fotoUrl;

  CidadeDestino({
    required this.nome,
    required this.pais,
    required this.estado,
    this.latitude,
    this.longitude,
    this.fotoUrl,
  });

  String get label => '$nome, $estado - $pais';

  CidadeDestino copyWith({String? fotoUrl}) {
    return CidadeDestino(
      nome: nome,
      pais: pais,
      estado: estado,
      latitude: latitude,
      longitude: longitude,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }
}