import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/viagem_viewmodel.dart';
import 'itinerario_screen.dart';
import 'criar_viagem_screen.dart';

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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Consumer<ViagemViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.viagens.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: viewModel.viagens.length,
            itemBuilder: (context, index) {
              final viagem = viewModel.viagens[index];
              return Card(
                color: const Color(0xFFD9D9D9),
                margin: const EdgeInsets.only(bottom: 16.0),
                child: ListTile(
                  title: Text(
                    viagem.destino,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Viajantes: ${viagem.quantidadeViajantes}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFEEA243)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItinerarioScreen(viagem: viagem),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFEEA243),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Pesquisar'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Itinerário'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Descobrir'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Faça sua\nprimeira viagem!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFEEA243),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Image.asset(
              'assets/images/janela_aviao.png',
              width: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            _buildCustomButton(
              context: context,
              label: 'Criar viagem',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CriarViagemScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildCustomButton(
              context: context,
              label: 'Participar de viagem',
              onPressed: () {},
            ),
            const SizedBox(height: 16),
            _buildCustomButton(
              context: context,
              label: 'Descobrir viagens',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEEA243),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}