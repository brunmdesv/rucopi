
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final nomeController = TextEditingController();
  final cpfController = TextEditingController();
  final whatsappController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final enderecoController = TextEditingController();

  bool carregando = false;

  void cadastrar() async {
    setState(() => carregando = true);

    try {
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: emailController.text,
        password: senhaController.text,
      );

      final userId = authResponse.user?.id;

      if (userId != null) {
        await Supabase.instance.client.from('moradores').insert({
          'id': userId,
          'nome': nomeController.text,
          'cpf': cpfController.text,
          'whatsapp': whatsappController.text,
          'email': emailController.text,
          'endereco': enderecoController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso')),
        );

        Navigator.pop(context); // Volta para o login
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome completo')),
            TextField(controller: cpfController, decoration: const InputDecoration(labelText: 'CPF')),
            TextField(controller: whatsappController, decoration: const InputDecoration(labelText: 'WhatsApp')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'E-mail')),
            TextField(controller: senhaController, obscureText: true, decoration: const InputDecoration(labelText: 'Senha')),
            TextField(controller: enderecoController, decoration: const InputDecoration(labelText: 'Endereço')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: carregando ? null : cadastrar,
              child: carregando ? const CircularProgressIndicator() : const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
