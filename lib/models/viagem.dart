import 'dart:convert';
import 'cidade_destino.dart';

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

class Acomodacao {
  final String nome;
  final String localizacao;
  final String? checkIn;
  final String? checkOut;

  Acomodacao({required this.nome, required this.localizacao, this.checkIn, this.checkOut});

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'localizacao': localizacao,
    'checkIn': checkIn,
    'checkOut': checkOut,
  };

  factory Acomodacao.fromJson(Map<String, dynamic> json) => Acomodacao(
    nome: json['nome'],
    localizacao: json['localizacao'],
    checkIn: json['checkIn'],
    checkOut: json['checkOut'],
  );
}

class Transporte {
  final String tipo;
  final String detalhes;

  Transporte({required this.tipo, required this.detalhes});

  Map<String, dynamic> toJson() => {'tipo': tipo, 'detalhes': detalhes};

  factory Transporte.fromJson(Map<String, dynamic> json) => Transporte(
    tipo: json['tipo'],
    detalhes: json['detalhes'],
  );
}

class CheckItem {
  final String titulo;
  bool isDone;

  CheckItem({required this.titulo, this.isDone = false});

  Map<String, dynamic> toJson() => {'titulo': titulo, 'isDone': isDone};

  factory CheckItem.fromJson(Map<String, dynamic> json) => CheckItem(
    titulo: json['titulo'],
    isDone: json['isDone'] ?? false,
  );
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
  List<Acomodacao> acomodacoes;
  List<Transporte> transportes;
  List<CheckItem> checkList;
  final CidadeDestino? cidadeDestino;

  Viagem({
    required this.id,
    required this.destino,
    required this.pontoPartida,
    required this.dataInicio,
    required this.dataFim,
    required this.quantidadeViajantes,
    required this.despesas,
    required this.atracoes,
    this.cidadeDestino,
    this.acomodacoes = const [],
    this.transportes = const [],
    this.checkList = const [],
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
      'acomodacoes': jsonEncode(acomodacoes.map((e) => e.toJson()).toList()),
      'transportes': jsonEncode(transportes.map((e) => e.toJson()).toList()),
      'checkList': jsonEncode(checkList.map((e) => e.toJson()).toList()),
      'cidadeDestino': cidadeDestino != null ? jsonEncode(cidadeDestino!.toJson()) : null,
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
      acomodacoes: json['acomodacoes'] != null
          ? (jsonDecode(json['acomodacoes']) as List).map((e) => Acomodacao.fromJson(e)).toList()
          : [],
      transportes: json['transportes'] != null
          ? (jsonDecode(json['transportes']) as List).map((e) => Transporte.fromJson(e)).toList()
          : [],
      checkList: json['checkList'] != null
          ? (jsonDecode(json['checkList']) as List).map((e) => CheckItem.fromJson(e)).toList()
          : [],
      cidadeDestino: json['cidadeDestino'] != null
          ? CidadeDestino.fromJson(jsonDecode(json['cidadeDestino']))
          : null,    
    );
  }
}
