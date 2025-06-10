class Turma {
  final String id;
  final String? nomeDoCurso;
  final String? turno;
  final int? semestre;
  final int? qtdDeAlunos;
  final String? observacoes;

  Turma({
    required this.id,
    this.nomeDoCurso,
    this.turno,
    this.semestre,
    this.qtdDeAlunos,
    this.observacoes,
  });

  factory Turma.fromMap(Map<String, dynamic> map) {
    return Turma(
      id: map['id'] as String,
      nomeDoCurso: map['nomeDoCurso'] as String?,
      turno: map['turno'] as String?,
      semestre:
          map['semestre'] != null ? (map['semestre'] as num).toInt() : null,
      qtdDeAlunos:
          map['qtdDeAlunos'] != null
              ? (map['qtdDeAlunos'] as num).toInt()
              : null,
      observacoes: map['observacoes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomeDoCurso': nomeDoCurso,
      'turno': turno,
      'semestre': semestre,
      'qtdDeAlunos': qtdDeAlunos,
      'observacoes': observacoes,
    };
  }

  @override
  String toString() {
    final curso = nomeDoCurso ?? 'Curso desconhecido';
    final sem = semestre != null ? '$semestreº semestre' : 'Sem semestre';
    final turnoStr = turno ?? 'Sem turno';
    return '$curso - $sem ($turnoStr)';
  }
}
