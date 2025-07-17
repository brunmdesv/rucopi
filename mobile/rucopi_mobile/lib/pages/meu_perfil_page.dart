import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_padrao.dart';

class MeuPerfilPage extends StatefulWidget {
  const MeuPerfilPage({Key? key}) : super(key: key);

  @override
  State<MeuPerfilPage> createState() => _MeuPerfilPageState();
}

class _MeuPerfilPageState extends State<MeuPerfilPage> {
  Map<String, dynamic>? morador;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        loading = false;
      });
      return;
    }
    final resp = await Supabase.instance.client
        .from('moradores')
        .select()
        .eq('id', user.id)
        .single();
    setState(() {
      morador = resp;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppPadrao(
      titulo: 'Meu Perfil',
      leading: Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : morador == null
          ? const Center(child: Text('Usuário não logado.'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_circle,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      morador!['nome'] ?? '-',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _info('E-mail', morador!['email']),
                _info('CPF', morador!['cpf']),
                _info('Whatsapp', morador!['whatsapp']),
                _info('Endereço', morador!['endereco']),
              ],
            ),
    );
  }

  Widget _info(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? '-')),
        ],
      ),
    );
  }
}
