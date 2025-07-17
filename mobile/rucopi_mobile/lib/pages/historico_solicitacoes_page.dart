import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detalhes_solicitacao_page.dart';

class HistoricoSolicitacoesPage extends StatefulWidget {
  const HistoricoSolicitacoesPage({Key? key}) : super(key: key);

  @override
  State<HistoricoSolicitacoesPage> createState() =>
      _HistoricoSolicitacoesPageState();
}

class _HistoricoSolicitacoesPageState extends State<HistoricoSolicitacoesPage> {
  bool loading = true;
  List<dynamic> solicitacoes = [];

  @override
  void initState() {
    super.initState();
    _carregarSolicitacoes();
  }

  Future<void> _carregarSolicitacoes() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        loading = false;
      });
      return;
    }
    final resp = await Supabase.instance.client
        .from('solicitacoes')
        .select('descricao, status, criado_em, tipo_entulho, endereco, fotos')
        .eq('morador_id', user.id)
        .order('criado_em', ascending: false);
    setState(() {
      solicitacoes = resp;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Solicitações')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : solicitacoes.isEmpty
          ? const Center(child: Text('Nenhuma solicitação encontrada.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: solicitacoes.length,
              itemBuilder: (context, i) {
                final s = solicitacoes[i];
                final data =
                    DateTime.tryParse(s['criado_em'] ?? '') ?? DateTime.now();
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(s['descricao'] ?? 'Sem descrição'),
                    subtitle: Text(
                      'Status: ${s['status']}\nData: ${data.day}/${data.month}/${data.year}',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetalhesSolicitacaoPage(solicitacao: s),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
