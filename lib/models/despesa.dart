class Despesa {
  final String id;
  final String categoria;
  final double valor;
  final DateTime data;
  final bool isIndividual;

  Despesa({
    required this.id,
    required this.categoria,
    required this.valor,
    required this.data,
    required this.isIndividual,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoria': categoria,
    'valor': valor,
    'data': data.toIso8601String(),
    'isIndividual': isIndividual,
  };

  factory Despesa.fromJson(Map<String, dynamic> json) => Despesa(
    id: json['id'],
    categoria: json['categoria'],
    valor: json['valor'],
    data: DateTime.parse(json['data']),
    isIndividual: json['isIndividual'],
  );
}