import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_styles.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class DetalhesSolicitacaoDialog extends StatefulWidget {
  final Map<String, dynamic> solicitacao;
  const DetalhesSolicitacaoDialog({Key? key, required this.solicitacao})
    : super(key: key);

  @override
  State<DetalhesSolicitacaoDialog> createState() =>
      _DetalhesSolicitacaoDialogState();
}

class _DetalhesSolicitacaoDialogState extends State<DetalhesSolicitacaoDialog> {
  Map<String, dynamic>? morador;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _carregarMorador();
  }

  Future<void> _carregarMorador() async {
    final moradorId = widget.solicitacao['morador_id'];
    if (moradorId == null) {
      setState(() {
        loading = false;
      });
      return;
    }
    try {
      final resp = await Supabase.instance.client
          .from('moradores')
          .select()
          .eq('id', moradorId)
          .single();
      setState(() {
        morador = resp;
        loading = false;
      });
    } catch (e) {
      setState(() {
        morador = null;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final solicitacao = widget.solicitacao;
    final fotos = solicitacao['fotos'] is List
        ? List<String>.from(solicitacao['fotos'])
        : <String>[];
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: width < 600 ? width * 0.98 : 700,
          maxHeight: MediaQuery.of(context).size.height * 0.95,
        ),
        decoration: BoxDecoration(
          color: theme.dialogBackgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header colorido
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppRadius.card),
                        topRight: Radius.circular(AppRadius.card),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.assignment_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Detalhes da Solicitação',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Status destacado
                          _buildStatusCard(theme, solicitacao),
                          const SizedBox(height: 20),
                          // Card do Morador
                          Card(
                            elevation: 6,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.card,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        color: theme.primaryColor,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Informações do Morador',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.primaryColor,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  _infoRow('Nome', morador?['nome']),
                                  _infoRow('E-mail', morador?['email']),
                                  _infoRow('Whatsapp', morador?['whatsapp']),
                                  _infoRow('CPF', morador?['cpf']),
                                  _infoRow('Endereço', morador?['endereco']),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Card da Solicitação
                          Card(
                            elevation: 6,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.card,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.assignment,
                                        color: theme.primaryColor,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Informações da Solicitação',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.primaryColor,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  _infoRow(
                                    'Descrição',
                                    solicitacao['descricao'],
                                  ),
                                  _infoRow(
                                    'Tipo de Entulho',
                                    solicitacao['tipo_entulho'],
                                  ),
                                  _infoRow('Endereço', solicitacao['endereco']),
                                  _infoRow('Status', solicitacao['status']),
                                  _infoRow(
                                    'Data de Criação',
                                    _formatDate(solicitacao['criado_em']),
                                  ),
                                  if (fotos.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Text(
                                      'Fotos Anexadas:',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 100,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: fotos.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 8),
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () => _showImageGallery(
                                              context,
                                              fotos,
                                              index,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                fotos[index],
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
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

  Widget _buildStatusCard(ThemeData theme, Map solicitacao) {
    final status = solicitacao['status']?.toString().toLowerCase() ?? '';
    Color color;
    String label;
    IconData icon;
    switch (status) {
      case 'pendente':
        color = Colors.orange;
        label = 'Aguardando Coleta';
        icon = Icons.schedule_rounded;
        break;
      case 'em andamento':
        color = Colors.blue;
        label = 'Em Andamento';
        icon = Icons.local_shipping_rounded;
        break;
      case 'concluida':
      case 'concluído':
        color = Colors.green;
        label = 'Concluída';
        icon = Icons.check_circle_rounded;
        break;
      default:
        color = theme.primaryColor;
        label = status.isNotEmpty ? status : 'Indefinido';
        icon = Icons.help_outline_rounded;
    }
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      color: color.withOpacity(0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status atual da solicitação',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.disabledColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    try {
      final dateTime = DateTime.tryParse(date.toString());
      if (dateTime != null) {
        return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {}
    return date.toString();
  }

  void _showImageGallery(
    BuildContext context,
    List<String> fotos,
    int initialIndex,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      builder: (context) {
        int currentIndex = initialIndex;
        return StatefulBuilder(
          builder: (context, setState) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.98,
                      maxWidth: MediaQuery.of(context).size.width * 0.98,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: PhotoView(
                        imageProvider: NetworkImage(fotos[currentIndex]),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 2.5,
                        heroAttributes: PhotoViewHeroAttributes(
                          tag: fotos[currentIndex],
                        ),
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  // Botão de download e botão de fechar removidos
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _downloadImage(String url) async {
    // Para web/mobile, pode-se usar url_launcher para abrir a imagem em nova aba
    // ou implementar download nativo para desktop/mobile
    // Aqui, vamos abrir em nova aba (web) ou tentar baixar
    // Para Flutter web:
    // ignore: avoid_web_libraries_in_flutter
    try {
      // ignore: undefined_prefixed_name
      // Para web
      // import 'dart:html' as html;
      // html.AnchorElement(href: url)
      //   ..setAttribute('download', '')
      //   ..click();
      // Para mobile/desktop, pode-se usar url_launcher:
      // import 'package:url_launcher/url_launcher.dart';
      // await launch(url);
      // Aqui, só abrirá a imagem em nova aba/aba de download
      // (o usuário pode salvar manualmente)
      //
      // Para multiplataforma, tente url_launcher:
      //
      // import 'package:url_launcher/url_launcher.dart';
      // await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      //
      // Para simplificar, vamos tentar url_launcher se disponível:
      //
      // Se não tiver url_launcher, apenas mostre um aviso
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao baixar imagem: $e')));
    }
  }
}
