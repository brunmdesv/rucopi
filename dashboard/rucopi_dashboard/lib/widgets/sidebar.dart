import 'package:flutter/material.dart';
import '../pages/dashboard_home_page.dart';

class Sidebar extends StatelessWidget {
  final bool sidebarExpanded;
  final VoidCallback onToggle;
  final ThemeData theme;
  final bool isDark;
  final BuildContext parentContext;
  final void Function(DashboardScreen) onSelect;
  final DashboardScreen currentScreen;

  const Sidebar({
    Key? key,
    required this.sidebarExpanded,
    required this.onToggle,
    required this.theme,
    required this.isDark,
    required this.parentContext,
    required this.onSelect,
    required this.currentScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sidebarExpanded ? 280 : 80,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: sidebarExpanded
                ? Row(
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
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'RUCOPI',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              'Sistema de Gestão',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.disabledColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: onToggle,
                          icon: Icon(
                            sidebarExpanded ? Icons.menu_open : Icons.menu,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: onToggle,
                        icon: Icon(
                          sidebarExpanded ? Icons.menu_open : Icons.menu,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildSidebarItem(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  selected: currentScreen == DashboardScreen.dashboard,
                  theme: theme,
                  onTap: () => onSelect(DashboardScreen.dashboard),
                ),
                _buildSidebarItem(
                  icon: Icons.list_alt_rounded,
                  title: 'Solicitações',
                  selected: currentScreen == DashboardScreen.solicitacoes,
                  theme: theme,
                  onTap: () => onSelect(DashboardScreen.solicitacoes),
                ),
                _buildSidebarItem(
                  icon: Icons.map_rounded,
                  title: 'Mapa',
                  selected: false,
                  theme: theme,
                  onTap: () {},
                ),
                _buildSidebarItem(
                  icon: Icons.analytics_rounded,
                  title: 'Relatórios',
                  selected: false,
                  theme: theme,
                  onTap: () {},
                ),
                _buildSidebarItem(
                  icon: Icons.person_rounded,
                  title: 'Perfil',
                  selected: currentScreen == DashboardScreen.perfil,
                  theme: theme,
                  onTap: () => onSelect(DashboardScreen.perfil),
                ),
                _buildSidebarItem(
                  icon: Icons.settings_rounded,
                  title: 'Configurações',
                  selected: currentScreen == DashboardScreen.configuracoes,
                  theme: theme,
                  onTap: () => onSelect(DashboardScreen.configuracoes),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required ThemeData theme,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? theme.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? theme.primaryColor : theme.disabledColor,
                  size: 20,
                ),
                if (sidebarExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: selected
                            ? theme.primaryColor
                            : theme.disabledColor,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
