import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/viagem_viewmodel.dart';
import '../models/viagem.dart';
import '../widgets/custom_bottom_nav.dart';
import 'itinerario_screen.dart';
import 'criar_viagem_screen.dart';
import 'conta_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEA243),
        toolbarHeight: 60,
        title: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            'EasyTravel',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 26,
              fontFamily: 'Pacifico',
            ),
          ),
        ),
        centerTitle: false,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<ViagemViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.viagens.isEmpty) {
              return _buildEmptyState(context);
            }

            return Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 30),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.60,
                      child: PageView.builder(
                        clipBehavior: Clip.none,
                        itemCount: viewModel.viagens.length,
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        itemBuilder: (context, index) {
                          final viagem = viewModel.viagens[index];
                          return _buildViagemCard(context, viagem);
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        viewModel.viagens.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? const Color(0xFFEEA243)
                                : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 5,
                right: 30,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CriarViagemScreen()),
                  ),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEA243),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 50),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
    bottomNavigationBar: const CustomBottomNav(selectedIndex: 1),
  );
}

  Widget _buildViagemCard(BuildContext context, Viagem viagem) {
    final String? imageUrl = viagem.cidadeDestino?.fotoUrl;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItinerarioScreen(viagem: viagem),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, size: 100, color: Colors.white),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image, size: 100, color: Colors.white),
                      ),
              ),
            ),

            Positioned(
              top: 20,
              right: 20,
              child: Row(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage('https://public-cdn-s3-us-west-2.oss-us-east-1.aliyuncs.com/talkie-user-img/93903448822076/200045860827213.jpeg?x-oss-process=image/resize,w_1024/format,webp'),
                      ),
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_circle, size: 14, color: Color(0xFFEEA243)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEA243),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.download, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: -25, // "Vazado"
              child: Container(
                width: 225,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEA243),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      viagem.destino.split(',')[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white, size: 12),
                        const SizedBox(width: 6),
                        Text(
                          '${DateFormat('dd/MM/yyyy').format(viagem.dataInicio)} - ${DateFormat('dd/MM/yyyy').format(viagem.dataFim)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
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
              width: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.airplanemode_active, size: 150, color: Color(0xFFEEA243)),
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

  Widget _buildCustomButton(
      {required BuildContext context, required String label, required VoidCallback onPressed}) {
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
