import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ensalamento.dart';
import '../models/turma.dart';

class EnsalamentoRepository {
  final SupabaseClient client;

  EnsalamentoRepository(this.client);

  Future<List<Ensalamento>> buscarEnsalamentosPorBloco(String bloco) async {
    final response =
        await client.from('ensalamentos').select('''
        id,
        dia_da_semana,
        sala:sala_id(id, nome, bloco),
        primeiroCurso:primeiro_curso_id(id, nomeDoCurso, semestre),
        segundoCurso:segundo_curso_id(id, nomeDoCurso, semestre)
      ''').execute();

    if (response.status != 200 && response.status != 201) {
      throw Exception('Erro ao buscar ensalamentos');
    }

    final data = response.data as List<dynamic>;

    final filtrado =
        data.where((item) {
          final sala = item['sala'];
          return sala != null && sala['bloco'] == bloco;
        }).toList();

    return filtrado.map((e) => Ensalamento.fromMap(e)).toList();
  }

  Future<List<Ensalamento>> buscarEnsalamentosFiltrados(
    String cursoId,
    int semestre,
  ) async {
    if (cursoId.isEmpty || semestre <= 0) {
      return [];
    }

    final response =
        await client
            .from('ensalamentos')
            .select('''
          id,
          dia_da_semana,
          sala:sala_id(id, nome, bloco),
          primeiroCurso:primeiro_curso_id(id, nomeDoCurso, semestre),
          segundoCurso:segundo_curso_id(id, nomeDoCurso, semestre)
        ''')
            .or('primeiro_curso_id.eq.$cursoId,segundo_curso_id.eq.$cursoId')
            .execute();

    if (response.status != 200 && response.status != 201) {
      throw Exception('Erro ao buscar ensalamentos: status {response.status}');
    }

    final data = response.data as List<dynamic>;

    final listaFiltrada =
        data.where((item) {
          final map = item as Map<String, dynamic>;

          final primeiroCurso =
              map['primeiroCurso'] != null
                  ? Turma.fromMap(map['primeiroCurso'] as Map<String, dynamic>)
                  : null;

          final segundoCurso =
              map['segundoCurso'] != null
                  ? Turma.fromMap(map['segundoCurso'] as Map<String, dynamic>)
                  : null;

          return (primeiroCurso?.semestre == semestre) ||
              (segundoCurso?.semestre == semestre);
        }).toList();

    return listaFiltrada
        .map((e) => Ensalamento.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Ensalamento>> buscarTodosEnsalamentos() async {
    final response =
        await client
            .from('ensalamentos')
            .select('''
          id,
          dia_da_semana,
          sala:sala_id(id, nome, bloco),
          primeiroCurso:primeiro_curso_id(id, nomeDoCurso, semestre),
          segundoCurso:segundo_curso_id(id, nomeDoCurso, semestre)
        ''')
            .order('dia_da_semana')
            .execute();

    if (response.status != 200 && response.status != 201) {
      throw Exception('Erro ao buscar ensalamentos: status ${response.status}');
    }

    final data = response.data as List<dynamic>;
    return data
        .map((e) => Ensalamento.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Ensalamento>> buscarPorBloco(String bloco) async {
    final response =
        await client
            .from('ensalamentos')
            .select('''
          id,
          dia_da_semana,
          sala:sala_id(id, nome, bloco),
          primeiroCurso:primeiro_curso_id(id, nomeDoCurso, semestre),
          segundoCurso:segundo_curso_id(id, nomeDoCurso, semestre)
        ''')
            .eq('sala.bloco', bloco)
            .order('dia_da_semana')
            .execute();

    if (response.status != 200 && response.status != 201) {
      throw Exception(
        'Erro ao buscar ensalamentos por bloco: status ${response.status}',
      );
    }

    final data = response.data as List<dynamic>;
    return data
        .map((e) => Ensalamento.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Ensalamento>> buscarEnsalamentosPorDiaEBloco(
    String dia,
    String? bloco,
  ) async {
    final response =
        await client
            .from('ensalamentos')
            .select('''
          id,
          dia_da_semana,
          sala:sala_id(id, nome, bloco),
          primeiroCurso:primeiro_curso_id(id, nomeDoCurso, semestre),
          segundoCurso:segundo_curso_id(id, nomeDoCurso, semestre)
        ''')
            .eq('dia_da_semana', dia)
            .order('sala_id')
            .execute();

    if (response.status != 200 && response.status != 201) {
      throw Exception('Erro ao buscar ensalamentos por dia e bloco');
    }

    final data = response.data as List<dynamic>;

    final filtrado =
        bloco == null
            ? data
            : data.where((item) {
              final sala = item['sala'];
              return sala != null && sala['bloco'] == bloco;
            }).toList();

    return filtrado.map((e) => Ensalamento.fromMap(e)).toList();
  }

  Future<List<String>> listarBlocos() async {
    final response =
        await client
            .from('salas')
            .select('bloco')
            .not('bloco', 'is', null)
            .execute();

    if (response.status != 200 && response.status != 201) {
      throw Exception('Erro ao listar blocos: status ${response.status}');
    }

    final data = response.data as List<dynamic>;
    final blocos = data.map((e) => e['bloco'] as String).toSet().toList();
    blocos.sort();
    return blocos;
  }
}
