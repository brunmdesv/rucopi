import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'pages/login_page.dart';
import 'pages/cadastro_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega o arquivo .env com URL e chave do Supabase
  await dotenv.load(fileName: ".env");

  // Inicializa Supabase
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginPage(),
        '/cadastro': (_) => const CadastroPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _criarPerfilMorador(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para criar seu perfil!')),
      );
      return;
    }
    final response = await Supabase.instance.client.from('moradores').insert({
      'id': user.id,
      'nome': 'Novo Morador',
    });
    if (response == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil criado com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar perfil: $response')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rucopi - Teste Supabase')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                final user = Supabase.instance.client.auth.currentUser;
                final text = user == null
                    ? 'Nenhum usuário logado'
                    : 'Usuário logado: \\${user.email}';
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(text)));
              },
              child: const Text('Ver usuário logado'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _criarPerfilMorador(context),
              child: const Text('Criar perfil de morador'),
            ),
          ],
        ),
      ),
    );
  }
}
