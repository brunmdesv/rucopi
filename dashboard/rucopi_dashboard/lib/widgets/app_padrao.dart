import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppPadrao extends StatelessWidget {
  final String? titulo;
  final Widget child;
  final List<Widget>? actions;
  final Widget? leading;
  final bool mostrarAppBar;
  final Color? backgroundColor;
  final PreferredSizeWidget? customAppBar;
  const AppPadrao({
    Key? key,
    this.titulo,
    required this.child,
    this.actions,
    this.leading,
    this.mostrarAppBar = true,
    this.backgroundColor,
    this.customAppBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            if (mostrarAppBar) _CustomTopBar(theme: theme),
            Expanded(
              child: Padding(padding: const EdgeInsets.all(32), child: child),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _defaultAppBar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color:
              theme.appBarTheme.backgroundColor ??
              (isDark ? const Color(0xFF1A1A1A) : Colors.white),
          border: Border(
            bottom: BorderSide(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: leading,
              ),
            if (titulo != null)
              Padding(
                padding: const EdgeInsets.only(right: 24, left: 8),
                child: Text(
                  titulo!,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            const Spacer(),
            if (actions != null)
              ...actions!.map(
                (action) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: action,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Novo widget para o topo customizado
class _CustomTopBar extends StatelessWidget {
  final ThemeData theme;
  _CustomTopBar({required this.theme});

  static const List<_NavItem> navItems = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.list_alt_rounded, label: 'Solicitações'),
    _NavItem(icon: Icons.map_rounded, label: 'Mapa'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Relatórios'),
    _NavItem(icon: Icons.settings_rounded, label: 'Configurações'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color:
            theme.appBarTheme.backgroundColor ??
            (isDark ? const Color(0xFF1A1A1A) : Colors.white),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Lado esquerdo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.eco_rounded,
                  color: theme.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'RUCOPI',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    'SISTEMA DE GESTÃO',
                    style: TextStyle(fontSize: 12, letterSpacing: 1),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Centro: navegação
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NavBarIcon(
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                route: '/home',
                theme: theme,
              ),
              _NavBarIcon(
                icon: Icons.list_alt_rounded,
                label: 'Solicitações',
                route: '/solicitacoes',
                theme: theme,
              ),
              _NavBarIcon(
                icon: Icons.map_rounded,
                label: 'Mapa',
                route: null,
                theme: theme,
              ),
              _NavBarIcon(
                icon: Icons.bar_chart_rounded,
                label: 'Relatórios',
                route: null,
                theme: theme,
              ),
              _NavBarIcon(
                icon: Icons.settings_rounded,
                label: 'Configurações',
                route: '/configuracoes',
                theme: theme,
              ),
            ],
          ),
          const Spacer(),
          // Lado direito
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.more_vert_rounded, size: 28),
              color: theme.primaryColor,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// Widget para cada ícone de navegação
class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? route;
  final ThemeData theme;
  const _NavBarIcon({
    required this.icon,
    required this.label,
    required this.route,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: route != null
          ? () {
              context.go(route!);
            }
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: theme.primaryColor, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
