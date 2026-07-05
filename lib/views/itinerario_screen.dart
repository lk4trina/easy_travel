import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  List<Map<String, dynamic>> _atracoesFirebase = [];
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
          if (data?['atracoes'] != null) {
            _atracoesFirebase = List<Map<String, dynamic>>.from(data!['atracoes']);
          }
          _carregando = false;
        });
      } else {
        setState(() => _carregando = false);
      }
    } catch (e) {
      setState(() => _carregando = false);
    }
  }

  void _mostrarFotosAtracao(String nomeAtracao, List<dynamic> fotos) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(nomeAtracao, style: const TextStyle(color: Color(0xFFEEA243))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Galeria de Fotos (Firebase):', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: fotos.map((url) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(url, height: 120, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: Color(0xFFEEA243))),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEA243),
        title: Text(widget.viagem.destino, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _urlFotoCidade.isNotEmpty
                ? Image.network(_urlFotoCidade, height: 200, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(height: 200, color: Colors.grey))
                : Container(height: 200, color: const Color(0xFFD9D9D9)),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFFEEA243)),
                      const SizedBox(width: 12),
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(widget.viagem.dataInicio)} - ${DateFormat('dd/MM/yyyy').format(widget.viagem.dataFim)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    '✨ Selecione suas Atrações',
                    style: TextStyle(color: Color(0xFFEEA243), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    children: _atracoesFirebase.map((atracao) {
                      final nome = atracao['nome'] as String;
                      final jaAdicionada = widget.viagem.atracoes.contains(nome);
                      return FilterChip(
                        label: Text(nome),
                        selected: jaAdicionada,
                        selectedColor: const Color(0xFFEEA243).withOpacity(0.3),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              widget.viagem.atracoes.add(nome);
                            } else {
                              widget.viagem.atracoes.remove(nome);
                            }
                          });
                          Provider.of<ViagemViewModel>(context, listen: false).atualizarViagem(widget.viagem);
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    '📍 Meu Roteiro (Toque para ver fotos)',
                    style: TextStyle(color: Color(0xFFEEA243), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  widget.viagem.atracoes.isEmpty
                      ? const Text('Nenhuma atração adicionada ao roteiro.', style: TextStyle(color: Colors.grey))
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.viagem.atracoes.length,
                    itemBuilder: (context, index) {
                      final nomeAtracaoLocal = widget.viagem.atracoes[index];

                      final dadosAtracaoFirebase = _atracoesFirebase.firstWhere(
                            (a) => a['nome'] == nomeAtracaoLocal,
                        orElse: () => {'nome': nomeAtracaoLocal, 'fotos': []},
                      );

                      return Card(
                        color: const Color(0xFFD9D9D9).withOpacity(0.4),
                        child: ListTile(
                          leading: const Icon(Icons.camera_alt, color: Color(0xFFEEA243)),
                          title: Text(nomeAtracaoLocal, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Toque para abrir a galeria', style: TextStyle(fontSize: 11)),
                          onTap: () {
                            if (dadosAtracaoFirebase['fotos'] != null && (dadosAtracaoFirebase['fotos'] as List).isNotEmpty) {
                              _mostrarFotosAtracao(nomeAtracaoLocal, dadosAtracaoFirebase['fotos']);
                            }
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Color(0xFFEE4343)),
                            onPressed: () {
                              setState(() => widget.viagem.atracoes.removeAt(index));
                              Provider.of<ViagemViewModel>(context, listen: false).atualizarViagem(widget.viagem);
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEA243),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GastosScreen(viagemId: widget.viagem.id)),
                      );
                    },
                    icon: const Icon(Icons.monetization_on, color: Colors.white),
                    label: const Text('Ver Finanças e Gastos', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}