class Sala {
  final String id;
  final String nome;
  final String bloco;

  Sala({
    required this.id,
    required this.nome,
    required this.bloco,
  });

  factory Sala.fromMap(Map<String, dynamic> map) {
    return Sala(
      id: map['id'] as String,
      nome: map['nome'] as String,
      bloco: map['bloco'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'bloco': bloco,
    };
  }
}
