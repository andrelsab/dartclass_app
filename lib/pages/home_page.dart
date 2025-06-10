import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/ensalamento_repository.dart';
import '../models/ensalamento.dart';
import 'ensalamento_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  late EnsalamentoRepository repository;
  List<Ensalamento> todosEnsalamentos = [];
  List<Ensalamento> ensalamentosFiltrados = [];
  bool carregando = true;
  String? mensagem;
  int diaSelecionadoIndex = (DateTime.now().weekday - 1).clamp(0, 4);
  String? cursoId;
  int? semestre;

  final diasSemana = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'];

  @override
  void initState() {
    super.initState();
    repository = EnsalamentoRepository(Supabase.instance.client);
    carregarEnsalamentos();
  }

  Future<void> carregarEnsalamentos() async {
    final prefs = await SharedPreferences.getInstance();
    cursoId = prefs.getString('curso_id');
    semestre = prefs.getInt('semestre');

    if (cursoId == null || semestre == null) {
      setState(() {
        carregando = false;
        mensagem = 'Por favor, configure seu curso e semestre.';
      });
      return;
    }

    try {
      final lista = await repository.buscarEnsalamentosFiltrados(
        cursoId!,
        semestre!,
      );
      setState(() {
        todosEnsalamentos = lista;
        aplicarFiltroDia();
        mensagem =
            lista.isEmpty
                ? 'Nenhum ensalamento encontrado para seu curso e semestre.'
                : null;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        carregando = false;
        mensagem = 'Erro ao carregar ensalamentos:\n${e.toString()}';
      });
    }
  }

  void aplicarFiltroDia() {
    final diaSelecionado = diasSemana[diaSelecionadoIndex];
    setState(() {
      ensalamentosFiltrados =
          todosEnsalamentos
              .where(
                (e) =>
                    e.diaDaSemana.toLowerCase() == diaSelecionado.toLowerCase(),
              )
              .toList();
      // Ordena por nome da sala e semestre do primeiro horário
      ensalamentosFiltrados.sort((a, b) {
        final nomeA = a.sala?.nome.toLowerCase() ?? '';
        final nomeB = b.sala?.nome.toLowerCase() ?? '';
        final cmpNome = nomeA.compareTo(nomeB);
        if (cmpNome != 0) return cmpNome;
        final semA = a.primeiroCurso?.semestre ?? 0;
        final semB = b.primeiroCurso?.semestre ?? 0;
        return semA.compareTo(semB);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildEnsalamentoPage(),
      const EnsalamentoPage(), // ← Adicione sua página aqui
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      appBar: AppBar(
        title: const Text(
          'DartClass',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/config');
            },
          ),
        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 12,
        iconSize: 30,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Ensalamento',
          ),
        ],
      ),
    );
  }

  Widget _buildEnsalamentoPage() {
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    // Cria uma lista temporária de todos os horários do usuário, com campo horarioNum
    final List<_CardHorario> horarios = [];
    for (final e in ensalamentosFiltrados) {
      if (e.primeiroCurso?.id == cursoId) {
        horarios.add(
          _CardHorario(
            curso: e.primeiroCurso?.nomeDoCurso ?? 'Curso desconhecido',
            semestre: e.primeiroCurso?.semestre ?? 0,
            sala: e.sala?.nome ?? 'N/A',
            horario: '1º Horário',
            horarioNum: 1,
          ),
        );
      }
      if (e.segundoCurso?.id == cursoId) {
        horarios.add(
          _CardHorario(
            curso: e.segundoCurso?.nomeDoCurso ?? 'Curso desconhecido',
            semestre: e.segundoCurso?.semestre ?? 0,
            sala: e.sala?.nome ?? 'N/A',
            horario: '2º Horário',
            horarioNum: 2,
          ),
        );
      }
    }

    // Ordena: nome da sala e horarioNum (1 antes de 2), semestre só se quiser separar turmas diferentes
    horarios.sort((a, b) {
      final cmpSala = a.sala.toLowerCase().compareTo(b.sala.toLowerCase());
      if (cmpSala != 0) return cmpSala;
      // Se quiser manter o semestre como critério secundário, descomente a linha abaixo:
      // final cmpSem = a.semestre.compareTo(b.semestre);
      // if (cmpSem != 0) return cmpSem;
      return a.horarioNum.compareTo(b.horarioNum);
    });

    final List<Widget> cards =
        horarios
            .map(
              (h) => EnsalamentoCard(
                curso: h.curso,
                semestre: h.semestre,
                sala: h.sala,
                horario: h.horario,
              ),
            )
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: diasSemana.length,
            itemBuilder: (context, index) {
              final isSelected = index == diaSelecionadoIndex;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ChoiceChip(
                  label: Text(
                    diasSemana[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.blue,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      diaSelecionadoIndex = index;
                      aplicarFiltroDia();
                    });
                  },
                  selectedColor: Colors.blueAccent,
                  backgroundColor: Colors.white,
                  elevation: isSelected ? 4 : 1,
                  showCheckmark: false,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Aulas de ${diasSemana[diaSelecionadoIndex]}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child:
              cards.isEmpty
                  ? Center(
                    child: Text(
                      mensagem ?? 'Nenhuma aula para este dia.',
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                  : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: cards,
                  ),
        ),
      ],
    );
  }
}

// Classe auxiliar interna para ordenar corretamente os cards
class _CardHorario {
  final String curso;
  final int semestre;
  final String sala;
  final String horario;
  final int horarioNum; // 1 para 1º Horário, 2 para 2º Horário
  _CardHorario({
    required this.curso,
    required this.semestre,
    required this.sala,
    required this.horario,
    required this.horarioNum,
  });
}

class EnsalamentoCard extends StatelessWidget {
  final String curso;
  final int semestre;
  final String sala;
  final String horario;

  const EnsalamentoCard({
    super.key,
    required this.curso,
    required this.semestre,
    required this.sala,
    required this.horario,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.book, size: 40, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$curso - $semestreº semestre',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sala: $sala',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  horario,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
