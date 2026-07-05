import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/viagem_viewmodel.dart';
// import 'criar_despesa_screen.dart'; // Vamos usar na última tela!

class GastosScreen extends StatelessWidget {
  final String viagemId;

  const GastosScreen({super.key, required this.viagemId});

  @override
  Widget build(BuildContext context) {
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
          final viagem = viewModel.viagens.firstWhere((v) => v.id == viagemId);
          final totalIndividual = viewModel.calcularTotalIndividual(viagemId);
          final totalGrupo = viewModel.calcularTotalGrupo(viagemId);
          final total = totalIndividual + totalGrupo;

          final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                color: const Color(0xFFEEA243).withOpacity(0.1),
                child: Column(
                  children: [
                    Text(
                      currencyFormat.format(total),
                      style: const TextStyle(color: Color(0xFFEEA243), fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildResumoGasto('Individual', totalIndividual, currencyFormat),
                        _buildResumoGasto('Grupo', totalGrupo, currencyFormat),
                      ],
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Categoria', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    Text('Valor', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Divider(height: 1),

              Expanded(
                child: viagem.despesas.isEmpty
                    ? const Center(
                  child: Text('Nenhuma despesa registrada.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                )
                    : ListView.builder(
                  itemCount: viagem.despesas.length,
                  itemBuilder: (context, index) {
                    final despesa = viagem.despesas[index];
                    return ListTile(
                      leading: Icon(
                        despesa.isIndividual ? Icons.person : Icons.group,
                        color: const Color(0xFFEEA243),
                      ),
                      title: Text(despesa.categoria, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(DateFormat('dd/MM/yyyy').format(despesa.data)),
                      trailing: Text(
                        currencyFormat.format(despesa.valor),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEEA243),
        onPressed: () {
          // Vamos adicionar a navegação para a Tela 5 aqui!
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildResumoGasto(String titulo, double valor, NumberFormat formatador) {
    return Column(
      children: [
        Text(titulo, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          formatador.format(valor),
          style: const TextStyle(color: Color(0xFFEEA243), fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}