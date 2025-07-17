import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'nova_solicitacao_page.dart';
import 'historico_solicitacoes_page.dart';
import 'meu_perfil_page.dart';
import '../widgets/app_padrao.dart';
import '../theme/app_styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String nomeUsuario = '';
  int solicitacoesPendentes = 0;
  int solicitacoesTotais = 0;
  bool loading = true;
  List<dynamic> solicitacoesRecentes = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _carregarSolicitacoesRecentes();
  }

  Future<void> _carregarDados() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        nomeUsuario = 'Usuário';
        loading = false;
      });
      return;
    }
    final moradorId = user.id;
    // Buscar nome do morador
    final moradorResp = await Supabase.instance.client
        .from('moradores')
        .select('nome')
        .eq('id', moradorId)
        .single();
    final nome = moradorResp != null && moradorResp['nome'] != null
        ? moradorResp['nome'] as String
        : 'Usuário';
    // Buscar solicitações
    final solicitacoesResp = await Supabase.instance.client
        .from('solicitacoes')
        .select('status')
        .eq('morador_id', moradorId);
    final total = solicitacoesResp.length;
    final pendentes = solicitacoesResp
        .where((s) => s['status'] == 'pendente')
        .length;
    setState(() {
      nomeUsuario = nome;
      solicitacoesTotais = total;
      solicitacoesPendentes = pendentes;
      loading = false;
    });
  }

  Future<void> _carregarSolicitacoesRecentes() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        solicitacoesRecentes = [];
      });
      return;
    }
    try {
      final resp = await Supabase.instance.client
          .from('solicitacoes')
          .select('descricao, status, criado_em, endereco, tipo_entulho')
          .eq('morador_id', user.id)
          .order('criado_em', ascending: false)
          .limit(2);
      setState(() {
        solicitacoesRecentes = resp;
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
    return AppPadrao(
      titulo: 'Rucopi',
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MeuPerfilPage()),
            );
          },
        ),
      ],
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregarDados,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header com informações do usuário
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.section),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.primaryColor.withOpacity(0.1),
                            theme.primaryColor.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: theme.primaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nomeUsuario,
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.primaryColor,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Bem-vindo ao sistema de coletas',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme
                                                .textTheme
                                                .bodySmall
                                                ?.color,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Seção de estatísticas
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.section,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Label na primeira linha
                                  Text(
                                    'Pendentes',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Icone e quantidade na segunda linha
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor.withOpacity(
                                            0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.schedule_outlined,
                                          color: theme.primaryColor,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        solicitacoesPendentes.toString(),
                                        style: theme.textTheme.headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.primaryColor,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withOpacity(
                                  0.08,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Label na primeira linha
                                  Text(
                                    'Total',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.secondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Icone e quantidade na segunda linha
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.secondary
                                              .withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.analytics_outlined,
                                          color: theme.colorScheme.secondary,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        solicitacoesTotais.toString(),
                                        style: theme.textTheme.headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Botão principal
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.section,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NovaSolicitacaoPage(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.primaryColor,
                                theme.primaryColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Solicitar Nova Coleta',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    // Seção Histórico de Solicitações
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.section,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Separador visual
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 1.5,
                                  color: theme.dividerColor.withOpacity(0.5),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Icon(
                                  Icons.history,
                                  color: theme.primaryColor,
                                  size: 28,
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 1.5,
                                  color: theme.dividerColor.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (solicitacoesRecentes.isEmpty)
                            Text(
                              'Nenhuma solicitação recente.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          for (final solicitacao in solicitacoesRecentes)
                            _buildSolicitacaoResumoCard(context, solicitacao),
                          if (solicitacoesRecentes.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HistoricoSolicitacoesPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.list_alt),
                                label: const Text('Ver todas as solicitações'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  textStyle: theme.textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolicitacaoResumoCard(
    BuildContext context,
    dynamic solicitacao,
  ) {
    final theme = Theme.of(context);
    final status = (solicitacao['status'] ?? 'pendente').toLowerCase();
    final isConcluida = status == 'concluido';
    final statusIcon = isConcluida
        ? Icons.check_circle_outline
        : Icons.schedule_outlined;
    final statusColor = isConcluida ? Colors.green : Colors.orange;
    final statusText = isConcluida ? 'Concluída' : 'Pendente';
    final endereco = solicitacao['endereco'] ?? 'Sem endereço';
    final data = solicitacao['criado_em'] != null
        ? DateTime.tryParse(solicitacao['criado_em'])
        : null;
    final dataStr = data != null
        ? '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}'
        : 'Data não disponível';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    statusText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: theme.primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(dataStr, style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              endereco,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
