import 'package:flutter/material.dart';
import '../theme/app_styles.dart';
import 'solicitacoes_page.dart';
import 'configuracoes_page.dart';
import 'detalhes_solicitacao.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Enum para as telas
enum DashboardScreen {
  dashboard,
  solicitacoes,
  mapa,
  relatorios,
  configuracoes,
}

class DashboardHomePage extends StatefulWidget {
  const DashboardHomePage({super.key});

  @override
  State<DashboardHomePage> createState() => _DashboardHomePageState();
}

class _DashboardHomePageState extends State<DashboardHomePage> {
  DashboardScreen currentScreen = DashboardScreen.dashboard;
  DashboardScreen? hoveredScreen;

  void _onMenuTap(DashboardScreen screen) {
    setState(() {
      currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: width < 900 ? _buildDrawerMenu(theme, isDark) : null,
      body: Column(
        children: [
          _buildMenuBar(theme, isDark),
          Flexible(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _buildScreenContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuBar(ThemeData theme, bool isDark) {
    final width = MediaQuery.of(context).size.width;
    if (width < 900) {
      // MOBILE/TABLET: menu hamburguer
      return Material(
        elevation: 2,
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              const SizedBox(width: 8),
              Icon(Icons.eco_rounded, color: theme.primaryColor, size: 24),
              const SizedBox(width: 4),
              Text(
                'RUCOPI',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
    // DESKTOP/TABLET: menu bar tradicional
    return Material(
      elevation: 2,
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          children: [
            // Esquerda: Logo
            Row(
              children: [
                Icon(Icons.eco_rounded, color: theme.primaryColor, size: 32),
                const SizedBox(width: 8),
                Text(
                  'RUCOPI',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Centro: Navegação
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMenuIcon(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  selected: currentScreen == DashboardScreen.dashboard,
                  onTap: () => _onMenuTap(DashboardScreen.dashboard),
                  theme: theme,
                  screenType: DashboardScreen.dashboard,
                ),
                const SizedBox(width: 32),
                _buildMenuIcon(
                  icon: Icons.list_alt_rounded,
                  label: 'Solicitações',
                  selected: currentScreen == DashboardScreen.solicitacoes,
                  onTap: () => _onMenuTap(DashboardScreen.solicitacoes),
                  theme: theme,
                  screenType: DashboardScreen.solicitacoes,
                ),
                const SizedBox(width: 32),
                _buildMenuIcon(
                  icon: Icons.map_rounded,
                  label: 'Mapa',
                  selected: currentScreen == DashboardScreen.mapa,
                  onTap: () => _onMenuTap(DashboardScreen.mapa),
                  theme: theme,
                  screenType: DashboardScreen.mapa,
                ),
                const SizedBox(width: 32),
                _buildMenuIcon(
                  icon: Icons.bar_chart_rounded,
                  label: 'Relatórios',
                  selected: currentScreen == DashboardScreen.relatorios,
                  onTap: () => _onMenuTap(DashboardScreen.relatorios),
                  theme: theme,
                  screenType: DashboardScreen.relatorios,
                ),
                const SizedBox(width: 32),
                _buildMenuIcon(
                  icon: Icons.settings_rounded,
                  label: 'Configurações',
                  selected: currentScreen == DashboardScreen.configuracoes,
                  onTap: () => _onMenuTap(DashboardScreen.configuracoes),
                  theme: theme,
                  screenType: DashboardScreen.configuracoes,
                ),
              ],
            ),
            const Spacer(),
            // Direita: 3 pontinhos
            IconButton(
              icon: const Icon(Icons.more_vert_rounded, size: 20),
              onPressed: () {
                showMenu(
                  context: context,
                  position: const RelativeRect.fromLTRB(1000, 60, 16, 0),
                  items: [
                    const PopupMenuItem(child: Text('Opção 1')),
                    const PopupMenuItem(child: Text('Opção 2')),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuIcon({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required ThemeData theme,
    required DashboardScreen screenType,
  }) {
    return _MenuIcon(
      icon: icon,
      label: label,
      selected: selected,
      onTap: onTap,
      theme: theme,
    );
  }

  Widget _buildScreenContent() {
    switch (currentScreen) {
      case DashboardScreen.dashboard:
        return _DashboardContent(key: const ValueKey('dashboard'));
      case DashboardScreen.solicitacoes:
        return const SolicitacoesPage(key: ValueKey('solicitacoes'));
      case DashboardScreen.configuracoes:
        return const ConfiguracoesPage(key: ValueKey('configuracoes'));
      case DashboardScreen.mapa:
        return _PlaceholderContent(
          icon: Icons.map_rounded,
          label: 'Mapa',
          key: const ValueKey('mapa'),
        );
      case DashboardScreen.relatorios:
        return _PlaceholderContent(
          icon: Icons.bar_chart_rounded,
          label: 'Relatórios',
          key: const ValueKey('relatorios'),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDrawerMenu(ThemeData theme, bool isDark) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.eco_rounded, color: theme.primaryColor, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'RUCOPI',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            _buildDrawerItem(
              icon: Icons.dashboard_rounded,
              label: 'Dashboard',
              selected: currentScreen == DashboardScreen.dashboard,
              onTap: () {
                Navigator.of(context).pop();
                _onMenuTap(DashboardScreen.dashboard);
              },
              theme: theme,
            ),
            _buildDrawerItem(
              icon: Icons.list_alt_rounded,
              label: 'Solicitações',
              selected: currentScreen == DashboardScreen.solicitacoes,
              onTap: () {
                Navigator.of(context).pop();
                _onMenuTap(DashboardScreen.solicitacoes);
              },
              theme: theme,
            ),
            _buildDrawerItem(
              icon: Icons.map_rounded,
              label: 'Mapa',
              selected: currentScreen == DashboardScreen.mapa,
              onTap: () {
                Navigator.of(context).pop();
                _onMenuTap(DashboardScreen.mapa);
              },
              theme: theme,
            ),
            _buildDrawerItem(
              icon: Icons.bar_chart_rounded,
              label: 'Relatórios',
              selected: currentScreen == DashboardScreen.relatorios,
              onTap: () {
                Navigator.of(context).pop();
                _onMenuTap(DashboardScreen.relatorios);
              },
              theme: theme,
            ),
            _buildDrawerItem(
              icon: Icons.settings_rounded,
              label: 'Configurações',
              selected: currentScreen == DashboardScreen.configuracoes,
              onTap: () {
                Navigator.of(context).pop();
                _onMenuTap(DashboardScreen.configuracoes);
              },
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? theme.primaryColor : theme.disabledColor,
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: selected ? theme.primaryColor : theme.disabledColor,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      onTap: onTap,
    );
  }
}

// Conteúdo do Dashboard (exemplo)
class _DashboardContent extends StatefulWidget {
  const _DashboardContent({super.key});

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  void _navegarParaSolicitacoes() {
    // Encontrar o widget pai que contém o estado de navegação
    final context = this.context;
    final dashboardState = context
        .findAncestorStateOfType<_DashboardHomePageState>();
    if (dashboardState != null) {
      dashboardState._onMenuTap(DashboardScreen.solicitacoes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    // StreamBuilder para atualização em tempo real
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('solicitacoes')
          .stream(primaryKey: ['id'])
          .order('criado_em', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar dados',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }
        final solicitacoes = snapshot.data ?? [];
        final total = solicitacoes.length;
        final pendentes = solicitacoes
            .where((s) => s['status'] == 'pendente')
            .length;
        final andamento = solicitacoes
            .where((s) => s['status'] == 'em andamento')
            .length;
        final concluidas = solicitacoes
            .where((s) => s['status'] == 'concluida')
            .length;
        final solicitacoesRecentes = solicitacoes.take(8).toList();
        // Responsividade: padding menor em telas pequenas
        final horizontalPadding = width < 600
            ? 8.0
            : (width < 900 ? 16.0 : 32.0);
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: horizontalPadding,
            right: horizontalPadding,
            top: 24,
            bottom: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildWelcomeHeader(theme, isDark, width),
                const SizedBox(height: 24),
                _buildStatsGrid(
                  theme,
                  isDark,
                  width,
                  total,
                  pendentes,
                  andamento,
                  concluidas,
                ),
                const SizedBox(height: 24),
                _buildMainContentResponsive(
                  theme,
                  isDark,
                  width,
                  solicitacoesRecentes,
                  total: total,
                  concluidas: concluidas,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(
    ThemeData theme,
    bool isDark,
    double width,
    int total,
    int pendentes,
    int andamento,
    int concluidas,
  ) {
    int crossAxisCount = 4;
    if (width < 1100) crossAxisCount = 2;
    if (width < 700) crossAxisCount = 1;
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth;
        if (crossAxisCount == 1) {
          cardWidth = constraints.maxWidth;
        } else {
          cardWidth = constraints.maxWidth / crossAxisCount - 16;
        }
        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                title: 'Total de Solicitações',
                value: total,
                icon: Icons.assignment_rounded,
                color: theme.primaryColor,
                theme: theme,
                isDark: isDark,
                width: width,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                title: 'Aguardando Coleta',
                value: pendentes,
                icon: Icons.access_time_rounded,
                color: const Color(0xFFFF9800),
                theme: theme,
                isDark: isDark,
                width: width,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                title: 'Em Andamento',
                value: andamento,
                icon: Icons.local_shipping_rounded,
                color: const Color(0xFF2196F3),
                theme: theme,
                isDark: isDark,
                width: width,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                title: 'Concluídas',
                value: concluidas,
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF4CAF50),
                theme: theme,
                isDark: isDark,
                width: width,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
    required bool isDark,
    required double width,
  }) {
    return Container(
      constraints: BoxConstraints(
        minWidth: width < 400 ? 100 : 150,
        maxWidth: 280,
      ),
      padding: EdgeInsets.all(width < 600 ? 10 : 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(width < 600 ? 8 : 12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(width < 600 ? 5 : 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: width < 600 ? 16 : 20),
          ),
          const SizedBox(width: 10),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: width < 600 ? 20 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: width < 600 ? 12 : null,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRequestsSection(
    ThemeData theme,
    bool isDark,
    double width,
    List<dynamic> solicitacoesRecentes,
  ) {
    // Filtrar apenas solicitações pendentes e ordenar por data (mais antigas primeiro)
    final solicitacoesPendentes =
        solicitacoesRecentes.where((s) => s['status'] == 'pendente').toList()
          ..sort((a, b) {
            final dataA = DateTime.tryParse(a['criado_em'] ?? '');
            final dataB = DateTime.tryParse(b['criado_em'] ?? '');

            // Se ambas as datas são nulas, mantém a ordem original
            if (dataA == null && dataB == null) return 0;

            // Se apenas uma data é nula, coloca a nula por último
            if (dataA == null) return 1;
            if (dataB == null) return -1;

            // Ordem crescente: mais antigas primeiro (dataA.compareTo(dataB))
            return dataA.compareTo(dataB);
          });

    // Pegar apenas as 3 primeiras
    final solicitacoesExibidas = solicitacoesPendentes.take(3).toList();
    final totalPendentes = solicitacoesPendentes.length;
    final restantes = totalPendentes - solicitacoesExibidas.length;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header compacto
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: width < 600 ? 12 : 16,
              vertical: width < 600 ? 8 : 12,
            ),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: theme.primaryColor,
                  size: width < 600 ? 14 : 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Solicitações Pendentes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: width < 600 ? 13 : null,
                    ),
                  ),
                ),
                if (restantes > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '+$restantes',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Lista compacta
          if (solicitacoesExibidas.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(width < 600 ? 8 : 12),
              child: Column(
                children: solicitacoesExibidas.asMap().entries.map((entry) {
                  final index = entry.key;
                  final solicitacao = entry.value;
                  return Column(
                    children: [
                      _buildSolicitacaoCardCompact(
                        solicitacao,
                        theme,
                        isDark,
                        width,
                        index + 1,
                      ),
                      if (index < solicitacoesExibidas.length - 1)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: width < 600 ? 4 : 6,
                          ),
                          child: Container(
                            height: 1,
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF2A2A2A)
                                : Colors.grey.shade200,
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          // Estado vazio compacto
          if (solicitacoesExibidas.isEmpty)
            Padding(
              padding: EdgeInsets.all(width < 600 ? 16 : 20),
              child: _buildEmptyStateCompact(theme),
            ),
          // Botão compacto
          if (restantes > 0)
            Container(
              padding: EdgeInsets.all(width < 600 ? 8 : 12),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF0F0F0F)
                    : Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _navegarParaSolicitacoes,
                  icon: Icon(
                    Icons.list_alt_rounded,
                    size: width < 600 ? 10 : 12,
                  ),
                  label: Text(
                    'Ver mais $restantes solicitações pendentes',
                    style: TextStyle(fontSize: width < 600 ? 9 : null),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: width < 600 ? 6 : 8,
                    ),
                    side: BorderSide(
                      color: theme.primaryColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSolicitacaoCardCompact(
    dynamic solicitacao,
    ThemeData theme,
    bool isDark,
    double width,
    int numero,
  ) {
    final nomeMorador =
        solicitacao['nome_morador'] ??
        solicitacao['morador_id'] ??
        'Morador não identificado';
    final endereco = solicitacao['endereco'] ?? 'Sem endereço';
    final data = solicitacao['criado_em'] != null
        ? DateTime.tryParse(solicitacao['criado_em'])
        : null;
    final dataStr = data != null
        ? '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}'
        : 'Sem data';
    final horaStr = data != null
        ? '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}'
        : '';

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) =>
              DetalhesSolicitacaoDialog(solicitacao: solicitacao),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(width < 600 ? 8 : 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.primaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Número compacto
            Container(
              width: width < 600 ? 20 : 24,
              height: width < 600 ? 20 : 24,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  '$numero',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: width < 600 ? 8 : 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Informações compactas
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          nomeMorador,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: width < 600 ? 10 : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFFFF9800).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              color: const Color(0xFFFF9800),
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Pendente',
                              style: TextStyle(
                                color: const Color(0xFFFF9800),
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 11,
                        color: theme.disabledColor,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          endereco,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.disabledColor,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$dataStr $horaStr',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.disabledColor,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(ThemeData theme, bool isDark, double width) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width < 600 ? 16 : 24,
        vertical: width < 600 ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.handshake_rounded, color: theme.primaryColor, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo ao RUCOPI!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: width < 600 ? 16 : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seu sistema de gestão de coleta de resíduos.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.disabledColor,
                    fontSize: width < 600 ? 12 : null,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_rounded,
              color: theme.primaryColor,
              size: 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
    ThemeData theme,
    bool isDark,
    double width, {
    int total = 0,
    int concluidas = 0,
  }) {
    return Container(
      padding: EdgeInsets.all(width < 600 ? 12 : 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(width < 600 ? 8 : 12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo Rápido',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: width < 600 ? 14 : null,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickStatItem(
            'Taxa de Conclusão',
            total > 0
                ? '${((concluidas / total) * 100).toStringAsFixed(1)}%'
                : '0%',
            Icons.trending_up_rounded,
            const Color(0xFF4CAF50),
            theme,
            width,
          ),
          const SizedBox(height: 8),
          _buildQuickStatItem(
            'Tempo Médio',
            '2.5 dias',
            Icons.access_time_rounded,
            const Color(0xFF2196F3),
            theme,
            width,
          ),
          const SizedBox(height: 8),
          _buildQuickStatItem(
            'Eficiência',
            '89%',
            Icons.speed_rounded,
            const Color(0xFFFF9800),
            theme,
            width,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
    double width,
  ) {
    return Row(
      children: [
        Icon(icon, size: width < 600 ? 12 : 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: width < 600 ? 11 : null,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: width < 600 ? 11 : null,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(ThemeData theme, bool isDark, double width) {
    return Container(
      padding: EdgeInsets.all(width < 600 ? 12 : 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(width < 600 ? 8 : 12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ações Rápidas',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: width < 600 ? 14 : null,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.list_alt_rounded, size: width < 600 ? 14 : 18),
              label: Text(
                'Ver Solicitações',
                style: TextStyle(fontSize: width < 600 ? 12 : null),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: width < 600 ? 8 : 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.refresh_rounded, size: width < 600 ? 14 : 18),
              label: Text(
                'Atualizar Dados',
                style: TextStyle(fontSize: width < 600 ? 12 : null),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: width < 600 ? 8 : 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCompact(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 32,
            color: theme.disabledColor,
          ),
          const SizedBox(height: 8),
          Text(
            'Nenhuma solicitação pendente',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.disabledColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'concluida':
        return {
          'color': const Color(0xFF4CAF50),
          'icon': Icons.check_circle_rounded,
          'text': 'Concluída',
        };
      case 'em andamento':
        return {
          'color': const Color(0xFF2196F3),
          'icon': Icons.local_shipping_rounded,
          'text': 'Em Andamento',
        };
      default:
        return {
          'color': const Color(0xFFFF9800),
          'icon': Icons.access_time_rounded,
          'text': 'Pendente',
        };
    }
  }

  // Adicionar método responsivo dentro de _DashboardContentState
  Widget _buildMainContentResponsive(
    ThemeData theme,
    bool isDark,
    double width,
    List<dynamic> solicitacoesRecentes, {
    int total = 0,
    int concluidas = 0,
  }) {
    if (width < 900) {
      // Tablet/mobile: empilha as colunas
      return Column(
        children: [
          _buildRecentRequestsSection(
            theme,
            isDark,
            width,
            solicitacoesRecentes,
          ),
          const SizedBox(height: 16),
          _buildQuickStats(
            theme,
            isDark,
            width,
            total: total,
            concluidas: concluidas,
          ),
          const SizedBox(height: 16),
          _buildQuickActions(theme, isDark, width),
        ],
      );
    } else {
      // Desktop: mantém lado a lado
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildRecentRequestsSection(
              theme,
              isDark,
              width,
              solicitacoesRecentes,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildQuickStats(
                  theme,
                  isDark,
                  width,
                  total: total,
                  concluidas: concluidas,
                ),
                const SizedBox(height: 24),
                _buildQuickActions(theme, isDark, width),
              ],
            ),
          ),
        ],
      );
    }
  }
}

// Placeholder para telas não implementadas
class _PlaceholderContent extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlaceholderContent({
    required this.icon,
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: theme.disabledColor),
          const SizedBox(height: 16),
          Text(
            '$label em breve',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuIcon extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _MenuIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
    Key? key,
  }) : super(key: key);

  @override
  State<_MenuIcon> createState() => _MenuIconState();
}

class _MenuIconState extends State<_MenuIcon> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: widget.selected
                  ? widget.theme.primaryColor
                  : widget.theme.disabledColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: widget.theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: widget.selected
                    ? widget.theme.primaryColor
                    : widget.theme.disabledColor,
                fontWeight: widget.selected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.ease,
              height: 3,
              width: widget.selected || isHovered ? 28 : 0,
              decoration: BoxDecoration(
                color: widget.selected
                    ? widget.theme.primaryColor
                    : (isHovered
                          ? widget.theme.primaryColor.withOpacity(0.5)
                          : Colors.transparent),
                borderRadius: BorderRadius.circular(2),
                boxShadow: widget.selected || isHovered
                    ? [
                        BoxShadow(
                          color: widget.theme.primaryColor.withOpacity(0.18),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
