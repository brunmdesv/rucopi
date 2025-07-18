import 'package:flutter/material.dart';
import '../theme/app_styles.dart';
import 'solicitacoes_page.dart';
import 'configuracoes_page.dart';
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
          Expanded(
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
    final isHovered = hoveredScreen == screenType;
    return MouseRegion(
      onEnter: (_) => setState(() => hoveredScreen = screenType),
      onExit: (_) => setState(() => hoveredScreen = null),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? theme.primaryColor : theme.disabledColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12, // Tamanho menor para a label
                color: selected ? theme.primaryColor : theme.disabledColor,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.ease,
              height: 3,
              width: selected || isHovered ? 28 : 0,
              decoration: BoxDecoration(
                color: selected
                    ? theme.primaryColor
                    : (isHovered
                          ? theme.primaryColor.withOpacity(0.5)
                          : Colors.transparent),
                borderRadius: BorderRadius.circular(2),
                boxShadow: selected || isHovered
                    ? [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.18),
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
  int total = 0;
  int pendentes = 0;
  int andamento = 0;
  int concluidas = 0;
  bool carregando = true;
  String? erro;
  List<dynamic> solicitacoesRecentes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_buscarResumo(), _buscarSolicitacoesRecentes()]);
  }

  Future<void> _buscarResumo() async {
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      final response = await Supabase.instance.client
          .from('solicitacoes')
          .select('status');
      setState(() {
        total = response.length;
        pendentes = response.where((s) => s['status'] == 'pendente').length;
        andamento = response.where((s) => s['status'] == 'em andamento').length;
        concluidas = response.where((s) => s['status'] == 'concluida').length;
      });
    } catch (e) {
      setState(() {
        erro = 'Erro ao buscar dados: $e';
      });
    } finally {
      setState(() {
        carregando = false;
      });
    }
  }

  Future<void> _buscarSolicitacoesRecentes() async {
    try {
      final response = await Supabase.instance.client
          .from('solicitacoes')
          .select(
            'id, descricao, status, criado_em, endereco, tipo_entulho, fotos',
          )
          .order('criado_em', ascending: false)
          .limit(8);
      setState(() {
        solicitacoesRecentes = response;
      });
    } catch (e) {
      setState(() {
        solicitacoesRecentes = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (erro != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar dados',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              erro ?? 'Erro desconhecido',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    // Responsividade: padding menor em telas pequenas
    final horizontalPadding = width < 600 ? 8.0 : (width < 900 ? 16.0 : 32.0);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(theme, isDark, width),
          const SizedBox(height: 24),
          _buildStatsGrid(theme, isDark, width),
          const SizedBox(height: 24),
          _buildMainContentResponsive(theme, isDark, width),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(ThemeData theme, bool isDark, double width) {
    return Container(
      padding: EdgeInsets.all(width < 600 ? 12 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(width < 600 ? 8 : 16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo ao Sistema Rucopi',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: width < 600 ? 18 : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitore e gerencie todas as solicitações de coleta de entulho',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: width < 600 ? 13 : null,
                  ),
                ),
              ],
            ),
          ),
          if (width > 400)
            Container(
              padding: EdgeInsets.all(width < 600 ? 8 : 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(width < 600 ? 6 : 12),
              ),
              child: Icon(
                Icons.eco_rounded,
                size: width < 600 ? 24 : 32,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme, bool isDark, double width) {
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
          spacing: 16,
          runSpacing: 16,
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
        minWidth: width < 400 ? 120 : 180,
        maxWidth: 320,
      ),
      padding: EdgeInsets.all(width < 600 ? 12 : 20),
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
            padding: EdgeInsets.all(width < 600 ? 6 : 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: width < 600 ? 18 : 24),
          ),
          const SizedBox(width: 12),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: width < 600 ? 22 : 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: width < 600 ? 13 : null,
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
  ) {
    return Container(
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
          Padding(
            padding: EdgeInsets.all(width < 600 ? 12 : 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Solicitações Recentes',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: width < 600 ? 16 : null,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.arrow_forward_rounded,
                    size: width < 600 ? 13 : 16,
                  ),
                  label: Text(
                    'Ver todas',
                    style: TextStyle(fontSize: width < 600 ? 12 : null),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: width < 600 ? 260 : 400,
            child: solicitacoesRecentes.isEmpty
                ? _buildEmptyState(theme)
                : ListView.separated(
                    padding: EdgeInsets.all(width < 600 ? 8 : 16),
                    itemCount: solicitacoesRecentes.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return _buildSolicitacaoListItem(
                        solicitacoesRecentes[index],
                        theme,
                        isDark,
                        width,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolicitacaoListItem(
    dynamic solicitacao,
    ThemeData theme,
    bool isDark,
    double width,
  ) {
    final status = (solicitacao['status'] ?? 'pendente').toLowerCase();
    final statusConfig = _getStatusConfig(status);
    final endereco = solicitacao['endereco'] ?? 'Sem endereço';
    final tipoEntulho = solicitacao['tipo_entulho'] ?? 'Não informado';
    final data = solicitacao['criado_em'] != null
        ? DateTime.tryParse(solicitacao['criado_em'])
        : null;
    final dataStr = data != null
        ? '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}'
        : 'Sem data';

    return Container(
      padding: EdgeInsets.all(width < 600 ? 10 : 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(width < 600 ? 6 : 8),
        border: Border.all(
          color: statusConfig['color'].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(width < 600 ? 5 : 8),
            decoration: BoxDecoration(
              color: statusConfig['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              statusConfig['icon'],
              size: width < 600 ? 12 : 16,
              color: statusConfig['color'],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  endereco,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: width < 600 ? 12 : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  tipoEntulho,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.disabledColor,
                    fontSize: width < 600 ? 11 : null,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width < 600 ? 6 : 8,
                  vertical: width < 600 ? 2 : 4,
                ),
                decoration: BoxDecoration(
                  color: statusConfig['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusConfig['text'],
                  style: TextStyle(
                    color: statusConfig['color'],
                    fontSize: width < 600 ? 9 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dataStr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.disabledColor,
                  fontSize: width < 600 ? 9 : 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme, bool isDark, double width) {
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
              onPressed: _loadData,
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

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: theme.disabledColor),
          const SizedBox(height: 16),
          Text(
            'Nenhuma solicitação encontrada',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.disabledColor,
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
  ) {
    if (width < 900) {
      // Tablet/mobile: empilha as colunas
      return Column(
        children: [
          _buildRecentRequestsSection(theme, isDark, width),
          const SizedBox(height: 16),
          _buildQuickStats(theme, isDark, width),
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
            child: _buildRecentRequestsSection(theme, isDark, width),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildQuickStats(theme, isDark, width),
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
