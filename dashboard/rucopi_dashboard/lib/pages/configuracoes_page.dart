import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:rucopi_dashboard/pages/usuarios_dashboard.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({Key? key}) : super(key: key);

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final user = Supabase.instance.client.auth.currentUser;
    final width = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: user == null
          ? Future.value(null)
          : Supabase.instance.client
                .from('usuarios')
                .select('cargo')
                .eq('id', user.id)
                .single(),
      builder: (context, snapshot) {
        final cargo = snapshot.hasData && snapshot.data != null
            ? (snapshot.data as Map<String, dynamic>)['cargo'] as String?
            : null;
        final isAdmin = cargo == 'administrador';
        final isOperador = cargo == 'operador';
        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical: 32,
              horizontal: width < 600 ? 8 : 0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.settings_rounded,
                            color: theme.primaryColor,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Configurações',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Tema do sistema',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        color: theme.cardColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          side: BorderSide(color: theme.dividerColor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _ThemeIconButton(
                                icon: Icons.light_mode,
                                tooltip: 'Claro',
                                selected:
                                    themeProvider.themeMode == ThemeMode.light,
                                onTap: () =>
                                    themeProvider.setTheme(ThemeMode.light),
                              ),
                              const SizedBox(width: 16),
                              _ThemeIconButton(
                                icon: Icons.dark_mode,
                                tooltip: 'Escuro',
                                selected:
                                    themeProvider.themeMode == ThemeMode.dark,
                                onTap: () =>
                                    themeProvider.setTheme(ThemeMode.dark),
                              ),
                              const SizedBox(width: 16),
                              _ThemeIconButton(
                                icon: Icons.brightness_auto,
                                tooltip: 'Automático',
                                selected:
                                    themeProvider.themeMode == ThemeMode.system,
                                onTap: () =>
                                    themeProvider.setTheme(ThemeMode.system),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (isAdmin || isOperador)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Gerenciamento',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.manage_accounts),
                              label: const Text('Gerenciar usuários'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                textStyle: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.button,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const UsuariosDashboard(),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      Text(
                        'Sessão',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: Colors.white,
                          textStyle: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.button,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          await Supabase.instance.client.auth.signOut();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ThemeIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeIconButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withOpacity(0.15)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? theme.colorScheme.primary : theme.dividerColor,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Icon(
            icon,
            size: 32,
            color: selected ? theme.colorScheme.primary : theme.iconTheme.color,
          ),
        ),
      ),
    );
  }
}
