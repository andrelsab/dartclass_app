import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'pages/home_page.dart';
import 'pages/config_page.dart';
import 'pages/splash_page.dart';

void main() async {
  // Garante que os bindings do Flutter estejam prontos
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa os dados de formatação de data para pt_BR
  await initializeDateFormatting('pt_BR', null);

  // Inicializa o Supabase
  await Supabase.initialize(
    url: 'https://ktqpfpelpsqcgwwzouyp.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt0cXBmcGVscHNxY2d3d3pvdXlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ1NjgyMjMsImV4cCI6MjA2MDE0NDIyM30.ENPXIn3c1COhsW1EG2PNTRkuxShITPO5xhPdC3QP4TQ',
  );

  runApp(const EnsalamentoApp());
}

class EnsalamentoApp extends StatelessWidget {
  const EnsalamentoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ensalamento',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0077C2),
        scaffoldBackgroundColor: const Color(0xFFEFF3F8),
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/home': (context) => const HomePage(),
        '/config': (context) => const ConfigPage(),
      },
    );
  }
}
