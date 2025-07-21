import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../widgets/app_padrao.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class NovaSolicitacaoPage extends StatefulWidget {
  const NovaSolicitacaoPage({super.key});

  @override
  State<NovaSolicitacaoPage> createState() => _NovaSolicitacaoPageState();
}

class _NovaSolicitacaoPageState extends State<NovaSolicitacaoPage> {
  final descricaoController = TextEditingController();
  final enderecoController = TextEditingController();
  String? tipoEntulho;
  final tiposEntulho = ['Entulho de obra', 'Móveis', 'Galhos', 'Outros'];
  final List<XFile> imagensSelecionadas = [];
  bool carregando = false;
  String enderecoModo = 'manual'; // 'manual', 'mapa', 'atual'
  LatLng enderecoMapa = const LatLng(-23.5505, -46.6333); // SP centro
  bool buscandoEndereco = false;
  String? enderecoRua;

  Future<void> selecionarImagens() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? novasImagens = await picker.pickMultiImage();
    if (novasImagens != null && novasImagens.isNotEmpty) {
      setState(() {
        imagensSelecionadas.clear();
        imagensSelecionadas.addAll(novasImagens.take(3));
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
      setState(() {
        enderecoMapa = LatLng(pos.latitude, pos.longitude);
        enderecoController.text = '${pos.latitude}, ${pos.longitude}';
      });
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
    // Buscar localização atual antes de abrir o mapa
    if (enderecoModo == 'mapa') {
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          final pos = await Geolocator.getCurrentPosition();
          enderecoMapa = LatLng(pos.latitude, pos.longitude);
        }
      } catch (_) {}
    }
    final LatLng? resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SelecionarNoMapaPage(posicaoInicial: enderecoMapa),
      ),
    );
    if (resultado != null) {
      setState(() {
        enderecoMapa = resultado;
        enderecoController.text =
            '${resultado.latitude}, ${resultado.longitude}';
      });
      // Buscar nome da rua
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          resultado.latitude,
          resultado.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          setState(() {
            enderecoRua = '${p.street}, ${p.subLocality}, ${p.locality}';
          });
        }
      } catch (_) {}
    }
  }

  Future<void> enviarSolicitacao() async {
    setState(() => carregando = true);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faça login para enviar uma solicitação!'),
        ),
      );
      setState(() => carregando = false);
      return;
    }
    try {
      // Buscar dados do morador
      final moradorResponse = await Supabase.instance.client
          .from('moradores')
          .select('nome')
          .eq('id', user.id)
          .single();

      final nomeMorador = moradorResponse['nome'] ?? 'Morador não identificado';

      List<String> fotosUrls = [];
      if (imagensSelecionadas.isNotEmpty) {
        fotosUrls = await uploadImagens(user.id);
      }
      await Supabase.instance.client.from('solicitacoes').insert({
        'morador_id': user.id,
        'nome_morador': nomeMorador,
        'descricao': descricaoController.text,
        'tipo_entulho': tipoEntulho,
        'endereco': enderecoController.text,
        'fotos': fotosUrls,
        'status': 'pendente',
        'criado_em': DateTime.now().toIso8601String(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação enviada com sucesso!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao enviar solicitação: $e')));
    } finally {
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPadrao(
      titulo: 'Nova Solicitação',
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
                fillColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.08),
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
                fillColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.08),
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
                  onSelected: (_) => setState(() => enderecoModo = 'manual'),
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
                  onSelected: (_) => setState(() => enderecoModo = 'mapa'),
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
                  onSelected: (_) {
                    setState(() => enderecoModo = 'atual');
                    obterLocalizacaoAtual();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (enderecoModo == 'manual')
              TextField(
                controller: enderecoController,
                decoration: InputDecoration(
                  labelText: 'Endereço',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            if (enderecoModo == 'mapa')
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('Escolher no mapa'),
                onPressed: selecionarNoMapa,
              ),
            if (enderecoModo == 'atual' && buscandoEndereco)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (enderecoModo != 'manual' && enderecoController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: [
                    Text(
                      'Endereço selecionado: ${enderecoController.text}',
                      textAlign: TextAlign.center,
                    ),
                    if (enderecoRua != null)
                      Text(
                        'Rua: $enderecoRua',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            // Card de fotos centralizado
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
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
                      ...imagensSelecionadas.map(
                        (img) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Image.file(
                            File(img.path),
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (imagensSelecionadas.length < 3)
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
                  onPressed: carregando ? null : enviarSolicitacao,
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar Solicitação'),
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

// Widget de seleção no mapa
class SelecionarNoMapaPage extends StatefulWidget {
  final LatLng? posicaoInicial;
  const SelecionarNoMapaPage({super.key, this.posicaoInicial});

  @override
  State<SelecionarNoMapaPage> createState() => _SelecionarNoMapaPageState();
}

class _SelecionarNoMapaPageState extends State<SelecionarNoMapaPage> {
  LatLng? _pino;
  late CameraPosition _cameraPosition;

  @override
  void initState() {
    super.initState();
    _pino =
        widget.posicaoInicial ?? const LatLng(-23.5505, -46.6333); // SP centro
    _cameraPosition = CameraPosition(target: _pino!, zoom: 16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escolher no mapa')),
      body: GoogleMap(
        initialCameraPosition: _cameraPosition,
        onTap: (pos) => setState(() => _pino = pos),
        markers: _pino != null
            ? {Marker(markerId: const MarkerId('pino'), position: _pino!)}
            : {},
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pino != null ? () => Navigator.pop(context, _pino) : null,
        label: const Text('Confirmar'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
