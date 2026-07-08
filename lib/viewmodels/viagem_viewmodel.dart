import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/viagem.dart';
import '../services/database_helper.dart';

class ViagemViewModel extends ChangeNotifier {
  List<Viagem> _viagens = [];
  final _uuid = const Uuid();

  List<Viagem> get viagens => _viagens;

  ViagemViewModel() {
    _carregarDados();
    inicializarAtracoesNoFirebase();
  }

  Future<void> _carregarDados() async {
    _viagens = await DatabaseHelper.instance.lerTodasViagens();
    notifyListeners();
  }

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
      acomodacoes: [],
      transportes: [],
      checkList: [],
    );

    _viagens.add(novaViagem);
    await DatabaseHelper.instance.inserirViagem(novaViagem);
    notifyListeners();
  }

  Future<void> atualizarViagem(Viagem viagem) async {
    final index = _viagens.indexWhere((v) => v.id == viagem.id);
    if (index != -1) {
      _viagens[index] = viagem;
      await DatabaseHelper.instance.atualizarViagem(viagem);
      notifyListeners();
    }
  }

  Future<void> excluirViagem(String id) async {
    _viagens.removeWhere((v) => v.id == id);
    await DatabaseHelper.instance.excluirViagem(id);
    notifyListeners();
  }

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

  Future<void> adicionarAcomodacao(String viagemId, Acomodacao acomodacao) async {
    final index = _viagens.indexWhere((v) => v.id == viagemId);
    if (index != -1) {
      _viagens[index].acomodacoes = [..._viagens[index].acomodacoes, acomodacao];
      await DatabaseHelper.instance.atualizarViagem(_viagens[index]);
      notifyListeners();
    }
  }

  Future<void> adicionarTransporte(String viagemId, Transporte transporte) async {
    final index = _viagens.indexWhere((v) => v.id == viagemId);
    if (index != -1) {
      _viagens[index].transportes = [..._viagens[index].transportes, transporte];
      await DatabaseHelper.instance.atualizarViagem(_viagens[index]);
      notifyListeners();
    }
  }

  Future<void> adicionarCheckItem(String viagemId, CheckItem item) async {
    final index = _viagens.indexWhere((v) => v.id == viagemId);
    if (index != -1) {
      _viagens[index].checkList = [..._viagens[index].checkList, item];
      await DatabaseHelper.instance.atualizarViagem(_viagens[index]);
      notifyListeners();
    }
  }

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
              'https://www.viagensecaminhos.com/wp-content/uploads/2017/03/passarela-da-barra-balneario-camboriu-1.jpg',
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ2cYQ26tYA5cp8_rUNR3UaA4sTEo8V3SgJaHdXWcb8em1dhqBuLxeHamA&s=10'
            ]
          },
          {
            'nome': 'Praia do Estaleiro',
            'fotos': [
              'https://www.safetyyatchs.com.br/admin/image/blog/48/48-1thumb.jpg',
              'https://imgmd.net/images/v1/guia/2917634/praia-do-estaleiro.jpg'
            ]
          },
          {
            'nome': 'Praia do Pinho',
            'fotos': [
              'https://img2.migalhas.com.br/_MEDPROC_/https__img.migalhas.com.br__SL__gf_base__SL__empresas__SL__MIGA__SL__imagens__SL__2025__SL__12__SL__30__SL__cropped_bxgnamx4.i4u.png._PROC_CP65.png',
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdyM4Gfh-pYaL-BgBqooZ-dwWI6BAVnwhZve9veTfnqjvejFAPUgk3Ak1g&s=10'
            ]
          },
          {
            'nome': 'Oceanic Aquarium',
            'fotos': [
              'https://passaportedigital.com/wp-content/uploads/2021/02/oceanic-aquarium-balneario-camboriu.jpg',
              'https://oatlantico.com.br/wp-content/uploads/2020/03/0aquario3.jpg'
            ]
          }
        ]
      },
      'Blumenau, SC - Brasil': {
        'fotoCidade': 'https://www.hotel10.com.br/wp-content/uploads/2025/09/Credito_-Daniel-Zimmermann.webp',
        'atracoes': [
          {
            'nome': 'Vila Germânica',
            'fotos': [
              'https://www.dicasdeviagem.com/wp-content/uploads/2019/06/vila-germanica-blumenau-1024x685.jpg',
              'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/1a/8b/1b/8b/emporio-vila-germanica.jpg?w=1200&h=-1&s=1'
            ]
          },
          {
            'nome': 'Museu da Cerveja',
            'fotos': [
              'https://www.litoraldesantacatarina.com/wp-content/uploads/2010/10/foto-museu-da-cerveja.jpg',
              'https://casadedoda.com/wp-content/uploads/2018/04/museu-da-cerveja-blumenau-6.jpg'
            ]
          },
          {
            'nome': 'Rua XV de Novembro',
            'fotos': [
              'https://www.turismoblumenau.com.br/wp-content/uploads/2021/10/Rua-XV-COMERCIO-1.jpg',
              'https://casadoturista.com.br/wp-content/uploads/2016/05/MG_5961.jpg'
            ]
          },
          {
            'nome': 'Parque Ramiro Ruediger',
            'fotos': [
              'https://blog.zelt.com.br/wp-content/uploads/2019/08/5-razoes-morar-proximo-parque-ramiro-ruediger.jpg',
              'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/1b/01/ed/ec/20200222-162831-largejpg.jpg?w=1200&h=1200&s=1'
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
        'fotoCidade': 'https://cdn.imoview.com.br/principe/Site/imagens/f29fgq0g.png',
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
        'fotoCidade': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRB0-4zRMmWeYb4IbVQwzrpIXSYuDqj3vEKFYDBskKOcGFZtkkznYvk9QA&s=10',
        'atracoes': [
          {
            'nome': 'Teatro Amazonas',
            'fotos': [
              'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0c/20/49/13/vista-externa-do-teatro.jpg?w=700&h=400&s=1',
              'https://turistaprofissional.com/wp-content/uploads/2012/12/Teatro-Amazonas.jpg'
            ]
          },
          {
            'nome': 'Encontro das Águas',
            'fotos': [
              'https://hweb-images.br-se1.magaluobjects.com/5873d325c19a4207cc40b87c/35464b3be0044f5a8a689a425b5247a6.jpg',
              'https://i0.wp.com/cabocloshousecolodge.com/wp-content/uploads/2022/08/encontro_das_aguas-AMAZONIA-REAL.jpg?fit=955%2C562&ssl=1'
            ]
          },
          {
            'nome': 'Mercado Adolpho Lisboa',
            'fotos': [
              'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0a/26/7e/4b/mercado-municipal-adolfo.jpg?w=1200&h=1200&s=1',
              'https://portalamazonia.com/wp-content/uploads/2022/07/b2ap3_large_mercadao.jpg'
            ]
          },
          {
            'nome': 'Praia da Ponta Negra',
            'fotos': [
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRW8BZe2_R0dlgAaWQej-egmDpCoXtHRy7ATtYQ7VxNcWRM_69Rya0JRbo&s=10',
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTXXBM4bt8FIY7aUMSZcjjfre-MAeMDuirhTnuIYDmMuFHK0Sl04elHyi1N&s=10'
            ]
          },
          {
            'nome': 'MUSA - Museu da Amazônia',
            'fotos': [
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQRWcc3hwRqgESasai1xnC7DgABAqN6ejYe9yxtf1WSquOdWJQrjiDxsUId&s=10',
              'https://portalamazonia.com/wp-content/uploads/2023/01/torre-fto-divulgao-musa.JPG'
            ]
          },
          {
            'nome': 'Arquipélago de Anavilhanas',
            'fotos': [
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHczJvdZlr_gJv9RlKWL9WNZDmUkmzYc_2ukbJnmd-ihnpc5G7M5fyWi4&s=10',
              'https://123ecos.com.br/wp-content/uploads/2024/11/Parque-Nacional-de-Anavilhanas-1.jpeg'
            ]
          },
          {
            'nome': 'Palácio Rio Negro',
            'fotos': [
              'https://upload.wikimedia.org/wikipedia/commons/3/31/Pal%C3%A1cio_Rio_Negro%2C_Manaus_1.jpg',
              'https://hweb-images.br-se1.magaluobjects.com/5873d325c19a4207cc40b87c/2ac530df4a30421d9b88a793d18b7699.jpg'
            ]
          },
          {
            'nome': 'Sumaúma Park',
            'fotos': [
              'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/17/c3/6e/1f/20190602-083805-largejpg.jpg?w=900&h=-1&s=1',
              'https://media-cdn.tripadvisor.com/media/photo-s/0b/0e/05/39/entrada-do-parque-sumauma.jpg'
            ]
          },
          {
            'nome': 'Centro de Instrução de Guerra na Selva (CIGS)',
            'fotos': [
              'https://s2-g1.glbimg.com/oWofr1HnKJDTI6wdzDmHRZSFVcM=/0x0:950x600/984x0/smart/filters:strip_icc()/s.glbimg.com/jo/g1/f/original/2013/05/25/fachada_3_do_cigs.jpg',
              'https://www.amazonasemais.com.br/wp-content/uploads/2014/12/cigs10.jpg'
            ]
          },
          {
            'nome': 'Flutuantes do Tarumã',
            'fotos': [
              'https://www.amazonasemais.com.br/wp-content/uploads/2020/06/lotus-flutuante-5.jpg',
              'https://cdn.bncamazonas.com.br/wp-content/uploads/2025/10/Flutuantes-Manaus.jpg'
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
