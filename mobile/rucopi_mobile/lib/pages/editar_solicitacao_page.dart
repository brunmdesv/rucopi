import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../widgets/app_padrao.dart';

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
  String? tipoEntulho;
  final tiposEntulho = ['Entulho de obra', 'Móveis', 'Galhos', 'Outros'];
  final List<XFile> imagensSelecionadas = [];
  List<String> imagensAntigas = [];
  bool carregando = false;

  @override
  void initState() {
    super.initState();
    descricaoController = TextEditingController(
      text: widget.solicitacao['descricao'] ?? '',
    );
    enderecoController = TextEditingController(
      text: widget.solicitacao['endereco'] ?? '',
    );
    tipoEntulho = widget.solicitacao['tipo_entulho'];
    if (widget.solicitacao['fotos'] is List) {
      imagensAntigas = List<String>.from(widget.solicitacao['fotos']);
    }
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
      List<String> fotosUrls = imagensAntigas;
      if (imagensSelecionadas.isNotEmpty) {
        fotosUrls = await uploadImagens(user.id);
      }
      await Supabase.instance.client
          .from('solicitacoes')
          .update({
            'descricao': descricaoController.text,
            'tipo_entulho': tipoEntulho,
            'endereco': enderecoController.text,
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
                      ...imagensAntigas.map(
                        (url) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Image.network(
                            url,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
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
                  onPressed: carregando ? null : salvarAlteracoes,
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
