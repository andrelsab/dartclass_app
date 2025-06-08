import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _verificarConfiguracao();
  }

  Future<void> _verificarConfiguracao() async {
    final prefs = await SharedPreferences.getInstance();

    final cursoId = prefs.getString('curso_id');
    final semestre = prefs.getInt('semestre');
    final turno = prefs.getString('turno'); // novo campo

    // Aguarda 1 segundo só para dar um tempo de splash
    await Future.delayed(const Duration(seconds: 1));

    if (cursoId != null && semestre != null && turno != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/config');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, color: Colors.white, size: 80),
            SizedBox(height: 16),
            Text(
              'DartClass',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
