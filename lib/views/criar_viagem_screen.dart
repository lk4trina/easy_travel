import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/viagem_viewmodel.dart';

class CriarViagemScreen extends StatefulWidget {
  const CriarViagemScreen({super.key});

  @override
  State<CriarViagemScreen> createState() => _CriarViagemScreenState();
}

class _CriarViagemScreenState extends State<CriarViagemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinoController = TextEditingController();
  final _partidaController = TextEditingController();
  final _viajantesController = TextEditingController(text: '1');

  DateTime? _dataInicio;
  DateTime? _dataFim;

  final List<String> _locaisSalvos = [
    'Florianópolis, SC - Brasil',
    'Balneário Camboriú, SC - Brasil',
    'Blumenau, SC - Brasil',
    'Joinville, SC - Brasil',
    'Manaus, AM - Brasil',
    'São Paulo, São Paulo - Brasil',
    'Milão, Lombardia - Itália',
    'Miami, Flórida - Estados Unidos'
  ];

  Future<void> _selecionarDatas(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFEEA243),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dataInicio = picked.start;
        _dataFim = picked.end;
      });
    }
  }

  void _salvarViagem() {
    if (_formKey.currentState!.validate() && _dataInicio != null) {
      Provider.of<ViagemViewModel>(context, listen: false).adicionarViagem(
        destino: _destinoController.text,
        pontoPartida: _partidaController.text.isEmpty ? null : _partidaController.text,
        dataInicio: _dataInicio!,
        dataFim: _dataFim!,
        quantidadeViajantes: int.parse(_viajantesController.text),
      );

      Navigator.pop(context);
    } else if (_dataInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione as datas da viagem.'),
          backgroundColor: Color(0xFFEE4343),
        ),
      );
    }
  }

  @override
  void dispose() {
    _destinoController.dispose();
    _partidaController.dispose();
    _viajantesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Nova Viagem', style: TextStyle(color: Color(0xFFEEA243), fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFEEA243)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/images/ilustracao_nova_viagem.png',
                height: 180,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Icon(Icons.map, size: 100, color: Color(0xFFEEA243)),
              ),
              const SizedBox(height: 24),

              const Text(
                'Qual seu destino?',
                style: TextStyle(color: Color(0xFFEEA243), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                  return _locaisSalvos.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (String selection) => _destinoController.text = selection,
                fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                  textController.addListener(() => _destinoController.text = textController.text);
                  return TextFormField(
                    controller: textController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'Cidade, país, região',
                      prefixIcon: const Icon(Icons.location_on, color: Color(0xFFEEA243)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value!.isEmpty ? 'Informe o destino' : null,
                  );
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'Qual seu ponto de partida (opcional)?',
                style: TextStyle(color: Color(0xFFEEA243), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _partidaController,
                decoration: InputDecoration(
                  hintText: 'Endereço',
                  prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFFEEA243)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Data e quantidade de viajantes',
                style: TextStyle(color: Color(0xFFEEA243), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: () => _selecionarDatas(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFFEEA243)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          _dataInicio == null
                              ? 'Selecione'
                              : '${DateFormat('dd/MM/yy').format(_dataInicio!)} - ${DateFormat('dd/MM/yy').format(_dataFim!)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _viajantesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person, color: Color(0xFFEEA243)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEEA243),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _salvarViagem,
                child: const Text(
                  'Adicionar itinerário',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
