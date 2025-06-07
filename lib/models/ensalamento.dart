import 'sala.dart';
import 'turma.dart';

class Ensalamento {
  final String id;
  final String salaId;
  final Sala? sala; // novo
  final String diaDaSemana;
  final Turma? primeiroCurso;
  final Turma? segundoCurso;
  final DateTime? createdAt;

  Ensalamento({
    required this.id,
    required this.salaId,
    this.sala,  // novo
    required this.diaDaSemana,
    this.primeiroCurso,
    this.segundoCurso,
    this.createdAt,
  });

factory Ensalamento.fromMap(Map<String, dynamic> map) {
  return Ensalamento(
    id: map['id']?.toString() ?? 'id_desconhecido',
    salaId: map['sala_id']?.toString() ?? 'sala_id_desconhecido',
    sala: map['sala'] != null
        ? Sala.fromMap(map['sala'] as Map<String, dynamic>)
        : null,
    diaDaSemana: map['dia_da_semana']?.toString() ?? 'Dia não informado',
    primeiroCurso: map['primeiroCurso'] != null
        ? Turma.fromMap(map['primeiroCurso'] as Map<String, dynamic>)
        : null,
    segundoCurso: map['segundoCurso'] != null
        ? Turma.fromMap(map['segundoCurso'] as Map<String, dynamic>)
        : null,
    createdAt: map['created_at'] != null
        ? DateTime.tryParse(map['created_at'].toString())
        : null,
  );
}

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sala_id': salaId,
      'sala': sala?.toMap(),
      'dia_da_semana': diaDaSemana,
      'primeiroCurso': primeiroCurso?.toMap(),
      'segundoCurso': segundoCurso?.toMap(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
