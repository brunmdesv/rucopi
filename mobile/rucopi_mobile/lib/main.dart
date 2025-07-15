import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Teste de leitura manual do arquivo .env
  final file = File('.env');
  print('Arquivo .env existe? ${await file.exists()}');
  if (await file.exists()) {
    print('Conteúdo do .env:');
    print(await file.readAsString());
  } else {
    print('Arquivo .env NÃO encontrado!');
  }

  await dotenv.load(fileName: ".env"); // Carrega o .env explicitamente

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rucopi App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rucopi - Teste Supabase')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            final user = Supabase.instance.client.auth.currentUser;
            final text = user == null
                ? 'Nenhum usuário logado'
                : 'Usuário logado: ${user.email}';
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(text)));
          },
          child: const Text('Ver usuário logado'),
        ),
      ),
    );
  }
}
