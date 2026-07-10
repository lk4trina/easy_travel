import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../viewmodels/viagem_viewmodel.dart';
import '../models/viagem.dart';
import 'itinerario_screen.dart';
import 'criar_viagem_screen.dart';
import 'conta_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEA243),
        title: const Text(
          'EasyTravel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Consumer<ViagemViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.viagens.isEmpty) {
            return _buildEmptyState(context);
          }

          return Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: PageView.builder(
                    itemCount: viewModel.viagens.length,
                    controller: PageController(viewportFraction: 0.8),
                    itemBuilder: (context, index) {
                      final viagem = viewModel.viagens[index];
                      return _buildViagemCard(context, viagem);
                    },
                  ),
                ),
              ),
              Positioned(
                right: 30,
                bottom: 100,
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFFEEA243),
                  shape: const CircleBorder(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CriarViagemScreen()),
                    );
                  },
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              )
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(    height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFEEA243),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const _BottomNavItem(icon: Icons.search, label: 'Pesquisar'),
            const _BottomNavItem(icon: Icons.work, label: 'Itinerário', isSelected: true),
            const _BottomNavItem(icon: Icons.explore, label: 'Descobrir'),
            const _BottomNavItem(icon: Icons.favorite_border, label: 'Favoritos'),
            _BottomNavItem(
              icon: Icons.person_outline,
              label: 'Perfil',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ContaScreen()));
              },
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildViagemCard(BuildContext context, Viagem viagem) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('cidades').doc(viagem.destino).get(),
      builder: (context, snapshot) {
        String? imageUrl;
        if (snapshot.hasData && snapshot.data!.exists) {
          imageUrl = snapshot.data!['fotoCidade'];
        }

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ItinerarioScreen(viagem: viagem)),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: imageUrl != null
                        ? Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                        : Container(color: Colors.grey[300], child: const Icon(Icons.image, size: 50)),
                  ),
                ),

                Positioned(
                  top: 15,
                  right: 15,
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.add, size: 18, color: Color(0xFFEEA243)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Color(0xFFEEA243), shape: BoxShape.circle),
                        child: const Icon(Icons.download, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),


                Positioned(
                  bottom: -25,
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEA243),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          viagem.destino.split(',')[0],
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.white, size: 10),
                            const SizedBox(width: 5),
                            Text(
                              '${DateFormat('dd/MM/yyyy').format(viagem.dataInicio)} - ${DateFormat('dd/MM/yyyy').format(viagem.dataFim)}',
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Faça sua\nprimeira viagem!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFEEA243),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Image.asset(
              'assets/images/janela_aviao.png',
              width: 250,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.airplanemode_active, size: 150, color: Color(0xFFEEA243)),
            ),
            const SizedBox(height: 40),
            _buildCustomButton(
              context: context,
              label: 'Criar viagem',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CriarViagemScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildCustomButton(context: context, label: 'Participar de viagem', onPressed: () {}),
            const SizedBox(height: 16),
            _buildCustomButton(context: context, label: 'Descobrir viagens', onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButton({required BuildContext context, required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEEA243),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  const _BottomNavItem({required this.icon, required this.label, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.white70, size: 28),
          Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}
