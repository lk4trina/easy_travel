import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/viagem.dart';
import '../services/database_helper.dart';

class ViagemViewModel extends ChangeNotifier {
  List<Viagem> _viagens = [];
  final _uuid = const Uuid();

  List<Viagem> get viagens => _viagens;

  // Construtor único unificado
  ViagemViewModel() {
    _carregarDados();
    inicializarAtracoesNoFirebase();
  }

  // Carrega as viagens do banco de dados SQLite local
  Future<void> _carregarDados() async {
    _viagens = await DatabaseHelper.instance.lerTodasViagens();
    notifyListeners();
  }

  // Cria uma nova viagem inicializando as listas vazias e salva no SQLite
  Future<void> adicionarViagem({
    required String destino,
    required String? pontoPartida,
    required DateTime dataInicio,
    required DateTime dataFim,
    required int quantidadeViajantes,
  }) async {
    final novaViagem = Viagem(
      id: _uuid.v4(),
      destino: destino,
      pontoPartida: pontoPartida,
      dataInicio: dataInicio,
      dataFim: dataFim,
      quantidadeViajantes: quantidadeViajantes,
      despesas: [],
      atracoes: [],
    );

    _viagens.add(novaViagem);
    await DatabaseHelper.instance.inserirViagem(novaViagem);
    notifyListeners();
  }

  // Atualiza uma viagem existente no SQLite (usado para salvar o roteiro de atrações)
  Future<void> atualizarViagem(Viagem viagem) async {
    final index = _viagens.indexWhere((v) => v.id == viagem.id);
    if (index != -1) {
      _viagens[index] = viagem;
      await DatabaseHelper.instance.atualizarViagem(viagem);
      notifyListeners();
    }
  }

  // Adiciona uma despesa a uma viagem específica e atualiza o banco local
  Future<void> adicionarDespesa(
      String viagemId, {
        required String categoria,
        required double valor,
        required DateTime data,
        required bool isIndividual,
      }) async {
    final index = _viagens.indexWhere((v) => v.id == viagemId);
    if (index != -1) {
      final novaDespesa = Despesa(
        id: _uuid.v4(),
        categoria: categoria,
        valor: valor,
        data: data,
        isIndividual: isIndividual,
      );

      _viagens[index].despesas = [..._viagens[index].despesas, novaDespesa];
      await DatabaseHelper.instance.atualizarViagem(_viagens[index]);
      notifyListeners();
    }
  }

  // Cálculos financeiros para a tela de Gastos
  double calcularTotalIndividual(String widgetViagemId) {
    final viagem = _viagens.firstWhere((v) => v.id == widgetViagemId, orElse: () => _viagens.first);
    return viagem.despesas
        .where((d) => d.isIndividual)
        .fold(0.0, (sum, item) => sum + item.valor);
  }

  double calcularTotalGrupo(String widgetViagemId) {
    final viagem = _viagens.firstWhere((v) => v.id == widgetViagemId, orElse: () => _viagens.first);
    return viagem.despesas
        .where((d) => !d.isIndividual)
        .fold(0.0, (sum, item) => sum + item.valor);
  }

  // FUNÇÃO DE AUTO-SETUP: Alimenta o catálogo na nuvem (Firebase) se estiver vazio
  Future<void> inicializarAtracoesNoFirebase() async {
    final firestore = FirebaseFirestore.instance;
    final colecao = firestore.collection('cidades');

    final dadosIniciais = {
      'Florianópolis, SC - Brasil': {
        'fotoCidade': 'https://unsplash.com/pt-br/fotografias/cidade-com-arranha-ceus-vendo-o-mar-azul-sob-ceus-azuis-e-brancos-IhknpZPSKnw',
        'atracoes': [
          {
            'nome': 'Ilha do Campeche',
            'fotos': [
              'https://ecoturismosuldailha.com.br/wp-content/uploads/2023/12/passeio-ilha-do-campeche.png',
              'https://s2-g1.glbimg.com/rh_N0Um3qvTJJeTHSPR6wrkSukE=/0x0:1200x637/924x0/smart/filters:strip_icc()/i.s3.glbimg.com/v1/AUTH_59edd422c0c84a879bd37670ae4f538a/internal_photos/bs/2025/g/W/u1mr3OSMCCv64awwEjjg/design-sem-nome-2025-01-28t142555.838.png'
            ]
          },
          {
            'nome': 'Ponte Hercílio Luz',
            'fotos': [
              'https://unsplash.com/pt-br/fotografias/uma-ponte-sobre-a-agua-com-uma-cidade-ao-fundo--W3rTwVpG5U',
              'https://www.pexels.com/photo/aerial-view-of-a-suspension-bridge-in-the-city-of-floripa-brazil-6676186/'
            ]
          },
          {
            'nome': 'Lagoa da Conceição',
            'fotos': [
              'https://www.pexels.com/photo/sandy-beach-with-seagulls-and-boats-in-brazil-36370259/',
              'https://unsplash.com/pt-br/fotografias/um-par-de-barcos-que-estao-sentados-na-agua-AWmFgRtRUTs'
            ]
          },
          {
            'nome': 'Praia da Joaquina',
            'fotos': [
              'https://unsplash.com/pt-br/fotografias/homem-em-roupa-de-mergulho-preta-surfando-nas-ondas-do-mar-durante-o-dia-vHVMTq9WFnU',
              'https://www.pexels.com/photo/seashore-during-daytime-illustration-155246/'
            ]
          },
          {
            'nome': 'Mercado Público',
            'fotos': [
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSBOHGqK3KXkhbkzp5_qQNPjUrxKYUozXj_frcXVQuw7hDlqLe_zezg-buJ&s=10',
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThKg88dWTsW_5IH_h46HO0-QhNBZRDgyLmM_LsS6xYnKDGrsoaUzAmFxU&s=10'
            ]
          },
          {
            'nome': 'Santo Antônio de Lisboa',
            'fotos': [
              'https://viajandosemtedio.com.br/wp-content/uploads/2021/12/euamo2.jpg',
              'https://destinoflorianopolis.com.br/wp-content/uploads/2016/07/Santo-Ant%C3%B4nio-de-Lisboa-Foto-Heverson-Santos-1.jpg'
            ]
          },
          {
            'nome': 'Praia de Jurerê',
            'fotos': [
              'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/1a/94/d6/1b/praia-de-jurere-tradicional.jpg?w=1200&h=-1&s=1',
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTrCMYLEBWh4QZfX4wMk0hciD-p_19r-yKWTCmqtqtVtp5rFjlS4V3KDW4&s=10'
            ]
          },
          {
            'nome': 'Dunas da Joaquina',
            'fotos': [
              'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/14/96/a3/14/ameiii.jpg?w=900&h=-1&s=1',
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTxSIPi1UqQvNY7kIejzZWZuKggKnCI1ORDLoRTGE-O84Tn6g7wgZ_Tk5o&s=10'
            ]
          },
          {
            'nome': 'Praia de Canasvieiras',
            'fotos': [
              'https://res.cloudinary.com/worldpackers/image/upload/c_fill,f_auto,q_auto,w_1024/v1/guides/article_cover/amv2qe0rq2pisbobbyi9?_a=BACAGSGT',
              'https://visitefloripa.com.br/wp-content/uploads/elementor/thumbs/Canasvieiras-3-qog17gcf5v1rtslrzef5t75mhh6m62remxg0iszdug.jpg'
            ]
          },
          {
            'nome': 'Ribeirão da Ilha',
            'fotos': [
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSFiLm_gLtJq_hw5FGL71eZVkJ0w-Rkpfgf6_aFENz-EmvS0TgS1ik3gZhD&s=10',
              'https://casadedoda.com/wp-content/uploads/2017/06/ribeirao-da-ilha-372.jpg'
            ]
          }
        ]
      },
      'Balneário Camboriú, SC - Brasil': {
        'fotoCidade': 'https://unsplash.com/pt-br/fotografias/uma-vista-de-uma-cidade-a-noite-a-partir-de-uma-vista-panoramica-GvteIVS0dOo',
        'atracoes': [
          {
            'nome': 'Parque Unipraias',
            'fotos': [
              'https://imgmd.net/images/v1/guia/2917657/parque-unipraias.jpg',
              'https://imgmd.net/images/v1/guia/2917658/parque-unipraias.jpg'
            ]
          },
          {
            'nome': 'Roda Gigante FG Big Wheel',
            'fotos': [
              'https://www.melhoresdestinos.com.br/wp-content/uploads/2020/12/fg-big-wheel-roda-gigante-balneario-camboriu-capa2019-01.jpg',
              'https://cdn.zarpou.com.br/zarpou/servicos/ingresso-roda-gigante-big-wheel-63038acbd325e-large.jpg?quality=75'
            ]
          },
          {
            'nome': 'Praia de Laranjeiras',
            'fotos': [
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ87MIblhqyDVXrpu9U6Mvd1zwOqvjp4FQn39AcsYfXD8RPEXHmroDfOM0q&s=10',
              'https://hotelmarimar.com.br/wp-content/uploads/2025/05/Balneario-Camboriu-desvende-as-belezas-desse-destino-junho.jpg'
            ]
          },
          {
            'nome': 'Cristo Luz',
            'fotos': [
              'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/13/04/db/4d/cristo-luza-a-iluminar.jpg?w=1200&h=-1&s=1',
              'https://static.ndmais.com.br/2023/11/7.jpg'
            ]
          },
          {
            'nome': 'Molhe da Barra Sul',
            'fotos': [
              'https://blog.saluteimoveis.com/wp-content/uploads/2021/08/Molhe-da-Barra-Sul-1-1024x575.jpg',
              'https://localconnect.com.br/blog/wp-content/uploads/2024/12/dji_fly_20250414_162458_570_1744658706470_photo_optimized_VSCO-scaled.jpeg'
            ]
          },
          {
            'nome': 'Avenida Atlântica',
            'fotos': [
              'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/07/5a/7e/ed/vista-do-setimo-andar.jpg?w=900&h=500&s=1',
              'https://blog.judicearaujo.com.br/wp-content/uploads/2023/12/i82D50x2_19365616ed6d67f5fe.jpg'
            ]
          },
          {
            'nome': 'Passarela da Barra',
            'fotos': [
              'https://images.unsplash.com/photo-1511316695145-4992006ffddb?w=400&q=80',
              'https://images.unsplash.com/photo-1518005020951-eccb494ad742?w=400&q=80'
            ]
          },
          {
            'nome': 'Praia do Estaleiro',
            'fotos': [
              'https://images.unsplash.com/photo-1439066615861-d1af74d74000?w=400&q=80',
              'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=400&q=80'
            ]
          },
          {
            'nome': 'Praia do Pinho',
            'fotos': [
              'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=400&q=80',
              'https://images.unsplash.com/photo-1501426026826-31c667bdf23d?w=400&q=80'
            ]
          },
          {
            'nome': 'Oceanic Aquarium',
            'fotos': [
              'https://images.unsplash.com/photo-1522069169874-c58ec4b76be5?w=400&q=80',
              'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&q=80'
            ]
          }
        ]
      },
      'Blumenau, SC - Brasil': {
        'fotoCidade': 'https://images.unsplash.com/photo-1599833585141-863a017e2993?w=800&q=80',
        'atracoes': [
          {
            'nome': 'Vila Germânica',
            'fotos': [
              'https://images.unsplash.com/photo-1586724230021-a02154315256?w=400&q=80',
              'https://images.unsplash.com/photo-1605371924599-2c03b5dbae30?w=400&q=80'
            ]
          },
          {
            'nome': 'Museu da Cerveja',
            'fotos': [
              'https://images.unsplash.com/photo-1566633806327-68e152aaf26d?w=400&q=80',
              'https://images.unsplash.com/photo-1571613316887-6f8d5cbf7ef7?w=400&q=80'
            ]
          },
          {
            'nome': 'Rua XV de Novembro',
            'fotos': [
              'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=400&q=80',
              'https://images.unsplash.com/photo-1490642914619-7955a3fd483c?w=400&q=80'
            ]
          },
          {
            'nome': 'Parque Ramiro Ruediger',
            'fotos': [
              'https://images.unsplash.com/photo-1519331379826-f10be5486c6f?w=400&q=80',
              'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&q=80'
            ]
          },
          {
            'nome': 'Catedral São Paulo Apóstolo',
            'fotos': [
              'https://images.unsplash.com/photo-1548625361-155de0cbb55a?w=400&q=80',
              'https://images.unsplash.com/photo-1478147427282-58a87a120781?w=400&q=80'
            ]
          },
          {
            'nome': 'Museu da Família Colonial',
            'fotos': [
              'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=400&q=80',
              'https://images.unsplash.com/photo-1464146072230-91cabc968266?w=400&q=80'
            ]
          },
          {
            'nome': 'Prefeitura de Blumenau',
            'fotos': [
              'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=400&q=80',
              'https://images.unsplash.com/photo-1582407947304-fd86f028f716?w=400&q=80'
            ]
          },
          {
            'nome': 'Spitzkopf',
            'fotos': [
              'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80',
              'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=400&q=80'
            ]
          },
          {
            'nome': 'Parque das Nascentes',
            'fotos': [
              'https://images.unsplash.com/photo-1448375240586-882707db888b?w=400&q=80',
              'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=400&q=80'
            ]
          },
          {
            'nome': 'Museu de Hábitos e Costumes',
            'fotos': [
              'https://images.unsplash.com/photo-1566121318594-a4f5c3754d45?w=400&q=80',
              'https://images.unsplash.com/photo-1558591710-4b4a1ae0f04d?w=400&q=80'
            ]
          }
        ]
      },
      'Joinville, SC - Brasil': {
        'fotoCidade': 'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?w=800&q=80',
        'atracoes': [
          {
            'nome': 'Escola do Teatro Bolshoi',
            'fotos': [
              'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=400&q=80',
              'https://images.unsplash.com/photo-1518834107812-67b0b7c58434?w=400&q=80'
            ]
          },
          {
            'nome': 'Mirante de Joinville',
            'fotos': [
              'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=400&q=80',
              'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=400&q=80'
            ]
          },
          {
            'nome': 'Museu Nacional de Imigração',
            'fotos': [
              'https://images.unsplash.com/photo-1549880338-65ddcdfd017b?w=400&q=80',
              'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=400&q=80'
            ]
          },
          {
            'nome': 'Estrada Bonita',
            'fotos': [
              'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=400&q=80',
              'https://images.unsplash.com/photo-1475924156734-496f6cac6ec1?w=400&q=80'
            ]
          },
          {
            'nome': 'Parque Zoobotânico',
            'fotos': [
              'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400&q=80',
              'https://images.unsplash.com/photo-1572099606223-6e29f85c334e?w=400&q=80'
            ]
          },
          {
            'nome': 'Rua das Palmeiras',
            'fotos': [
              'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=400&q=80',
              'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400&q=80'
            ]
          },
          {
            'nome': 'MUBI - Museu da Bicicleta',
            'fotos': [
              'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=400&q=80',
              'https://images.unsplash.com/photo-1532298229144-0ec0c57515c7?w=400&q=80'
            ]
          },
          {
            'nome': 'Gidrion (Passeio de Barco)',
            'fotos': [
              'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=400&q=80',
              'https://images.unsplash.com/photo-1559136555-9303baea8ebd?w=400&q=80'
            ]
          },
          {
            'nome': 'Parque Porta do Mar',
            'fotos': [
              'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=400&q=80',
              'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80'
            ]
          },
          {
            'nome': 'Mercado Público',
            'fotos': [
              'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=400&q=80',
              'https://images.unsplash.com/photo-1543007630-9710e4a00a20?w=400&q=80'
            ]
          }
        ]
      },
      'Manaus, AM - Brasil': {
        'fotoCidade': 'https://images.unsplash.com/photo-1601379018444-ed884ee7ba88?w=800&q=80',
        'atracoes': [
          {
            'nome': 'Teatro Amazonas',
            'fotos': [
              'https://images.unsplash.com/photo-1596402184320-417e7178b2cd?w=400&q=80',
              'https://images.unsplash.com/photo-1549918830-116704c4668b?w=400&q=80'
            ]
          },
          {
            'nome': 'Encontro das Águas',
            'fotos': [
              'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=400&q=80',
              'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80'
            ]
          },
          {
            'nome': 'Mercado Adolpho Lisboa',
            'fotos': [
              'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&q=80',
              'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=400&q=80'
            ]
          },
          {
            'nome': 'Praia da Ponta Negra',
            'fotos': [
              'https://images.unsplash.com/photo-1501426026826-31c667bdf23d?w=400&q=80',
              'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=400&q=80'
            ]
          },
          {
            'nome': 'MUSA - Museu da Amazônia',
            'fotos': [
              'https://images.unsplash.com/photo-1448375240586-882707db888b?w=400&q=80',
              'https://images.unsplash.com/photo-1502082553048-f009c37129b9?w=400&q=80'
            ]
          },
          {
            'nome': 'Arquipélago de Anavilhanas',
            'fotos': [
              'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=400&q=80',
              'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&q=80'
            ]
          },
          {
            'nome': 'Palácio Rio Negro',
            'fotos': [
              'https://images.unsplash.com/photo-1564507592333-c60657eea523?w=400&q=80',
              'https://images.unsplash.com/photo-1595206133361-b1fe343e5e23?w=400&q=80'
            ]
          },
          {
            'nome': 'Sumaúma Park',
            'fotos': [
              'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400&q=80',
              'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&q=80'
            ]
          },
          {
            'nome': 'Centro de Instrução de Guerra na Selva (CIGS)',
            'fotos': [
              'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400&q=80',
              'https://images.unsplash.com/photo-1472396961693-142e6e269027?w=400&q=80'
            ]
          },
          {
            'nome': 'Flutuantes do Tarumã',
            'fotos': [
              'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=400&q=80',
              'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=400&q=80'
            ]
          }
        ]
      }
    };

    try {
      final snapshot = await colecao.limit(1).get();
      if (snapshot.docs.isEmpty) {
        for (var entrada in dadosIniciais.entries) {
          await colecao.doc(entrada.key).set(entrada.value);
        }
        print("🔥 Catálogo de atrações com fotos enviado para o Firebase!");
      }
    } catch (e) {
      print("Erro ao inicializar Firebase com fotos: $e");
    }
  }
}