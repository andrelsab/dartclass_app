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

    if (!mounted) return;
    if (cursoId != null && semestre != null && turno != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/config');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', width: 120, height: 120),
            const SizedBox(height: 16),
            const Text(
              'DartClass',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
