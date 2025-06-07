import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ensalamento.dart';
import '../models/turma.dart';

class EnsalamentoRepository {
  final SupabaseClient client;

  EnsalamentoRepository(this.client);

 Future<List<Ensalamento>> buscarEnsalamentosFiltrados(String cursoId, int semestre) async {
  if (cursoId.isEmpty || semestre <= 0) {
    return []; // Protege contra chamadas inválidas
  }

  final response = await client
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
    throw Exception('Erro ao buscar ensalamentos: status ${response.status}');
  }

  final data = response.data as List<dynamic>;

  final listaFiltrada = data.where((item) {
    final map = item as Map<String, dynamic>;

    final primeiroCurso = map['primeiroCurso'] != null
        ? Turma.fromMap(map['primeiroCurso'] as Map<String, dynamic>)
        : null;

    final segundoCurso = map['segundoCurso'] != null
        ? Turma.fromMap(map['segundoCurso'] as Map<String, dynamic>)
        : null;

    return (primeiroCurso?.semestre == semestre) || (segundoCurso?.semestre == semestre);
  }).toList();

  return listaFiltrada.map((e) => Ensalamento.fromMap(e as Map<String, dynamic>)).toList();
}

}
