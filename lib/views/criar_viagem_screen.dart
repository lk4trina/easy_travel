import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../viewmodels/viagem_viewmodel.dart';
import '../services/destino_api_service.dart';
import '../models/cidade_destino.dart';

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

  final DestinoApiService _destinoApiService = DestinoApiService();

  CidadeDestino? _cidadeSelecionada;
  String? _fotoCidadeUrl;

  DateTime? _dataInicio;
  DateTime? _dataFim;

  bool _buscandoFoto = false;
  bool _salvando = false;

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

  Future<void> _salvarViagem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dataInicio == null || _dataFim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione as datas da viagem.'),
          backgroundColor: Color(0xFFEE4343),
        ),
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      if (_cidadeSelecionada != null && _fotoCidadeUrl != null) {
        await FirebaseFirestore.instance
            .collection('cidades')
            .doc(_destinoController.text)
            .set({
          'nome': _cidadeSelecionada?.nome,
          'estado': _cidadeSelecionada?.estado,
          'pais': _cidadeSelecionada?.pais,
          'fotoCidade': _fotoCidadeUrl,
        }, SetOptions(merge: true));
      }

      await Provider.of<ViagemViewModel>(context, listen: false).adicionarViagem(
        destino: _destinoController.text,
        pontoPartida:
            _partidaController.text.isEmpty ? null : _partidaController.text,
        dataInicio: _dataInicio!,
        dataFim: _dataFim!,
        quantidadeViajantes: int.parse(_viajantesController.text),
        cidadeDestino: _cidadeSelecionada,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar viagem: $e'),
            backgroundColor: const Color(0xFFEE4343),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
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
        title: const Text(
          'Nova Viagem',
          style: TextStyle(
            color: Color(0xFFEEA243),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFFEEA243),
          ),
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
                errorBuilder: (c, e, s) => const Icon(
                  Icons.map,
                  size: 100,
                  color: Color(0xFFEEA243),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Qual seu destino?',
                style: TextStyle(
                  color: Color(0xFFEEA243),
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Autocomplete<CidadeDestino>(
                displayStringForOption: (cidade) => cidade.label,
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (textEditingValue.text.trim().length < 2) {
                    return const Iterable<CidadeDestino>.empty();
                  }

                  return await _destinoApiService.buscarCidades(
                    textEditingValue.text,
                  );
                },
                onSelected: (CidadeDestino cidade) async {
                  setState(() {
                    _cidadeSelecionada = cidade;
                    _destinoController.text = cidade.label;
                    _buscandoFoto = true;
                  });

                  try {
                    final cidadeComFoto =
                        await _destinoApiService.buscarCidadeComFoto(cidade);

                    setState(() {
                      _cidadeSelecionada = cidadeComFoto;
                      _fotoCidadeUrl = cidadeComFoto.fotoUrl;
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Não foi possível buscar a foto: $e'),
                        backgroundColor: const Color(0xFFEE4343),
                      ),
                    );
                  } finally {
                    if (mounted) {
                      setState(() {
                        _buscandoFoto = false;
                      });
                    }
                  }
                },
                fieldViewBuilder: (
                  context,
                  textEditingController,
                  focusNode,
                  onFieldSubmitted,
                ) {
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'Digite uma cidade',
                      prefixIcon: const Icon(
                        Icons.location_on,
                        color: Color(0xFFEEA243),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o destino';
                      }

                      return null;
                    },
                    onChanged: (value) {
                      _destinoController.text = value;
                      _cidadeSelecionada = null;
                      _fotoCidadeUrl = null;
                    },
                  );
                },
              ),

              if (_buscandoFoto)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFEEA243),
                    ),
                  ),
                ),

              if (_fotoCidadeUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _fotoCidadeUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: const Color(0xFFFFF3E0),
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Color(0xFFEEA243),
                            size: 48,
                          ),
                        );
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              const Text(
                'Qual seu ponto de partida (opcional)?',
                style: TextStyle(
                  color: Color(0xFFEEA243),
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _partidaController,
                decoration: InputDecoration(
                  hintText: 'Endereço',
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFFEEA243),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Data e quantidade de viajantes',
                style: TextStyle(
                  color: Color(0xFFEEA243),
                  fontWeight: FontWeight.bold,
                ),
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
                          prefixIcon: const Icon(
                            Icons.calendar_today,
                            color: Color(0xFFEEA243),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Color(0xFFEEA243),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        final quantidade = int.tryParse(value ?? '');

                        if (quantidade == null || quantidade <= 0) {
                          return 'Inválido';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEEA243),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _salvando ? null : _salvarViagem,
                child: Text(
                  _salvando ? 'Salvando...' : 'Adicionar itinerário',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}