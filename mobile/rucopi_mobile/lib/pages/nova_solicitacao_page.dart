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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição do entulho',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: tipoEntulho,
              items: tiposEntulho
                  .map(
                    (tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => tipoEntulho = val),
              decoration: const InputDecoration(labelText: 'Tipo de entulho'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: enderecoController,
              decoration: const InputDecoration(labelText: 'Endereço'),
            ),
            const SizedBox(height: 12),
            Text('Fotos (máx. 3):'),
            const SizedBox(height: 8),
            Row(
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: carregando ? null : enviarSolicitacao,
              child: carregando
                  ? const CircularProgressIndicator()
                  : const Text('Enviar Solicitação'),
            ),
          ],
        ),
      ),
    );
  }
}
