import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodels/viagem_viewmodel.dart';

class CriarDespesaScreen extends StatefulWidget {
  final String viagemId;
  const CriarDespesaScreen({super.key, required this.viagemId});

  @override
  State<CriarDespesaScreen> createState() => _CriarDespesaScreenState();
}

class _CriarDespesaScreenState extends State<CriarDespesaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoriaController = TextEditingController();
  final _valorController = TextEditingController();
  DateTime _dataSelecionada = DateTime.now();
  bool _isIndividual = true;
  File? _imagemRecibo;

  final List<String> _categorias = [
    'Transporte',
    'Acomodação',
    'Restaurante',
    'Geral',
    'Entretenimento',
    'Ingressos',
    'Compras',
    'Outros',
  ];

  Future<void> _tirarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imagemRecibo = File(pickedFile.path);
      });
    }
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFEEA243)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
      });
    }
  }

  void _salvarDespesa() {
    if (_formKey.currentState!.validate()) {
      Provider.of<ViagemViewModel>(context, listen: false).adicionarDespesa(
        widget.viagemId,
        categoria: _categoriaController.text,
        valor: double.parse(_valorController.text.replaceAll(',', '.')),
        data: _dataSelecionada,
        isIndividual: _isIndividual,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEA243),
        title: const Text('Criar Despesa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Selecione a categoria', style: TextStyle(color: Color(0xFFEEA243), fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return _categorias.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (String selection) => _categoriaController.text = selection,
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'Digite o gasto',
                      suffixIcon: const Icon(Icons.label_outline, color: Color(0xFFEEA243)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) => _categoriaController.text = val,
                    validator: (value) => value!.isEmpty ? 'Informe a categoria' : null,
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text('Digite o valor', style: TextStyle(color: Color(0xFFEEA243), fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isIndividual = !_isIndividual),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(_isIndividual ? Icons.person : Icons.group, color: const Color(0xFFEEA243)),
                          const SizedBox(width: 4),
                          Text(_isIndividual ? 'Eu' : 'Grupo', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _valorController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        prefixText: 'R\$ ',
                        hintText: '0,00',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => value!.isEmpty ? 'Informe o valor' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Recibo (Câmera)', style: TextStyle(color: Color(0xFFEEA243), fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _tirarFoto,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _imagemRecibo == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 50, color: Color(0xFFEEA243)),
                            Text('Toque para tirar foto do recibo', style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imagemRecibo!, fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Selecione a data', style: TextStyle(color: Color(0xFFEEA243), fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selecionarData(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(DateFormat('dd/MM/yyyy').format(_dataSelecionada)),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEE4343)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar', style: TextStyle(color: Color(0xFFEE4343), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEEA243),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _salvarDespesa,
                      child: const Text('Salvar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
