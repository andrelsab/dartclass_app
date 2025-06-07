import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ensalamento.dart';
import '../repositories/ensalamento_repository.dart';

class EnsalamentoPage extends StatefulWidget {
  const EnsalamentoPage({super.key});

  @override
  State<EnsalamentoPage> createState() => _EnsalamentoPageState();
}

class _EnsalamentoPageState extends State<EnsalamentoPage> {
  final EnsalamentoRepository _repository = EnsalamentoRepository(
    Supabase.instance.client,
  );

  List<Ensalamento> ensalamentos = [];
  List<String> blocos = [];
  String? blocoSelecionado;
  String diaSelecionado = '';
  bool carregando = true;

  final List<String> diasDaSemana = [
    'segunda',
    'terça',
    'quarta',
    'quinta',
    'sexta',
  ];

  @override
  void initState() {
    super.initState();
    diaSelecionado = _diaAtual();
    inicializar();
    carregarDados();
  }

  String _diaAtual() {
    final hoje = DateTime.now().weekday;
    switch (hoje) {
      case DateTime.monday:
        return 'segunda';
      case DateTime.tuesday:
        return 'terça';
      case DateTime.wednesday:
        return 'quarta';
      case DateTime.thursday:
        return 'quinta';
      case DateTime.friday:
        return 'sexta';
      default:
        return 'segunda';
    }
  }

  String _dataFormatada() {
    return DateFormat('EEEE, d \'de\' MMMM', 'pt_BR').format(DateTime.now());
  }

Future<void> inicializar() async {
  setState(() => carregando = true);

  blocos = await _repository.listarBlocos();

  // Define o bloco C como padrão, se existir
  if (blocos.contains('C')) {
    blocoSelecionado = 'C';
  } else if (blocos.isNotEmpty) {
    blocoSelecionado = blocos.first;
  }

  ensalamentos = await _repository.buscarEnsalamentosPorDiaEBloco(
    diaSelecionado,
    blocoSelecionado,
  );

  setState(() => carregando = false);
}


  Future<void> carregarDados() async {
    setState(() => carregando = true);

    blocos = await _repository.listarBlocos();
    ensalamentos = await _repository.buscarEnsalamentosPorDiaEBloco(
      diaSelecionado,
      blocoSelecionado,
    );

    setState(() => carregando = false);
  }

  void aplicarFiltro({String? novoDia, String? novoBloco}) async {
    setState(() {
      if (novoDia != null) diaSelecionado = novoDia;
      if (novoBloco != null) blocoSelecionado = novoBloco;
      carregando = true;
    });

    ensalamentos = await _repository.buscarEnsalamentosPorDiaEBloco(
      diaSelecionado,
      blocoSelecionado,
    );

    setState(() => carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      body:
          carregando
              ? const Center(child: CircularProgressIndicator())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _dataFormatada(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: diaSelecionado,
                            isExpanded: true,
                            items:
                                diasDaSemana.map((dia) {
                                  return DropdownMenuItem(
                                    value: dia,
                                    child: Text(
                                      dia[0].toUpperCase() + dia.substring(1),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) aplicarFiltro(novoDia: value);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButton<String>(
                            hint: const Text('Bloco'),
                            value: blocoSelecionado,
                            isExpanded: true,
                            items:
                                blocos.map((bloco) {
                                  return DropdownMenuItem<String>(
                                    value: bloco,
                                    child: Text(bloco),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              aplicarFiltro(novoBloco: value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        ensalamentos.isEmpty
                            ? const Center(
                              child: Text('Nenhum ensalamento encontrado.'),
                            )
                            : ListView.builder(
                              itemCount: ensalamentos.length,
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index) {
                                final e = ensalamentos[index];

                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Sala ${e.sala?.nome ?? 'N/A'} - ${e.sala?.bloco ?? 'N/A'}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0077C2),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        if (e.primeiroCurso != null)
                                          Text(
                                            '1º Horário: ${e.primeiroCurso!.nomeDoCurso} - ${e.primeiroCurso!.semestre}º semestre',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        if (e.segundoCurso != null)
                                          Text(
                                            '2º Horário: ${e.segundoCurso!.nomeDoCurso} - ${e.segundoCurso!.semestre}º semestre',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
