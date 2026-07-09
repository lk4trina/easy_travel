import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/viagem_viewmodel.dart';
import 'criar_despesa_screen.dart';

class GastosScreen extends StatefulWidget {
  final String viagemId;
  const GastosScreen({super.key, required this.viagemId});

  @override
  State<GastosScreen> createState() => _GastosScreenState();
}

class _GastosScreenState extends State<GastosScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEA243),
        title: const Text('Gastos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Consumer<ViagemViewModel>(
        builder: (context, viewModel, child) {
          final viagem = viewModel.viagens.firstWhere((v) => v.id == widget.viagemId);
          final totalIndividual = viewModel.calcularTotalIndividual(widget.viagemId);
          final totalGrupo = viewModel.calcularTotalGrupo(widget.viagemId);
          final total = totalIndividual + totalGrupo;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  children: [
                    Text(
                      currencyFormat.format(total),
                      style: const TextStyle(color: Color(0xFFEEA243), fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TabBar(
                      controller: _tabController,
                      indicatorColor: const Color(0xFFEEA243),
                      labelColor: const Color(0xFFEEA243),
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: 'Individual'),
                        Tab(text: 'Grupo'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildExpensesList(viagem.despesas.where((d) => d.isIndividual).toList(), currencyFormat),
                    _buildExpensesList(viagem.despesas.where((d) => !d.isIndividual).toList(), currencyFormat),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEEA243),
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CriarDespesaScreen(viagemId: widget.viagemId)),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildExpensesList(List despesas, NumberFormat currencyFormat) {
    if (despesas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/despesas.png', height: 120, errorBuilder: (c,e,s) => const Icon(Icons.monetization_on, size: 80, color: Color(0xFFEEA243))),
            const SizedBox(height: 16),
            const Text('Nenhuma despesa registrada.', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          color: Colors.grey.shade50,
          child: const Row(
            children: [
              SizedBox(width: 32),
              Expanded(flex: 4, child: Text('Categoria', style: TextStyle(color: Color(0xFFEEA243), fontWeight: FontWeight.bold))),
              Expanded(flex: 3, child: Text('Valor', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFEEA243), fontWeight: FontWeight.bold))),
              Expanded(flex: 3, child: Text('Data', textAlign: TextAlign.right, style: TextStyle(color: Color(0xFFEEA243), fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: despesas.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF5F5F5)),
            itemBuilder: (context, index) {
              final despesa = despesas[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Icon(_getCategoryIcon(despesa.categoria), color: const Color(0xFFEEA243), size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: Text(despesa.categoria, style: const TextStyle(color: Color(0xFFEEA243))),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        currencyFormat.format(despesa.valor),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFEEA243)),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(despesa.data),
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Color(0xFFEEA243)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'transporte': return Icons.flight_takeoff;
      case 'acomodação': return Icons.hotel;
      case 'restaurante': return Icons.restaurant;
      case 'geral': return Icons.local_offer;
      case 'entretenimento': return Icons.theater_comedy;
      case 'ingressos': return Icons.confirmation_number;
      case 'compras': return Icons.shopping_bag;
      default: return Icons.attach_money;
    }
  }
}
