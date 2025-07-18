import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_styles.dart';
import 'solicitacoes_page.dart';
import 'configuracoes_page.dart';
import '../widgets/sidebar.dart';

enum DashboardScreen {
  dashboard,
  solicitacoes,
  configuracoes,
  // Adicione outros se necessário
}

class DashboardHomePage extends StatefulWidget {
  const DashboardHomePage({super.key});

  @override
  State<DashboardHomePage> createState() => _DashboardHomePageState();
}

class _DashboardHomePageState extends State<DashboardHomePage> {
  int total = 0;
  int pendentes = 0;
  int andamento = 0;
  int concluidas = 0;
  bool carregando = true;
  String? erro;
  List<dynamic> solicitacoesRecentes = [];
  bool sidebarExpanded = true;
  DashboardScreen currentScreen = DashboardScreen.dashboard;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([buscarResumo(), buscarSolicitacoesRecentes()]);
  }

  Future<void> buscarResumo() async {
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

  Future<void> buscarSolicitacoesRecentes() async {
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

  void _onSidebarSelect(DashboardScreen screen) {
    setState(() {
      currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F0F)
          : const Color(0xFFF8FAFC),
      body: Row(
        children: [
          Sidebar(
            sidebarExpanded: sidebarExpanded,
            onToggle: () {
              setState(() {
                sidebarExpanded = !sidebarExpanded;
              });
            },
            theme: theme,
            isDark: isDark,
            parentContext: context,
            onSelect: _onSidebarSelect,
            currentScreen: currentScreen,
          ),
          Expanded(child: _buildScreenContent(theme, isDark)),
        ],
      ),
    );
  }

  Widget _buildScreenContent(ThemeData theme, bool isDark) {
    switch (currentScreen) {
      case DashboardScreen.dashboard:
        return carregando
            ? _buildLoadingScreen(theme)
            : erro != null
            ? _buildErrorScreen(theme)
            : _buildMainContent(theme, isDark);
      case DashboardScreen.solicitacoes:
        return const SolicitacoesPage();
      case DashboardScreen.configuracoes:
        return const ConfiguracoesPage();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLoadingScreen(ThemeData theme) {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorScreen(ThemeData theme) {
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
          Text(erro ?? 'Erro desconhecido', style: theme.textTheme.bodyMedium),
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

  Widget _buildMainContent(ThemeData theme, bool isDark) {
    return Column(
      children: [
        _buildTopBar(theme, isDark),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeHeader(theme, isDark),
                const SizedBox(height: 32),
                _buildStatsGrid(theme, isDark),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildRecentRequestsSection(theme, isDark),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildQuickStats(theme, isDark),
                          const SizedBox(height: 24),
                          _buildQuickActions(theme, isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(ThemeData theme, bool isDark) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Dashboard',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.person_rounded, color: theme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo ao Sistema Rucopi',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitore e gerencie todas as solicitações de coleta de entulho',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.eco_rounded, size: 32, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth < 1100) crossAxisCount = 2;
        if (constraints.maxWidth < 700) crossAxisCount = 1;
        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            SizedBox(
              width: constraints.maxWidth / crossAxisCount - 24,
              child: _buildStatCard(
                title: 'Total de Solicitações',
                value: total,
                icon: Icons.assignment_rounded,
                color: theme.primaryColor,
                theme: theme,
                isDark: isDark,
              ),
            ),
            SizedBox(
              width: constraints.maxWidth / crossAxisCount - 24,
              child: _buildStatCard(
                title: 'Aguardando Coleta',
                value: pendentes,
                icon: Icons.access_time_rounded,
                color: const Color(0xFFFF9800),
                theme: theme,
                isDark: isDark,
              ),
            ),
            SizedBox(
              width: constraints.maxWidth / crossAxisCount - 24,
              child: _buildStatCard(
                title: 'Em Andamento',
                value: andamento,
                icon: Icons.local_shipping_rounded,
                color: const Color(0xFF2196F3),
                theme: theme,
                isDark: isDark,
              ),
            ),
            SizedBox(
              width: constraints.maxWidth / crossAxisCount - 24,
              child: _buildStatCard(
                title: 'Concluídas',
                value: concluidas,
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF4CAF50),
                theme: theme,
                isDark: isDark,
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
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRequestsSection(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Solicitações Recentes',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SolicitacoesPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('Ver todas'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 400,
            child: solicitacoesRecentes.isEmpty
                ? _buildEmptyState(theme)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: solicitacoesRecentes.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return _buildSolicitacaoListItem(
                        solicitacoesRecentes[index],
                        theme,
                        isDark,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusConfig['color'].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusConfig['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              statusConfig['icon'],
              size: 16,
              color: statusConfig['color'],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  endereco,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  tipoEntulho,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusConfig['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusConfig['text'],
                  style: TextStyle(
                    color: statusConfig['color'],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dataStr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.disabledColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickStatItem(
            'Taxa de Conclusão',
            total > 0
                ? '${((concluidas / total) * 100).toStringAsFixed(1)}%'
                : '0%',
            Icons.trending_up_rounded,
            const Color(0xFF4CAF50),
            theme,
          ),
          const SizedBox(height: 12),
          _buildQuickStatItem(
            'Tempo Médio',
            '2.5 dias',
            Icons.access_time_rounded,
            const Color(0xFF2196F3),
            theme,
          ),
          const SizedBox(height: 12),
          _buildQuickStatItem(
            'Eficiência',
            '89%',
            Icons.speed_rounded,
            const Color(0xFFFF9800),
            theme,
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
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: theme.textTheme.bodySmall)),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SolicitacoesPage()),
                );
              },
              icon: const Icon(Icons.list_alt_rounded, size: 18),
              label: const Text('Ver Solicitações'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _loadData();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Atualizar Dados'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
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
}
