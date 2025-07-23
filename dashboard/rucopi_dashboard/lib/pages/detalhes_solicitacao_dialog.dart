import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_styles.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

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
  late String statusSelecionado;
  bool atualizandoStatus = false;
  latlong2.LatLng? localizacao;
  bool carregandoMapa = false;
  bool _satellite = false;

  @override
  void initState() {
    super.initState();
    statusSelecionado = widget.solicitacao['status'] ?? 'pendente';
    _carregarMorador();
    _carregarLocalizacao();
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

  Future<void> _atualizarStatus(
    String novoStatus, {
    DateTime? dataAgendada,
  }) async {
    setState(() {
      atualizandoStatus = true;
    });
    try {
      if (novoStatus == 'agendada') {
        final dataParaSalvar = dataAgendada ?? DateTime.now();
        await Supabase.instance.client
            .from('solicitacoes')
            .update({
              'status': novoStatus,
              'agendada_em': DateTime.now()
                  .toIso8601String(), // registro do momento da mudança
              'data_coleta': dataParaSalvar
                  .toIso8601String(), // data escolhida pelo usuário
            })
            .eq('id', widget.solicitacao['id']);
        // Buscar o valor real salvo no banco
        final updated = await Supabase.instance.client
            .from('solicitacoes')
            .select('agendada_em, data_coleta')
            .eq('id', widget.solicitacao['id'])
            .single();
        setState(() {
          statusSelecionado = novoStatus;
          widget.solicitacao['status'] = novoStatus;
          widget.solicitacao['agendada_em'] = updated['agendada_em'];
          widget.solicitacao['data_coleta'] = updated['data_coleta'];
        });
      } else {
        await Supabase.instance.client
            .from('solicitacoes')
            .update({'status': novoStatus})
            .eq('id', widget.solicitacao['id']);
        setState(() {
          statusSelecionado = novoStatus;
          widget.solicitacao['status'] = novoStatus;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status atualizado para "$novoStatus"!')),
        );
      }
      // Enviar notificação para o morador
      final moradorId = widget.solicitacao['morador_id'];
      if (moradorId != null) {
        await Supabase.instance.client.from('notificacoes').insert({
          'morador_id': moradorId,
          'solicitacao_id': widget.solicitacao['id'],
          'mensagem':
              'O status da sua solicitação foi alterado para: $novoStatus',
          'status': novoStatus,
          'lida': false,
          'criada_em': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao atualizar status: $e')));
      }
    } finally {
      setState(() {
        atualizandoStatus = false;
      });
    }
  }

  Future<void> _carregarLocalizacao() async {
    setState(() {
      carregandoMapa = true;
    });
    try {
      final solicitacao = widget.solicitacao;
      // 1. Tentar pegar coordenadas salvas
      final enderecoCoordenadas = solicitacao['endereco_coordenadas']
          ?.toString();
      if (enderecoCoordenadas != null && enderecoCoordenadas.contains(',')) {
        final partes = enderecoCoordenadas.split(',');
        if (partes.length == 2) {
          final lat = double.tryParse(partes[0]);
          final lng = double.tryParse(partes[1]);
          if (lat != null && lng != null) {
            setState(() {
              localizacao = latlong2.LatLng(lat, lng);
              carregandoMapa = false;
            });
            return;
          }
        }
      }
      // 2. Fallback: geocoding do endereço
      final endereco = solicitacao['endereco']?.toString();
      if (endereco != null && endereco.isNotEmpty) {
        List<Location> locations = await locationFromAddress(endereco);
        if (locations.isNotEmpty) {
          setState(() {
            localizacao = latlong2.LatLng(
              locations[0].latitude,
              locations[0].longitude,
            );
            carregandoMapa = false;
          });
          return;
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao buscar localização: $e');
    }
    setState(() {
      carregandoMapa = false;
    });
  }

  Widget _buildStatusDropdown() {
    final statusList = [
      'pendente',
      'agendada',
      'coletando',
      'concluido',
      'cancelado',
    ];
    return DropdownButton<String>(
      value: statusSelecionado,
      items: statusList.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status[0].toUpperCase() + status.substring(1)),
        );
      }).toList(),
      onChanged: atualizandoStatus
          ? null
          : (novoStatus) {
              if (novoStatus != null && novoStatus != statusSelecionado) {
                _atualizarStatus(novoStatus);
              }
            },
    );
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
          maxWidth: width < 600 ? width * 0.98 : 900,
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
                  // HEADER MODERNO
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: Container()),
                            Text(
                              'Detalhes da Solicitação',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  tooltip: 'Fechar',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [_statusVisual(theme, solicitacao)],
                        ),
                      ],
                    ),
                  ),
                  // CONTEÚDO PRINCIPAL
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // GALERIA DE FOTOS
                          if (fotos.isNotEmpty) ...[
                            _sectionTitle(
                              'Fotos da Solicitação',
                              theme,
                              icon: Icons.photo_library_rounded,
                            ),
                            _modernPhotoGallery(fotos, theme),
                            const SizedBox(height: 16),
                          ],
                          // INFORMAÇÕES AGRUPADAS
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // BLOCO MODERNO DE INFORMAÇÕES DA SOLICITAÇÃO
                                Expanded(
                                  child: _modernSolicitacaoInfoBlock(
                                    theme,
                                    solicitacao,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // MAPA
                          _buildMapaEndereco(theme),
                        ],
                      ),
                    ),
                  ),
                  // RODAPÉ MODERNO
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: theme.dialogBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(AppRadius.card),
                        bottomRight: Radius.circular(AppRadius.card),
                      ),
                      border: Border(
                        top: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                    child: Row(
                      children: [
                        // TAG DO MORADOR
                        _moradorChip(morador, theme),
                        Expanded(child: Container()),
                        _modernStatusDropdownButton(theme),
                        if (atualizandoStatus) ...[
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // NOVOS WIDGETS MODERNOS
  Widget _statusVisual(ThemeData theme, Map solicitacao) {
    final status = solicitacao['status']?.toString().toLowerCase() ?? '';
    Color color;
    String label;
    IconData icon;
    switch (status) {
      case 'pendente':
        color = theme.colorScheme.secondary;
        label = 'Pendente';
        icon = Icons.schedule_rounded;
        break;
      case 'agendada':
        color = theme.colorScheme.primary;
        label = 'Agendada';
        icon = Icons.event_available;
        break;
      case 'coletando':
        color = theme.colorScheme.primary;
        label = 'Coletando';
        icon = Icons.local_shipping_rounded;
        break;
      case 'concluido':
        color = theme.colorScheme.tertiary ?? Colors.green;
        label = 'Concluído';
        icon = Icons.check_circle_rounded;
        break;
      case 'cancelado':
        color = Colors.red;
        label = 'Cancelado';
        icon = Icons.cancel;
        break;
      default:
        color = theme.primaryColor;
        label = status.isNotEmpty ? status : 'Indefinido';
        icon = Icons.help_outline_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String label, ThemeData theme, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: theme.primaryColor, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernPhotoGallery(List<String> fotos, ThemeData theme) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: fotos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showImageGallery(context, fotos, index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                fotos[index],
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _modernInfoCard(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.primaryColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _modernStatusDropdown(ThemeData theme) {
    final statusList = [
      'pendente',
      'agendada',
      'coletando',
      'concluido',
      'cancelado',
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withOpacity(0.18)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: statusSelecionado,
          icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
          items: statusList.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(
                status[0].toUpperCase() + status.substring(1),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            );
          }).toList(),
          onChanged: atualizandoStatus
              ? null
              : (novoStatus) {
                  if (novoStatus != null && novoStatus != statusSelecionado) {
                    _atualizarStatus(novoStatus);
                  }
                },
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

  Widget _infoRowCompact(String label, dynamic value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.disabledColor,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
        return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
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

  Widget _cameraSeparator(ThemeData theme) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1, indent: 0, endIndent: 8)),
        Container(
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.camera_alt_rounded,
            color: theme.primaryColor,
            size: 20,
          ),
        ),
        const Expanded(child: Divider(thickness: 1, indent: 8, endIndent: 0)),
      ],
    );
  }

  Widget _sectionSeparatorLabel(String label, ThemeData theme) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1, indent: 0, endIndent: 8)),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
        const Expanded(child: Divider(thickness: 1, indent: 8, endIndent: 0)),
      ],
    );
  }

  Widget _modernStatusDropdownButton(ThemeData theme) {
    final statusList = [
      'pendente',
      'agendada',
      'coletando',
      'concluido',
      'cancelado',
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: statusSelecionado,
          icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          dropdownColor: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          items: statusList.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Row(
                children: [
                  Icon(
                    _statusIcon(status),
                    color: theme.primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status[0].toUpperCase() + status.substring(1),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: atualizandoStatus
              ? null
              : (novoStatus) async {
                  if (novoStatus != null && novoStatus != statusSelecionado) {
                    if (novoStatus == 'agendada') {
                      // Abrir calendário para selecionar data
                      final dataSelecionada = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        helpText: 'Selecione a data da coleta',
                        cancelText: 'Cancelar',
                        confirmText: 'Confirmar',
                        locale: const Locale('pt', 'BR'),
                      );
                      if (dataSelecionada != null) {
                        await _atualizarStatus(
                          novoStatus,
                          dataAgendada: dataSelecionada,
                        );
                      }
                    } else {
                      await _atualizarStatus(novoStatus);
                    }
                  }
                },
        ),
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pendente':
        return Icons.schedule_rounded;
      case 'agendada':
        return Icons.event_available;
      case 'coletando':
        return Icons.local_shipping_rounded;
      case 'concluido':
        return Icons.check_circle_rounded;
      case 'cancelado':
        return Icons.cancel;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Widget _moradorChip(Map<String, dynamic>? morador, ThemeData theme) {
    if (morador == null) return const SizedBox.shrink();
    final nome = (morador['nome'] ?? '').toString().trim();
    final nomes = nome.split(' ');
    final primeiroNome = nomes.isNotEmpty ? nomes[0] : '';
    final segundoNome = nomes.length > 1 ? nomes[1] : '';
    final whatsapp = (morador['whatsapp'] ?? '').toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.primaryColor.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person, color: theme.primaryColor, size: 18),
          const SizedBox(width: 6),
          Text(
            '$primeiroNome $segundoNome',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          if (whatsapp.isNotEmpty) ...[
            const SizedBox(width: 10),
            Icon(Icons.phone, color: Colors.green, size: 18),
            const SizedBox(width: 4),
            Text(
              whatsapp,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _modernSolicitacaoInfoBlock(ThemeData theme, Map solicitacao) {
    // Descrição, Tipo de Entulho e Data de Criação na mesma linha
    return Container(
      margin: const EdgeInsets.only(top: 0, bottom: 0),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(
          theme.brightness == Brightness.dark ? 0.04 : 0.07,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.description_rounded,
                  color: theme.primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Descrição',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.disabledColor,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (solicitacao['descricao'] ?? '-').toString(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                // Tipo de Entulho
                Icon(
                  Icons.category_rounded,
                  color: theme.primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo de Entulho',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.disabledColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (solicitacao['tipo_entulho'] ?? '-').toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                // Data de Criação
                Icon(
                  Icons.calendar_today_rounded,
                  color: theme.primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data de Criação',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.disabledColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(solicitacao['criado_em']),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if ((solicitacao['status']?.toString() ?? '').toLowerCase() ==
                  'agendada' &&
              solicitacao['data_coleta'] != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.event_available,
                    color: theme.primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Coleta agendada para:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.disabledColor,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(solicitacao['data_coleta']),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: theme.dividerColor, thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: theme.primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 110,
                  child: Text(
                    'Endereço',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.disabledColor,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              (solicitacao['endereco'] ?? '-').toString(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (solicitacao['numero_casa'] != null &&
                              (solicitacao['numero_casa'] as String)
                                  .isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Nº ${(solicitacao['numero_casa'] ?? '').toString()}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                          if (solicitacao['bairro'] != null &&
                              (solicitacao['bairro'] as String).isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              (solicitacao['bairro'] ?? '').toString(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (solicitacao['ponto_referencia'] != null &&
                          (solicitacao['ponto_referencia'] as String)
                              .isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          (solicitacao['ponto_referencia'] ?? '').toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            color: theme.textTheme.bodyLarge?.color
                                ?.withOpacity(0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapaEndereco(ThemeData theme) {
    final endereco = widget.solicitacao['endereco']?.toString() ?? '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
          child: Row(
            children: [
              Icon(Icons.map, color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Localização no Mapa',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => setState(() => _satellite = !_satellite),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      _satellite ? Icons.map : Icons.satellite_alt,
                      color: theme.primaryColor,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 220,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.primaryColor.withOpacity(0.18)),
            color: theme.cardColor,
          ),
          child: carregandoMapa
              ? const Center(child: CircularProgressIndicator())
              : localizacao == null
              ? Center(
                  child: Text(
                    'Não foi possível localizar o endereço no mapa.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      flutter_map.FlutterMap(
                        options: flutter_map.MapOptions(
                          initialCenter: localizacao!,
                          initialZoom: 16,
                          minZoom: 3,
                          maxZoom: 19,
                          interactionOptions: flutter_map.InteractionOptions(
                            flags: flutter_map.InteractiveFlag.all,
                          ),
                        ),
                        children: [
                          flutter_map.TileLayer(
                            urlTemplate: _satellite
                                ? "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
                                : "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            tileProvider: CancellableNetworkTileProvider(),
                            userAgentPackageName: 'com.rucopi.dashboard',
                          ),
                          flutter_map.MarkerLayer(
                            markers: [
                              flutter_map.Marker(
                                point: localizacao!,
                                width: 48,
                                height: 48,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.primaryColor.withOpacity(
                                          0.25,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.location_on,
                                    color: _satellite
                                        ? Colors.redAccent
                                        : theme.primaryColor,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              if (localizacao != null) {
                                showMapaDialog(
                                  context,
                                  localizacao!,
                                  _satellite,
                                  theme,
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.13),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(Icons.fullscreen, size: 22),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

void showMapaDialog(
  BuildContext context,
  latlong2.LatLng localizacao,
  bool satellite,
  ThemeData theme,
) {
  showDialog(
    context: context,
    builder: (context) {
      double zoom = 16;
      return StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: flutter_map.FlutterMap(
                    options: flutter_map.MapOptions(
                      initialCenter: localizacao,
                      initialZoom: zoom,
                      minZoom: 3,
                      maxZoom: 19,
                      interactionOptions: flutter_map.InteractionOptions(
                        flags: flutter_map.InteractiveFlag.all,
                      ),
                      onPositionChanged: (pos, hasGesture) {
                        setState(() => zoom = pos.zoom ?? zoom);
                      },
                    ),
                    children: [
                      flutter_map.TileLayer(
                        urlTemplate: satellite
                            ? "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
                            : "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        tileProvider: CancellableNetworkTileProvider(),
                        userAgentPackageName: 'com.rucopi.dashboard',
                      ),
                      flutter_map.MarkerLayer(
                        markers: [
                          flutter_map.Marker(
                            point: localizacao,
                            width: 56,
                            height: 56,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primaryColor.withOpacity(0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: satellite
                                    ? Colors.redAccent
                                    : theme.primaryColor,
                                size: 48,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      FloatingActionButton(
                        mini: true,
                        heroTag: 'zoom_in',
                        backgroundColor: theme.primaryColor,
                        foregroundColor: theme.colorScheme.onPrimary,
                        onPressed: () =>
                            setState(() => zoom = (zoom + 1).clamp(3, 19)),
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        mini: true,
                        heroTag: 'zoom_out',
                        backgroundColor: theme.primaryColor,
                        foregroundColor: theme.colorScheme.onPrimary,
                        onPressed: () =>
                            setState(() => zoom = (zoom - 1).clamp(3, 19)),
                        child: const Icon(Icons.remove),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        mini: true,
                        heroTag: 'close_map',
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: Colors.white,
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
