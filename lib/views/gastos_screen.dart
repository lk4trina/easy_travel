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
        title: const Text('Gastos', style: TextStyle(color: Colors.white)),
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
                padding: const EdgeInsets.all(24.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Text(
                      currencyFormat.format(total),
                      style: const TextStyle(
                        color: Color(0xFFEEA243),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
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
            MaterialPageRoute(
              builder: (context) => CriarDespesaScreen(viagemId: widget.viagemId),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildExpensesList(List despesas, NumberFormat currencyFormat) {
    if (despesas.isEmpty) {
      return const Center(
        child: Text('Nenhuma despesa registrada.', style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text('Categoria', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Valor', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Data', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: despesas.length,
            itemBuilder: (context, index) {
              final despesa = despesas[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    Icon(_getCategoryIcon(despesa.categoria), color: const Color(0xFFEEA243)),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(despesa.categoria, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(DateFormat('dd/MM/yyyy').format(despesa.data), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        currencyFormat.format(despesa.valor),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Expanded(flex: 2, child: SizedBox()),
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
      case 'transporte': return Icons.directions_car;
      case 'alimentação': return Icons.restaurant;
      case 'hospedagem': return Icons.hotel;
      case 'ingressos': return Icons.confirmation_number;
      default: return Icons.attach_money;
    }
  }
}
