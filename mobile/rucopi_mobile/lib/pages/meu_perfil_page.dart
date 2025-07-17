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
    final theme = Theme.of(context);
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
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16, top: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header com ícone e nome
                    Column(
                      children: [
                        Icon(
                          Icons.account_circle,
                          size: 72,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          morador!['nome'] ?? '-',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Campos
                    _infoRow(
                      context,
                      icon: Icons.email_outlined,
                      label: 'E-mail',
                      value: morador!['email'],
                    ),
                    const SizedBox(height: 16),
                    _infoRow(
                      context,
                      icon: Icons.badge_outlined,
                      label: 'CPF',
                      value: morador!['cpf'],
                    ),
                    const SizedBox(height: 16),
                    _infoRow(
                      context,
                      icon: Icons.phone_outlined,
                      label: 'Whatsapp',
                      value: morador!['whatsapp'],
                    ),
                    const SizedBox(height: 16),
                    _infoRow(
                      context,
                      icon: Icons.location_on_outlined,
                      label: 'Endereço',
                      value: morador!['endereco'],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? value,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.primaryColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(value ?? '-', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
