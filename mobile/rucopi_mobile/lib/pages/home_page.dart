import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'nova_solicitacao_page.dart';
import 'historico_solicitacoes_page.dart';
import 'meu_perfil_page.dart';
import '../widgets/app_padrao.dart';
import '../theme/app_styles.dart';
import 'detalhes_solicitacao_page.dart';
import 'configuracoes_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onAdd;
  final VoidCallback? onConfig;
  const HomePage({Key? key, this.onAdd, this.onConfig}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String nomeUsuario = '';
  int solicitacoesPendentes = 0;
  int solicitacoesTotais = 0;
  bool loading = true;
  List<dynamic> solicitacoesRecentes = [];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _carregarDados();
      // _carregarSolicitacoesRecentes() não é mais necessário
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _carregarDados();
    // _carregarSolicitacoesRecentes() não é mais necessário
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

  // _carregarSolicitacoesRecentes() não é mais necessário

  void atualizarDados() {
    _carregarDados();
    // _carregarSolicitacoesRecentes() não é mais necessário
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Supabase.instance.client.auth.currentUser;
    // Calcular quantidade de agendadas
    final agendadasCount = solicitacoesRecentes
        .where((s) => (s['status'] ?? '').toLowerCase() == 'agendada')
        .length;
    return AppPadrao(
      titulo: 'Rucopi',
      leading: IconButton(
        icon: const Icon(Icons.account_circle),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MeuPerfilPage()),
          );
        },
      ),
      actions: [
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: user == null
              ? null
              : Supabase.instance.client
                    .from('notificacoes')
                    .stream(primaryKey: ['id'])
                    .eq('morador_id', user.id)
                    .order('criada_em', ascending: false)
                    .limit(30),
          builder: (context, snapshot) {
            final notificacoes = snapshot.data ?? [];
            final notificacoesNaoLidas = notificacoes
                .where((n) => n['lida'] == false)
                .toList();
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: notificacoes.isEmpty
                      ? null
                      : () async {
                          await showDialog(
                            context: context,
                            builder: (context) => _DialogNotificacoes(
                              notificacoes: notificacoes,
                              onMarcarComoLidas: () async {
                                final idsNaoLidas = notificacoesNaoLidas
                                    .map((n) => n['id'])
                                    .toList();
                                if (idsNaoLidas.isNotEmpty) {
                                  await Supabase.instance.client
                                      .from('notificacoes')
                                      .update({'lida': true})
                                      .inFilter('id', idsNaoLidas);
                                }
                              },
                            ),
                          );
                        },
                ),
                if (notificacoesNaoLidas.isNotEmpty)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.cardColor, width: 1.5),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header com informações do usuário
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MeuPerfilPage(),
                        ),
                      );
                    },
                    child: HomeSectionCard(
                      margin: const EdgeInsets.only(top: 2, bottom: 8),
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
                                      _primeiroNomeESobrenome(nomeUsuario),
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
                  ),
                  const SizedBox(height: 0),
                  // Seção de estatísticas + botão principal em um único card
                  HomeSectionCard(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: buildStatCard(
                                context: context,
                                icon: Icons.schedule_outlined,
                                label: 'Pendentes',
                                value: solicitacoesPendentes.toString(),
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: StreamBuilder<List<Map<String, dynamic>>>(
                                stream: user == null
                                    ? null
                                    : Supabase.instance.client
                                          .from('solicitacoes')
                                          .stream(primaryKey: ['id'])
                                          .map(
                                            (rows) => rows
                                                .where(
                                                  (row) =>
                                                      row['morador_id'] ==
                                                          user.id &&
                                                      (row['status'] ?? '')
                                                              .toLowerCase() ==
                                                          'agendada',
                                                )
                                                .toList(),
                                          ),
                                builder: (context, snapshot) {
                                  final agendadasCount = snapshot.hasData
                                      ? snapshot.data!.length
                                      : 0;
                                  return buildStatCard(
                                    context: context,
                                    icon: Icons.event_available,
                                    label: 'Agendadas',
                                    value: agendadasCount.toString(),
                                    color: theme.primaryColor,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: buildStatCard(
                                context: context,
                                icon: Icons.analytics_outlined,
                                label: 'Total',
                                value: solicitacoesTotais.toString(),
                                color: theme.brightness == Brightness.dark
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Botão principal
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NovaSolicitacaoPage(),
                              ),
                            );
                            if (result == true) {
                              await _carregarDados();
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
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
                                  color: theme.colorScheme.onPrimary,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Solicitar Nova Coleta',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 0),
                  // Seção Histórico de Solicitações em um único card
                  HomeSectionCard(
                    margin: const EdgeInsets.only(top: 5, bottom: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Separador visual com texto
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
                              child: Text(
                                'Histórico de Solicitações',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withOpacity(0.7),
                                  fontWeight: FontWeight.w600,
                                ),
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
                        const SizedBox(height: 15),
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: user == null
                              ? null
                              : Supabase.instance.client
                                    .from('solicitacoes')
                                    .stream(primaryKey: ['id'])
                                    .eq('morador_id', user.id)
                                    .order('criado_em', ascending: true),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final solicitacoesRecentes = snapshot.data!;
                            if (solicitacoesRecentes.isEmpty) {
                              return Text(
                                'Nenhuma solicitação recente.',
                                style: theme.textTheme.bodyMedium,
                              );
                            }
                            return Column(
                              children: [
                                for (final solicitacao
                                    in solicitacoesRecentes.take(2))
                                  _buildSolicitacaoResumoCard(
                                    context,
                                    solicitacao,
                                  ),
                                if (solicitacoesRecentes.isNotEmpty) ...[
                                  const SizedBox(height: 0),
                                  Center(
                                    child: SizedBox(
                                      width: double.infinity,
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
                                        label: const Text(
                                          'Ver todas as solicitações',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: theme.primaryColor,
                                          foregroundColor:
                                              theme.colorScheme.onPrimary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 20,
                                          ),
                                          textStyle: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.onPrimary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
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
            const SizedBox(width: 6),
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
    Color statusColor;
    IconData statusIcon;
    String statusText;
    switch (status) {
      case 'pendente':
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.schedule_outlined;
        statusText = 'Pendente';
        break;
      case 'agendada':
        statusColor = theme.primaryColor;
        statusIcon = Icons.event_available;
        statusText = 'Agendada';
        break;
      case 'coletando':
        statusColor = theme.colorScheme.primary;
        statusIcon = Icons.local_shipping;
        statusText = 'Coletando';
        break;
      case 'concluido':
        statusColor = theme.primaryColor;
        statusIcon = Icons.check_circle_outline;
        statusText = 'Concluído';
        break;
      case 'cancelado':
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.cancel_outlined;
        statusText = 'Cancelado';
        break;
      default:
        statusColor = theme.primaryColor;
        statusIcon = Icons.help_outline;
        statusText = status;
    }
    final endereco = solicitacao['endereco'] ?? 'Sem endereço';
    final tipoEntulho = solicitacao['tipo_entulho'] ?? 'Não informado';
    final data = solicitacao['criado_em'] != null
        ? DateTime.tryParse(solicitacao['criado_em'])
        : null;
    final dataStr = data != null
        ? '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}'
        : 'Data não disponível';
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetalhesSolicitacaoPage(solicitacao: solicitacao),
          ),
        );
        if (result == true) {
          await _carregarDados();
          // _carregarSolicitacoesRecentes() não é mais necessário
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
                    Icon(statusIcon, color: statusColor, size: 20),
                    const SizedBox(width: 6),
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
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(dataStr, style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Tipo de entulho: $tipoEntulho',
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Função utilitária para exibir apenas o primeiro nome e sobrenome
String _primeiroNomeESobrenome(String nomeCompleto) {
  final partes = nomeCompleto.trim().split(' ');
  if (partes.length <= 2) return nomeCompleto;
  return '${partes[0]} ${partes[1]}';
}

// Widget reutilizável para padronizar os cards/seções da home
class HomeSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  const HomeSectionCard({required this.child, this.margin, Key? key})
    : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

Widget buildStatCard({
  required BuildContext context,
  required IconData icon,
  required String label,
  required String value,
  required Color color,
}) {
  final theme = Theme.of(context);
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 0),
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

class _DialogNotificacoes extends StatelessWidget {
  final List<Map<String, dynamic>> notificacoes;
  final Future<void> Function() onMarcarComoLidas;
  const _DialogNotificacoes({
    required this.notificacoes,
    required this.onMarcarComoLidas,
    Key? key,
  }) : super(key: key);

  String _mensagemNotificacao(Map<String, dynamic> n) {
    final tipo = n['tipo_entulho'] ?? '';
    final status = n['status'] ?? '';
    if (tipo.isNotEmpty && status.isNotEmpty) {
      return 'O status da solicitação de entulho do tipo "$tipo" mudou para "$status".';
    }
    return n['mensagem'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => onMarcarComoLidas());
    return Dialog(
      backgroundColor: theme.dialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        width: 340,
        constraints: const BoxConstraints(maxHeight: 480),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications, color: Colors.orange, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Notificações',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Fechar',
                ),
              ],
            ),
            const Divider(height: 18),
            if (notificacoes.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 32, bottom: 32),
                child: Center(
                  child: Text(
                    'Nenhuma notificação.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: notificacoes.length,
                  separatorBuilder: (_, __) => const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final n = notificacoes[index];
                    final data = n['criada_em'] != null
                        ? DateTime.tryParse(n['criada_em'])
                        : null;
                    final dataStr = data != null
                        ? '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}'
                        : '';
                    final idSolic = (n['solicitacao_id'] ?? '').toString();
                    final idTag = idSolic.length >= 5
                        ? idSolic.substring(0, 5)
                        : idSolic;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        color: n['lida'] == true
                            ? theme.disabledColor.withOpacity(0.07)
                            : theme.primaryColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: n['lida'] == true
                              ? theme.disabledColor.withOpacity(0.12)
                              : theme.primaryColor.withOpacity(0.13),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            n['lida'] == true
                                ? Icons.notifications_none
                                : Icons.notifications_active,
                            color: n['lida'] == true
                                ? theme.disabledColor
                                : theme.primaryColor,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.primaryColor.withOpacity(
                                          0.16,
                                        ),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: Text(
                                        dataStr,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontSize: 11,
                                              color: theme.primaryColor,
                                            ),
                                      ),
                                    ),
                                    if (idTag.isNotEmpty) ...[
                                      const SizedBox(width: 7),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.dividerColor.withOpacity(
                                            0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            7,
                                          ),
                                        ),
                                        child: Text(
                                          idTag,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontSize: 11,
                                                color: theme
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ],
                                    if (n['lida'] != true)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.error
                                                .withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Text(
                                            'Nova',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _mensagemNotificacao(n),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 13,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (n['lida'] != true)
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                                size: 20,
                              ),
                              tooltip: 'Marcar como lida',
                              onPressed: () async {
                                await Supabase.instance.client
                                    .from('notificacoes')
                                    .update({'lida': true})
                                    .eq('id', n['id']);
                                Navigator.of(context).pop();
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
