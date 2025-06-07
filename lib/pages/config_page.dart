import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/turma.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Turma> turmas = [];
  Turma? turmaSelecionada;
  bool carregando = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    _carregarTurmas();
  }

  Future<void> _carregarTurmas() async {
    try {
      final response =
          await supabase
              .from('turmas')
              .select()
              .order('nomeDoCurso')
              .order('semestre')
              .execute();

      if (response.status != 200 && response.status != 201) {
        setState(() {
          erro = 'Erro ao buscar turmas: status ${response.status}';
          carregando = false;
        });
        return;
      }

      final data = response.data;

      if (data == null || data is! List) {
        setState(() {
          erro = 'Dados de turmas inválidos.';
          carregando = false;
        });
        return;
      }

      setState(() {
        turmas =
            data.map((e) => Turma.fromMap(e as Map<String, dynamic>)).toList();
        carregando = false;
      });
    } catch (e) {
      setState(() {
        erro = 'Erro ao carregar turmas: $e';
        carregando = false;
      });
    }
  }

  Future<void> _salvarConfiguracao() async {
    if (turmaSelecionada == null || turmaSelecionada!.semestre == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um curso e semestre válidos.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('curso_id', turmaSelecionada!.id);
    await prefs.setInt('semestre', turmaSelecionada!.semestre!);

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      appBar: AppBar(
        title: const Text(
          'Configurar Turma',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // texto branco
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            carregando
                ? const Center(child: CircularProgressIndicator())
                : erro != null
                ? Center(
                  child: Text(
                    erro!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
                : Column(
                  children: [
                    DropdownButtonFormField<Turma>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Selecione o curso e semestre',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          turmas.map((turma) {
                            return DropdownMenuItem<Turma>(
                              value: turma,
                              child: Text(turma.toString()),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          turmaSelecionada = value;
                        });
                      },
                      value: turmaSelecionada,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _salvarConfiguracao,
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar e continuar'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
