import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../widgets/app_padrao.dart';

class NovaSolicitacaoPage extends StatefulWidget {
  const NovaSolicitacaoPage({Key? key}) : super(key: key);

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

  Future<void> selecionarImagens() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? novasImagens = await picker.pickMultiImage();
    if (novasImagens != null) {
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

  Future<void> enviarSolicitacao() async {
    setState(() => carregando = true);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faça login para enviar uma solicitação!'),
        ),
      );
      setState(() => carregando = false);
      return;
    }
    try {
      List<String> fotosUrls = [];
      if (imagensSelecionadas.isNotEmpty) {
        fotosUrls = await uploadImagens(user.id);
      }
      await Supabase.instance.client.from('solicitacoes').insert({
        'morador_id': user.id,
        'descricao': descricaoController.text,
        'tipo_entulho': tipoEntulho,
        'endereco': enderecoController.text,
        'fotos': fotosUrls,
        'status': 'pendente',
        'criado_em': DateTime.now().toIso8601String(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação enviada com sucesso!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao enviar solicitação: $e')));
    } finally {
      setState(() => carregando = false);
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
            // Campo de endereço
            TextField(
              controller: enderecoController,
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
