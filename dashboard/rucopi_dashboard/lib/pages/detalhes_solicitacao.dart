import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_styles.dart';

class DetalhesSolicitacaoDialog extends StatefulWidget {
  final Map<String, dynamic> solicitacao;

  const DetalhesSolicitacaoDialog({required this.solicitacao, Key? key})
    : super(key: key);

  @override
  State<DetalhesSolicitacaoDialog> createState() =>
      _DetalhesSolicitacaoDialogState();
}

class _DetalhesSolicitacaoDialogState extends State<DetalhesSolicitacaoDialog> {
  bool _loading = false;
  Map<String, dynamic>? _detalhesCompletos;

  @override
  void initState() {
    super.initState();
    _carregarDetalhesCompletos();
  }

  Future<void> _carregarDetalhesCompletos() async {
    setState(() {
      _loading = true;
    });

    try {
      // Buscar detalhes completos da solicitação incluindo informações do morador
      final response = await Supabase.instance.client
          .from('solicitacoes')
          .select('''
            *,
            moradores!inner(
              id,
              nome,
              telefone,
              email
            )
          ''')
          .eq('id', widget.solicitacao['id'])
          .single();

      setState(() {
        _detalhesCompletos = response;
      });
    } catch (e) {
      // Se falhar, usar os dados básicos
      setState(() {
        _detalhesCompletos = widget.solicitacao;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pendente':
        return const Color(0xFFFF9800);
      case 'em andamento':
        return const Color(0xFF2196F3);
      case 'concluida':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'pendente':
        return Icons.schedule_rounded;
      case 'em andamento':
        return Icons.local_shipping_rounded;
      case 'concluida':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pendente':
        return 'Aguardando Coleta';
      case 'em andamento':
        return 'Em Andamento';
      case 'concluida':
        return 'Concluída';
      default:
        return 'Indefinido';
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Data não informada';
    try {
      final dateTime = DateTime.tryParse(date.toString());
      if (dateTime != null) {
        return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return date.toString();
  }

  List<String> _getFotos(Map<String, dynamic> solicitacao) {
    if (solicitacao['fotos'] is List) {
      return List<String>.from(solicitacao['fotos']);
    }
    return <String>[];
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
            maxWidth: MediaQuery.of(context).size.width * 0.95,
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
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              // Imagem em qualidade completa
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      // Sem limitação de tamanho para qualidade completa
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 400,
                          color: Colors.black87,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Carregando imagem...',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                                if (loadingProgress.expectedTotalBytes !=
                                    null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '${((loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!) * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 400,
                          color: Colors.black87,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white54,
                                size: 48,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Erro ao carregar imagem',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Verifique sua conexão e tente novamente',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final solicitacao = _detalhesCompletos ?? widget.solicitacao;
    final fotos = _getFotos(solicitacao);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: width < 600 ? width * 0.95 : 700,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.card),
                  topRight: Radius.circular(AppRadius.card),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.assignment_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalhes da Solicitação',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: #${solicitacao['id']}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                solicitacao['status'],
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStatusColor(
                                  solicitacao['status'],
                                ).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getStatusIcon(solicitacao['status']),
                                  color: _getStatusColor(solicitacao['status']),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getStatusText(solicitacao['status']),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: _getStatusColor(
                                                solicitacao['status'],
                                              ),
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Status atual da solicitação',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.disabledColor,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Informações do Morador
                          _buildInfoSection(
                            theme,
                            'Informações do Morador',
                            Icons.person_rounded,
                            [
                              _buildInfoRow(
                                'Nome',
                                solicitacao['nome_morador'] ?? 'Não informado',
                              ),
                              _buildInfoRow(
                                'Telefone',
                                solicitacao['moradores']?['telefone'] ??
                                    'Não informado',
                              ),
                              _buildInfoRow(
                                'E-mail',
                                solicitacao['moradores']?['email'] ??
                                    'Não informado',
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Informações da Solicitação
                          _buildInfoSection(
                            theme,
                            'Informações da Solicitação',
                            Icons.assignment_rounded,
                            [
                              _buildInfoRow(
                                'Descrição',
                                solicitacao['descricao'] ?? 'Não informado',
                              ),
                              _buildInfoRow(
                                'Endereço',
                                solicitacao['endereco'] ?? 'Não informado',
                              ),
                              _buildInfoRow(
                                'Data de Criação',
                                _formatDate(solicitacao['criado_em']),
                              ),
                              if (solicitacao['atualizado_em'] != null)
                                _buildInfoRow(
                                  'Última Atualização',
                                  _formatDate(solicitacao['atualizado_em']),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Fotos Anexadas
                          if (fotos.isNotEmpty)
                            _buildFotosSection(theme, fotos),

                          const SizedBox(height: 24),

                          // Informações Adicionais
                          if (solicitacao['observacoes'] != null &&
                              solicitacao['observacoes'].toString().isNotEmpty)
                            _buildInfoSection(
                              theme,
                              'Observações',
                              Icons.note_rounded,
                              [
                                _buildInfoRow(
                                  'Observações',
                                  solicitacao['observacoes'],
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
    );
  }

  Widget _buildFotosSection(ThemeData theme, List<String> fotos) {
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF1A1A1A)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF2A2A2A)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
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
                  Icons.photo_library_rounded,
                  color: theme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Fotos Anexadas',
                  style: theme.textTheme.titleMedium?.copyWith(
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
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // Mais colunas para miniaturas menores
                crossAxisSpacing: 8, // Espaçamento menor
                mainAxisSpacing: 8,
                childAspectRatio: 1, // Mantém proporção quadrada
              ),
              itemCount: fotos.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _showImageDialog(context, fotos[index]);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8), // Bordas menores
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        fotos[index],
                        fit: BoxFit.cover,
                        width: 60, // Tamanho fixo pequeno
                        height: 60,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 60,
                            height: 60,
                            color: theme.scaffoldBackgroundColor,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: theme.scaffoldBackgroundColor,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.5),
                                  size: 20,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Erro',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodyMedium?.color
                                        ?.withOpacity(0.5),
                                    fontSize: 8,
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
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    ThemeData theme,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF1A1A1A)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF2A2A2A)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: theme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.disabledColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
