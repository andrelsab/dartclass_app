// ignore_for_file: deprecated_member_use

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
  List<String> cursos = [];
  List<int> semestres = [];
  List<String> turnos = [];

  String? cursoSelecionado;
  int? semestreSelecionado;
  String? turnoSelecionado;

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

      turmas =
          data.map((e) => Turma.fromMap(e as Map<String, dynamic>)).toList();
      cursos =
          turmas.map((t) => t.nomeDoCurso).whereType<String>().toSet().toList();
      semestres =
          turmas.map((t) => t.semestre).whereType<int>().toSet().toList()
            ..sort();
      turnos = turmas.map((t) => t.turno).whereType<String>().toSet().toList();

      setState(() {
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
    final turmaSelecionada = turmas.firstWhere(
      (t) =>
          t.nomeDoCurso == cursoSelecionado &&
          t.semestre == semestreSelecionado &&
          t.turno == turnoSelecionado,
      orElse: () => Turma(id: '', nomeDoCurso: null),
    );

    if (turmaSelecionada.id.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma combinação válida.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('curso_id', turmaSelecionada.id);
    await prefs.setInt('semestre', turmaSelecionada.semestre!);

    // Verifica se pode voltar ou substitui pela Home
    if (!mounted) return;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Configurar Turma',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Curso',
                        border: OutlineInputBorder(),
                      ),
                      value: cursoSelecionado,
                      items:
                          cursos
                              .map(
                                (curso) => DropdownMenuItem(
                                  value: curso,
                                  child: Text(curso),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          cursoSelecionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Semestre',
                        border: OutlineInputBorder(),
                      ),
                      value: semestreSelecionado,
                      items:
                          semestres
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text('$sº semestre'),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          semestreSelecionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Turno',
                        border: OutlineInputBorder(),
                      ),
                      value: turnoSelecionado,
                      items:
                          turnos
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          turnoSelecionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _salvarConfiguracao,
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar e continuar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
