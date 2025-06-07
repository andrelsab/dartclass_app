import 'package:shared_preferences/shared_preferences.dart';

class LocalConfigService {
  static const String _cursoKey = 'curso';
  static const String _semestreKey = 'semestre';

  /// Salva o curso e semestre localmente
  static Future<void> salvarCursoESemestre(String curso, int semestre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cursoKey, curso);
    await prefs.setInt(_semestreKey, semestre);
  }

  /// Retorna o curso salvo ou null se não existir
  static Future<String?> getCurso() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cursoKey);
  }

  /// Retorna o semestre salvo ou null se não existir
  static Future<int?> getSemestre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_semestreKey);
  }

  /// Remove as configurações salvas (opcional, se quiser resetar)
  static Future<void> limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cursoKey);
    await prefs.remove(_semestreKey);
  }
}
