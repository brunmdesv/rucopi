import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../widgets/app_padrao.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'nova_solicitacao_page.dart';

class EditarSolicitacaoPage extends StatefulWidget {
  final Map<String, dynamic> solicitacao;
  const EditarSolicitacaoPage({Key? key, required this.solicitacao})
    : super(key: key);

  @override
  State<EditarSolicitacaoPage> createState() => _EditarSolicitacaoPageState();
}

class _EditarSolicitacaoPageState extends State<EditarSolicitacaoPage> {
  late TextEditingController descricaoController;
  late TextEditingController enderecoController;
  late TextEditingController bairroController;
  late TextEditingController numeroCasaController;
  late TextEditingController pontoReferenciaController;
  String? tipoEntulho;
  final tiposEntulho = ['Entulho de obra', 'Móveis', 'Galhos', 'Outros'];
  final List<XFile> imagensSelecionadas = [];
  List<String> imagensAntigas = [];
  bool carregando = false;
  String enderecoModo = 'manual'; // 'manual', 'mapa', 'atual'
  LatLng enderecoMapa = const LatLng(-2.955939, -41.780729);
  bool buscandoEndereco = false;
  String? enderecoRua;
  List<String> imagensOriginais = [];
  bool get isPendente =>
      (widget.solicitacao['status'] ?? 'pendente') == 'pendente';

  @override
  void initState() {
    super.initState();
    descricaoController = TextEditingController(
      text: widget.solicitacao['descricao'] ?? '',
    );
    enderecoController = TextEditingController(
      text: widget.solicitacao['endereco'] ?? '',
    );
    bairroController = TextEditingController(
      text: widget.solicitacao['bairro'] ?? '',
    );
    numeroCasaController = TextEditingController(
      text: widget.solicitacao['numero_casa'] ?? '',
    );
    pontoReferenciaController = TextEditingController(
      text: widget.solicitacao['ponto_referencia'] ?? '',
    );
    tipoEntulho = widget.solicitacao['tipo_entulho'];
    if (widget.solicitacao['fotos'] is List) {
      imagensAntigas = List<String>.from(widget.solicitacao['fotos']);
    }
    imagensOriginais = widget.solicitacao['fotos'] is List
        ? List<String>.from(widget.solicitacao['fotos'])
        : [];
  }

  @override
  void dispose() {
    descricaoController.dispose();
    enderecoController.dispose();
    bairroController.dispose();
    numeroCasaController.dispose();
    pontoReferenciaController.dispose();
    super.dispose();
  }

  Future<void> selecionarImagens() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? novasImagens = await picker.pickMultiImage();
    if (novasImagens != null) {
      setState(() {
        imagensSelecionadas.clear();
        imagensSelecionadas.addAll(novasImagens.take(3));
        imagensAntigas.clear(); // Se selecionar novas, remove as antigas
      });
    }
  }

  Future<List<String>> uploadImagens(String userId) async {
    final storage = Supabase.instance.client.storage.from('fotosrucopi');
    List<String> urls = [];
    for (var i = 0; i < imagensSelecionadas.length; i++) {
      final file = File(imagensSelecionadas[i].path);
      final fileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final res = await storage.upload('solicitacoes/$fileName', file);
      if (res != null && res.isNotEmpty) {
        final url = storage.getPublicUrl('solicitacoes/$fileName');
        urls.add(url);
      }
    }
    return urls;
  }

  Future<void> obterLocalizacaoAtual() async {
    setState(() => buscandoEndereco = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de localização negada')),
        );
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      enderecoMapa = LatLng(pos.latitude, pos.longitude);
      List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          enderecoController.text = p.street ?? '';
          bairroController.text =
              (p.subLocality != null && p.subLocality!.isNotEmpty)
              ? p.subLocality!
              : (p.subAdministrativeArea ?? '');
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao obter localização: $e')));
    } finally {
      if (mounted) {
        setState(() => buscandoEndereco = false);
      }
    }
  }

  Future<void> selecionarNoMapa() async {
    final LatLng? resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SelecionarNoMapaPage(posicaoInicial: enderecoMapa),
      ),
    );
    if (resultado != null) {
      enderecoMapa = resultado;
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          resultado.latitude,
          resultado.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          setState(() {
            enderecoController.text = p.street ?? '';
            bairroController.text =
                (p.subLocality != null && p.subLocality!.isNotEmpty)
                ? p.subLocality!
                : (p.subAdministrativeArea ?? '');
          });
        }
      } catch (_) {
        setState(() {
          enderecoController.text = '';
          bairroController.text = '';
        });
      }
    }
  }

  // Função utilitária para extrair o caminho completo do storage a partir da URL pública
  String? getStoragePathFromUrl(String url) {
    final uri = Uri.parse(url);
    final idx = uri.path.indexOf('/fotosrucopi/');
    if (idx != -1) {
      return uri.path.substring(idx + '/fotosrucopi/'.length);
    }
    return null;
  }

  Future<void> salvarAlteracoes() async {
    setState(() => carregando = true);
    final user = Supabase.instance.client.auth.currentUser;
    final solicitacaoId = widget.solicitacao['id'];
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para editar a solicitação!')),
      );
      setState(() => carregando = false);
      return;
    }
    if (solicitacaoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação sem ID. Não é possível editar.'),
        ),
      );
      setState(() => carregando = false);
      return;
    }
    try {
      // Remover imagens antigas que foram removidas pelo usuário
      final supabase = Supabase.instance.client;
      final imagensRemovidas = imagensOriginais
          .where((url) => !imagensAntigas.contains(url))
          .toList();
      for (final url in imagensRemovidas) {
        try {
          final storagePath = getStoragePathFromUrl(url);
          if (storagePath != null) {
            await supabase.storage.from('fotosrucopi').remove([storagePath]);
          }
        } catch (_) {}
      }
      List<String> fotosUrls = imagensAntigas;
      if (imagensSelecionadas.isNotEmpty) {
        fotosUrls = await uploadImagens(user.id);
      }
      await supabase
          .from('solicitacoes')
          .update({
            'descricao': descricaoController.text,
            'tipo_entulho': tipoEntulho,
            'endereco': enderecoController.text,
            'bairro': bairroController.text,
            'numero_casa': numeroCasaController.text,
            'ponto_referencia': pontoReferenciaController.text,
            'fotos': fotosUrls,
          })
          .eq('id', solicitacaoId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação atualizada com sucesso!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar solicitação: $e')),
      );
    } finally {
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPadrao(
      titulo: 'Editar Solicitação',
      leading: Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo de descrição
            TextField(
              controller: descricaoController,
              decoration: InputDecoration(
                labelText: 'Descrição do entulho',
                prefixIcon: const Icon(Icons.description_outlined),
                filled: true,
                fillColor: Theme.of(context).primaryColor.withOpacity(0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            // Campo de tipo de entulho
            DropdownButtonFormField<String>(
              value: tipoEntulho,
              items: tiposEntulho
                  .map(
                    (tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => tipoEntulho = val),
              decoration: InputDecoration(
                labelText: 'Tipo de entulho',
                prefixIcon: const Icon(Icons.category_outlined),
                filled: true,
                fillColor: Theme.of(context).primaryColor.withOpacity(0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Seletor de modo de endereço
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceChip(
                  label: Row(
                    children: const [
                      Icon(Icons.home),
                      SizedBox(width: 4),
                      Text('Manual'),
                    ],
                  ),
                  selected: enderecoModo == 'manual',
                  onSelected: isPendente
                      ? (_) => setState(() => enderecoModo = 'manual')
                      : null,
                ),
                ChoiceChip(
                  label: Row(
                    children: const [
                      Icon(Icons.map),
                      SizedBox(width: 4),
                      Text('Mapa'),
                    ],
                  ),
                  selected: enderecoModo == 'mapa',
                  onSelected: isPendente
                      ? (_) async {
                          setState(() => enderecoModo = 'mapa');
                          await Future.delayed(
                            const Duration(milliseconds: 200),
                          );
                          selecionarNoMapa();
                        }
                      : null,
                ),
                ChoiceChip(
                  label: Row(
                    children: const [
                      Icon(Icons.my_location),
                      SizedBox(width: 4),
                      Text('Atual'),
                    ],
                  ),
                  selected: enderecoModo == 'atual',
                  onSelected: isPendente
                      ? (_) {
                          setState(() => enderecoModo = 'atual');
                          obterLocalizacaoAtual();
                        }
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Campo de endereço sempre visível, mas editável só no modo manual
            TextField(
              controller: enderecoController,
              enabled: isPendente && enderecoModo == 'manual',
              decoration: InputDecoration(
                labelText: 'Endereço',
                prefixIcon: const Icon(Icons.location_on_outlined),
                filled: true,
                fillColor: Theme.of(context).primaryColor.withOpacity(0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (enderecoModo == 'atual' && buscandoEndereco)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: bairroController,
                    decoration: InputDecoration(
                      labelText: 'Bairro',
                      prefixIcon: const Icon(Icons.location_city_outlined),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: numeroCasaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Nº',
                      prefixIcon: const Icon(Icons.home_outlined),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pontoReferenciaController,
              decoration: InputDecoration(
                labelText: 'Ponto de referência',
                prefixIcon: const Icon(Icons.place_outlined),
                filled: true,
                fillColor: Theme.of(context).primaryColor.withOpacity(0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Card de fotos centralizado
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.photo_library_outlined),
                      const SizedBox(width: 10),
                      const Text('Fotos (máx. 3):'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...imagensAntigas.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final url = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  url,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      imagensAntigas.removeAt(idx);
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      ...imagensSelecionadas.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final img = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(img.path),
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      imagensSelecionadas.removeAt(idx);
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (imagensAntigas.length + imagensSelecionadas.length <
                          3)
                        IconButton(
                          icon: const Icon(Icons.add_a_photo),
                          onPressed: selecionarImagens,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 260,
                child: ElevatedButton.icon(
                  onPressed: isPendente && !carregando
                      ? salvarAlteracoes
                      : null,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar Alterações'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            if (carregando)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
