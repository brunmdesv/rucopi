import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../widgets/app_padrao.dart';
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
  void initState() {
    super.initState();
  }

  PreferredSizeWidget _buildCustomAppBar(ThemeData theme) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: Container(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF1A1A1A)
            : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        alignment: Alignment.centerLeft,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 72,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Text(
                    'Configurações',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF606A45),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final user = Supabase.instance.client.auth.currentUser;
    return FutureBuilder(
      future: user == null
          ? Future.value(null)
          : Supabase.instance.client
                .from('usuarios')
                .select('cargo')
                .eq('id', user.id)
                .single(),
      builder: (context, snapshot) {
        final isAdmin =
            snapshot.hasData &&
            snapshot.data != null &&
            (snapshot.data as Map<String, dynamic>)['cargo'] == 'administrador';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.brightness_6,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Tema do sistema',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _ThemeIconButton(
                  icon: Icons.light_mode,
                  tooltip: 'Claro',
                  selected: themeProvider.themeMode == ThemeMode.light,
                  onTap: () => themeProvider.setTheme(ThemeMode.light),
                ),
                const SizedBox(width: 8),
                _ThemeIconButton(
                  icon: Icons.dark_mode,
                  tooltip: 'Escuro',
                  selected: themeProvider.themeMode == ThemeMode.dark,
                  onTap: () => themeProvider.setTheme(ThemeMode.dark),
                ),
                const SizedBox(width: 8),
                _ThemeIconButton(
                  icon: Icons.brightness_auto,
                  tooltip: 'Automático',
                  selected: themeProvider.themeMode == ThemeMode.system,
                  onTap: () => themeProvider.setTheme(ThemeMode.system),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.manage_accounts),
                  label: const Text('Gerenciar usuários'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    textStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const UsuariosDashboard(),
                      ),
                    );
                  },
                ),
              ),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
                textStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? theme.colorScheme.primary : Colors.transparent,
              width: selected ? 2 : 1,
            ),
          ),
          child: Icon(
            icon,
            size: 28,
            color: selected ? theme.colorScheme.primary : theme.iconTheme.color,
          ),
        ),
      ),
    );
  }
}
