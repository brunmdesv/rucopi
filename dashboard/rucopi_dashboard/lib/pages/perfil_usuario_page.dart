import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_styles.dart';

class PerfilUsuarioPage extends StatelessWidget {
  const PerfilUsuarioPage({Key? key}) : super(key: key);

  Color _getCargoColor(String? cargo) {
    switch (cargo) {
      case 'administrador':
        return const Color(0xFFD32F2F);
      case 'operador':
        return const Color(0xFF1976D2);
      default:
        return Colors.grey;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final dateTime = DateTime.tryParse(date.toString());
      if (dateTime != null) {
        return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
      }
    } catch (e) {}
    return date.toString().substring(0, 10);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return Center(child: Text('Usuário não autenticado'));
    }
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: 32,
          horizontal: width < 600 ? 8 : 0,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: FutureBuilder(
            future: Supabase.instance.client
                .from('usuarios')
                .select('nome, cargo, criado_em')
                .eq('id', user.id)
                .single(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data == null) {
                return Center(child: Text('Erro ao carregar dados do perfil'));
              }
              final usuario = snapshot.data as Map<String, dynamic>;
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        usuario['nome'] ?? 'Nome não informado',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.email ?? 'E-mail não informado',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.disabledColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getCargoColor(
                            usuario['cargo'],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          usuario['cargo'] ?? 'Cargo não informado',
                          style: TextStyle(
                            color: _getCargoColor(usuario['cargo']),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: theme.disabledColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Criado em: ${_formatDate(usuario['criado_em'])}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.disabledColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
