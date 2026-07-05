import 'dart:convert';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoria': categoria,
      'valor': valor,
      'data': data.toIso8601String(),
      'isIndividual': isIndividual ? 1 : 0,
    };
  }

  factory Despesa.fromJson(Map<String, dynamic> json) {
    return Despesa(
      id: json['id'],
      categoria: json['categoria'],
      valor: (json['valor'] as num).toDouble(),
      data: DateTime.parse(json['data']),
      isIndividual: json['isIndividual'] == 1 || json['isIndividual'] == true,
    );
  }
}

class Viagem {
  final String id;
  final String destino;
  final String? pontoPartida;
  final DateTime dataInicio;
  final DateTime dataFim;
  final int quantidadeViajantes;
  List<Despesa> despesas;
  final List<String> atracoes;

  Viagem({
    required this.id,
    required this.destino,
    required this.pontoPartida,
    required this.dataInicio,
    required this.dataFim,
    required this.quantidadeViajantes,
    required this.despesas,
    required this.atracoes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destino': destino,
      'pontoPartida': pontoPartida,
      'dataInicio': dataInicio.toIso8601String(),
      'dataFim': dataFim.toIso8601String(),
      'quantidadeViajantes': quantidadeViajantes,
      'despesas': jsonEncode(despesas.map((e) => e.toJson()).toList()),
      'atracoes': jsonEncode(atracoes),
    };
  }

  factory Viagem.fromJson(Map<String, dynamic> json) {
    return Viagem(
      id: json['id'],
      destino: json['destino'],
      pontoPartida: json['pontoPartida'],
      dataInicio: DateTime.parse(json['dataInicio']),
      dataFim: DateTime.parse(json['dataFim']),
      quantidadeViajantes: json['quantidadeViajantes'],
      despesas: json['despesas'] != null
          ? (jsonDecode(json['despesas']) as List).map((e) => Despesa.fromJson(e)).toList()
          : [],
      atracoes: json['atracoes'] != null
          ? List<String>.from(jsonDecode(json['atracoes']))
          : [],
    );
  }
}