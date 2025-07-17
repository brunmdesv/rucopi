import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_padrao.dart';
import '../theme/app_styles.dart';
import 'detalhes_solicitacao_page.dart';

class HistoricoSolicitacoesPage extends StatefulWidget {
  const HistoricoSolicitacoesPage({Key? key}) : super(key: key);

  @override
  State<HistoricoSolicitacoesPage> createState() =>
      _HistoricoSolicitacoesPageState();
}

class _HistoricoSolicitacoesPageState extends State<HistoricoSolicitacoesPage> {
  bool loading = true;
  List<dynamic> solicitacoes = [];

  @override
  void initState() {
    super.initState();
    _carregarSolicitacoes();
  }

  Future<void> _carregarSolicitacoes() async {
    setState(() {
      loading = true;
    });

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        loading = false;
      });
      return;
    }

    try {
      final resp = await Supabase.instance.client
          .from('solicitacoes')
          .select('descricao, status, criado_em, tipo_entulho, endereco, fotos')
          .eq('morador_id', user.id)
          .order('criado_em', ascending: false);

      setState(() {
        solicitacoes = resp;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return Colors.orange;
      case 'em_andamento':
        return Colors.blue;
      case 'concluido':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return theme.primaryColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return Icons.schedule_outlined;
      case 'em_andamento':
        return Icons.autorenew_outlined;
      case 'concluido':
        return Icons.check_circle_outline;
      case 'cancelado':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return 'Pendente';
      case 'em_andamento':
        return 'Em Andamento';
      case 'concluido':
        return 'Concluído';
      case 'cancelado':
        return 'Cancelado';
      default:
        return status;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Data não disponível';

    final date = DateTime.tryParse(dateString);
    if (date == null) return 'Data inválida';

    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPadrao(
      titulo: 'Histórico de Solicitações',
      leading: Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : solicitacoes.isEmpty
          ? _buildEmptyState(theme)
          : RefreshIndicator(
              onRefresh: _carregarSolicitacoes,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.section),
                itemCount: solicitacoes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final solicitacao = solicitacoes[index];
                  return _buildSolicitacaoCard(solicitacao, theme);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: theme.primaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma solicitação encontrada',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Suas solicitações de coleta aparecerão aqui',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolicitacaoCard(dynamic solicitacao, ThemeData theme) {
    final status = solicitacao['status'] ?? 'pendente';
    final statusColor = _getStatusColor(status, theme);
    final statusIcon = _getStatusIcon(status);
    final statusText = _getStatusText(status);

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalhesSolicitacaoPage(solicitacao: solicitacao),
          ),
        );
      },
      child: Card(
        color: theme.cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.section),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      solicitacao['descricao'] ?? 'Sem descrição',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Informações adicionais
              if (solicitacao['tipo_entulho'] != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      color: theme.primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tipo:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        solicitacao['tipo_entulho'],
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              if (solicitacao['endereco'] != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: theme.primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Endereço:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        solicitacao['endereco'],
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Data da solicitação
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: theme.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Data:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(solicitacao['criado_em']),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),

              // Indicador de fotos se existirem
              if (solicitacao['fotos'] != null &&
                  solicitacao['fotos'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.photo_outlined,
                      color: theme.colorScheme.secondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Possui fotos anexadas',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
