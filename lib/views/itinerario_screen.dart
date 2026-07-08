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
          final viagemAtual = viewModel.viagens.firstWhere((v) => v.id == widget.viagem.id, orElse: () => widget.viagem);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFFEEA243),
                flexibleSpace: FlexibleSpaceBar(
                  background: _urlFotoCidade.isNotEmpty
                      ? Image.network(_urlFotoCidade, fit: BoxFit.cover)
                      : Container(color: const Color(0xFFEEA243)),
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFFEEA243)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.person_add, color: Color(0xFFEEA243)),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.settings, color: Color(0xFFEEA243)),
                      onPressed: () => _confirmarExclusao(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 0),
                      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
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
                                  MaterialPageRoute(builder: (context) => GastosScreen(viagemId: viagemAtual.id)),
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 30),
                          _buildSectionHeader('Itinerário'),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              height: 200,
                              child: GoogleMap(
                                initialCameraPosition: const CameraPosition(
                                  target: LatLng(-27.5953778, -48.5480499),
                                  zoom: 12,
                                ),
                                myLocationButtonEnabled: false,
                                zoomControlsEnabled: false,
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
                                MaterialPageRoute(builder: (context) => GastosScreen(viagemId: viagemAtual.id)),
                              );
                            },
                            items: [
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
                    Positioned(
                      top: -40,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEA243),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Column(
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
                            Text(
                              '${DateFormat('dd/MM/yyyy').format(viagemAtual.dataInicio)} - ${DateFormat('dd/MM/yyyy').format(viagemAtual.dataFim)}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Color(0xFFEEA243),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.search, color: Colors.white),
            Icon(Icons.work, color: Colors.white),
            Icon(Icons.explore, color: Colors.white),
            Icon(Icons.favorite_border, color: Colors.white),
            Icon(Icons.person_outline, color: Colors.white),
          ],
        ),
      ),
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
            TextField(controller: localController, decoration: const InputDecoration(labelText: 'Localização')),
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
            TextField(controller: tipoController, decoration: const InputDecoration(labelText: 'Tipo (Ex: Avião, Carro)')),
            TextField(controller: detalhesController, decoration: const InputDecoration(labelText: 'Detalhes')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final transporte = Transporte(tipo: tipoController.text, detalhes: detalhesController.text);
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
        content: TextField(controller: tituloController, decoration: const InputDecoration(labelText: 'Título')),
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

  Widget _buildTopIcon(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEEA243),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
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

  Widget _buildInfoSection(String title, IconData icon, String subtitle, {required String imagePath, required VoidCallback onAdd, List<String>? items}) {
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
                Image.asset(imagePath, height: 80, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.image_outlined, size: 60, color: Colors.grey)),
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
              title: Text(items[index], style: const TextStyle(fontSize: 14)),
              trailing: title == 'Despesas' ? const Icon(Icons.chevron_right, size: 16) : null,
              dense: true,
              onTap: title == 'Despesas' ? onAdd : null,
            ),
          ),
        const Divider(),
      ],
    );
  }
}
