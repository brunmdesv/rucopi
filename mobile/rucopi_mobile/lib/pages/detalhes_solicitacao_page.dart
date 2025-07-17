import 'package:flutter/material.dart';
import '../widgets/app_padrao.dart';
import '../theme/app_styles.dart';

class DetalhesSolicitacaoPage extends StatelessWidget {
  final Map<String, dynamic> solicitacao;
  const DetalhesSolicitacaoPage({Key? key, required this.solicitacao})
      : super(key: key);

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
    
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = solicitacao['status'] ?? 'pendente';
    final statusColor = _getStatusColor(status, theme);
    final statusIcon = _getStatusIcon(status);
    final statusText = _getStatusText(status);
    
    final fotos = solicitacao['fotos'] is List
        ? List<String>.from(solicitacao['fotos'])
        : <String>[];

    return AppPadrao(
      titulo: 'Detalhes da Solicitação',
      leading: Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.section),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principal com informações
            Card(
              color: theme.cardColor,
              elevation: 6,
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
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          color: theme.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Informações da Solicitação',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
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
                              Icon(
                                statusIcon,
                                color: statusColor,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
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
                    
                    const SizedBox(height: AppSpacing.section),
                    
                    // Divider
                    Divider(
                      height: 1,
                      color: theme.dividerColor.withOpacity(0.3),
                    ),
                    
                    const SizedBox(height: AppSpacing.section),
                    
                    // Descrição
                    _buildInfoSection(
                      context,
                      'Descrição',
                      solicitacao['descricao'] ?? 'Sem descrição',
                      Icons.description_outlined,
                      theme,
                    ),
                    
                    const SizedBox(height: AppSpacing.section),
                    
                    // Tipo de entulho
                    if (solicitacao['tipo_entulho'] != null) ...[
                      _buildInfoSection(
                        context,
                        'Tipo de Entulho',
                        solicitacao['tipo_entulho'],
                        Icons.category_outlined,
                        theme,
                      ),
                      const SizedBox(height: AppSpacing.section),
                    ],
                    
                    // Endereço
                    if (solicitacao['endereco'] != null) ...[
                      _buildInfoSection(
                        context,
                        'Endereço',
                        solicitacao['endereco'],
                        Icons.location_on_outlined,
                        theme,
                      ),
                      const SizedBox(height: AppSpacing.section),
                    ],
                    
                    // Data
                    _buildInfoSection(
                      context,
                      'Data da Solicitação',
                      _formatDate(solicitacao['criado_em']),
                      Icons.calendar_today_outlined,
                      theme,
                    ),
                  ],
                ),
              ),
            ),
            
            // Card de fotos se existirem
            if (fotos.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.section),
              Card(
                color: theme.cardColor,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.section),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho das fotos
                      Row(
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            color: theme.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Fotos Anexadas',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${fotos.length} foto${fotos.length > 1 ? 's' : ''}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppSpacing.section),
                      
                      // Divider
                      Divider(
                        height: 1,
                        color: theme.dividerColor.withOpacity(0.3),
                      ),
                      
                      const SizedBox(height: AppSpacing.section),
                      
                      // Grid de fotos
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: fotos.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _showImageDialog(context, fotos[index]);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.dividerColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  fotos[index],
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: theme.scaffoldBackgroundColor,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: theme.scaffoldBackgroundColor,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.broken_image_outlined,
                                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                                            size: 32,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Erro ao carregar',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: theme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Text(
            content,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botão fechar
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              // Imagem
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        color: Colors.black12,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.black12,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white54,
                              size: 48,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Erro ao carregar imagem',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}