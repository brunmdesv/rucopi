import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_styles.dart';

class DetalhesSolicitacaoMoradorPage extends StatefulWidget {
  final Map<String, dynamic> solicitacao;
  const DetalhesSolicitacaoMoradorPage({Key? key, required this.solicitacao})
    : super(key: key);

  @override
  State<DetalhesSolicitacaoMoradorPage> createState() =>
      _DetalhesSolicitacaoMoradorPageState();
}

class _DetalhesSolicitacaoMoradorPageState
    extends State<DetalhesSolicitacaoMoradorPage> {
  Map<String, dynamic>? morador;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _carregarMorador();
  }

  Future<void> _carregarMorador() async {
    final moradorId = widget.solicitacao['morador_id'];
    print('DEBUG moradorId: ' + moradorId.toString());
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
      print('DEBUG morador encontrado: ' + resp.toString());
      setState(() {
        morador = resp;
        loading = false;
      });
    } catch (e) {
      print('DEBUG erro ao buscar morador: ' + e.toString());
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Solicitação'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : morador == null
          ? Center(
              child: Text(
                'Morador não encontrado.',
                style: theme.textTheme.titleLarge,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card do Morador
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.card),
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
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Informações do Morador',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _infoRow('Nome', morador?['nome']),
                          _infoRow('E-mail', morador?['email']),
                          _infoRow('Whatsapp', morador?['whatsapp']),
                          _infoRow('CPF', morador?['cpf']),
                          _infoRow('Endereço', morador?['endereco']),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Card da Solicitação
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.card),
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
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Informações da Solicitação',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _infoRow('Descrição', solicitacao['descricao']),
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
                              style: theme.textTheme.titleMedium?.copyWith(
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
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      fotos[index],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
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
    );
  }

  Widget _infoRow(String label, dynamic value) {
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
}
