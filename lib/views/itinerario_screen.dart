import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/viagem.dart';
import '../viewmodels/viagem_viewmodel.dart';
import 'gastos_screen.dart';

class ItinerarioScreen extends StatefulWidget {
  final Viagem viagem;
  const ItinerarioScreen({super.key, required this.viagem});

  @override
  State<ItinerarioScreen> createState() => _ItinerarioScreenState();
}

class _ItinerarioScreenState extends State<ItinerarioScreen> {
  String _urlFotoCidade = '';
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _buscarDadosFirebase();
  }

  Future<void> _buscarDadosFirebase() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('cidades')
          .doc(widget.viagem.destino)
          .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _urlFotoCidade = data?['fotoCidade'] ?? '';
          _carregando = false;
        });
      } else {
        setState(() => _carregando = false);
      }
    } catch (e) {
      setState(() => _carregando = false);
    }
  }

  void _mostrarMenuConfiguracoes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Color(0xFFEE4343)),
                  title: const Text(
                    'Excluir Itinerário',
                    style: TextStyle(color: Color(0xFFEE4343), fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmarExclusao(context);
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Itinerário?'),
        content: const Text('Tem certeza que deseja apagar esta viagem permanentemente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ViagemViewModel>(context, listen: false).excluirViagem(widget.viagem.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Excluir', style: TextStyle(color: Color(0xFFEE4343))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Consumer<ViagemViewModel>(
        builder: (context, viewModel, child) {
          final viagemAtual = viewModel.viagens.firstWhere(
                (v) => v.id == widget.viagem.id,
            orElse: () => widget.viagem,
          );

          return CustomScrollView(
            clipBehavior: Clip.none,
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFFEEA243),
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    clipBehavior: Clip.none,
                    fit: StackFit.expand,
                    children: [
                      _urlFotoCidade.isNotEmpty
                          ? Image.network(_urlFotoCidade, fit: BoxFit.cover)
                          : Container(color: const Color(0xFFEEA243)),

                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.85,
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEA243),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  viagemAtual.destino,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.calendar_today, color: Colors.white, size: 14),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${DateFormat('dd/MM/yyyy').format(viagemAtual.dataInicio)} - ${DateFormat('dd/MM/yyyy').format(viagemAtual.dataFim)}',
                                      style: const TextStyle(color: Colors.white, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, color: Color(0xFFEEA243)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Color(0xFFEEA243)),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(
                      icon: const Icon(Icons.settings, color: Color(0xFFEEA243)),
                      onPressed: () => _mostrarMenuConfiguracoes(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTopIcon(Icons.hotel, 'Acomodação'),
                          _buildTopIcon(Icons.flight, 'Transporte'),
                          _buildTopIcon(Icons.attach_money, 'Despesas', onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GastosScreen(viagemId: viagemAtual.id),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildSectionHeader('Itinerário'),
                      const SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            height: 180,
                            child: GoogleMap(
                              initialCameraPosition: const CameraPosition(
                                target: LatLng(-27.595, -48.548),
                                zoom: 12,
                              ),
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildInfoSection(
                        'Acomodação',
                        Icons.hotel,
                        'Toque no + para adicionar seus hotéis e acomodações',
                        imagePath: 'assets/images/acomodacao.png',
                        onAdd: () => _mostrarDialogoAcomodacao(context, viagemAtual.id),
                        items: viagemAtual.acomodacoes.map((e) => e.nome).toList(),
                      ),
                      _buildInfoSection(
                        'Transporte',
                        Icons.directions_car,
                        'Toque no + para adicionar seu transporte',
                        imagePath: 'assets/images/transporte.png',
                        onAdd: () => _mostrarDialogoTransporte(context, viagemAtual.id),
                        items: viagemAtual.transportes.map((e) => '${e.tipo}: ${e.detalhes}').toList(),
                      ),
                      _buildInfoSection(
                        'Despesas',
                        Icons.payments,
                        'Toque no + para adicionar uma despesa',
                        imagePath: 'assets/images/despesas.png',
                        onAdd: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GastosScreen(viagemId: viagemAtual.id),
                            ),
                          );
                        },
                        items: viagemAtual.despesas.isEmpty
                            ? null
                            : [
                          'Minhas Despesas: R\$ ${viewModel.calcularTotalIndividual(viagemAtual.id).toStringAsFixed(2)}',
                          'Total Grupo: R\$ ${viewModel.calcularTotalGrupo(viagemAtual.id).toStringAsFixed(2)}',
                        ],
                      ),
                      _buildInfoSection(
                        'Check-list',
                        Icons.checklist,
                        'Toque no + para adicionar uma check-list',
                        imagePath: 'assets/images/checklist.png',
                        onAdd: () => _mostrarDialogoCheckList(context, viagemAtual.id),
                        items: viagemAtual.checkList.map((e) => e.titulo).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          decoration: const BoxDecoration(
            color: Color(0xFFEEA243),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.search, color: Colors.white, size: 28),
              Icon(Icons.work, color: Colors.white, size: 28),
              Icon(Icons.explore, color: Colors.white, size: 28),
              Icon(Icons.favorite_border, color: Colors.white, size: 28),
              Icon(Icons.person_outline, color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopIcon(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEEA243).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFFEEA243)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEEA243),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFEEA243)),
          ],
        ),
        const Icon(Icons.add, color: Color(0xFFEEA243)),
      ],
    );
  }

  Widget _buildInfoSection(
      String title,
      IconData icon,
      String subtitle, {
        required String imagePath,
        required VoidCallback onAdd,
        List<String>? items,
      }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFEEA243)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEEA243),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFEEA243)),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFFEEA243)),
              onPressed: onAdd,
            ),
          ],
        ),
        if (items == null || items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                Image.asset(
                  imagePath,
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => const Icon(Icons.image_outlined, size: 60, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(
                items[index],
                style: const TextStyle(color: Color(0xFFEEA243), fontSize: 14),
              ),
              trailing: title == 'Despesas'
                  ? const Icon(Icons.chevron_right, color: Color(0xFFEEA243), size: 16)
                  : null,
              dense: true,
              onTap: title == 'Despesas' ? onAdd : null,
            ),
          ),
        const Divider(),
      ],
    );
  }

  void _mostrarDialogoAcomodacao(BuildContext context, String viagemId) {
    final nomeController = TextEditingController();
    final localController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Acomodação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(
                controller: localController, decoration: const InputDecoration(labelText: 'Localização')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final acomodacao = Acomodacao(nome: nomeController.text, localizacao: localController.text);
              Provider.of<ViagemViewModel>(context, listen: false).adicionarAcomodacao(viagemId, acomodacao);
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoTransporte(BuildContext context, String viagemId) {
    final tipoController = TextEditingController();
    final detalhesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Transporte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: tipoController,
                decoration: const InputDecoration(labelText: 'Tipo (Ex: Avião, Carro)')),
            TextField(controller: detalhesController, decoration: const InputDecoration(labelText: 'Detalhes')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final transporte =
              Transporte(tipo: tipoController.text, detalhes: detalhesController.text);
              Provider.of<ViagemViewModel>(context, listen: false).adicionarTransporte(viagemId, transporte);
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoCheckList(BuildContext context, String viagemId) {
    final tituloController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Item'),
        content: TextField(
            controller: tituloController, decoration: const InputDecoration(labelText: 'Título')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final item = CheckItem(titulo: tituloController.text);
              Provider.of<ViagemViewModel>(context, listen: false).adicionarCheckItem(viagemId, item);
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}