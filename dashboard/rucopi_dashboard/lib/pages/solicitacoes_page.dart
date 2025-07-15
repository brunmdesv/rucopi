import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class SolicitacoesPage extends StatefulWidget {
  const SolicitacoesPage({super.key});

  @override
  State<SolicitacoesPage> createState() => _SolicitacoesPageState();
}

class _SolicitacoesPageState extends State<SolicitacoesPage> {
  List<dynamic> solicitacoes = [];
  bool carregando = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    buscarSolicitacoes();
  }

  Future<void> buscarSolicitacoes() async {
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      final response = await Supabase.instance.client
          .from('solicitacoes')
          .select()
          .order('criado_em', ascending: false);
      setState(() {
        solicitacoes = response;
      });
    } catch (e) {
      setState(() {
        erro = 'Erro ao buscar solicitações: $e';
      });
    } finally {
      setState(() {
        carregando = false;
      });
    }
  }

  void logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitações de Coleta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: logout,
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : erro != null
          ? Center(child: Text(erro!))
          : solicitacoes.isEmpty
          ? const Center(child: Text('Nenhuma solicitação encontrada.'))
          : RefreshIndicator(
              onRefresh: buscarSolicitacoes,
              child: ListView.builder(
                itemCount: solicitacoes.length,
                itemBuilder: (context, index) {
                  final s = solicitacoes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(s['descricao'] ?? 'Sem descrição'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${s['status'] ?? '-'}'),
                          Text(
                            'Data: ${s['criado_em']?.toString().substring(0, 19) ?? '-'}',
                          ),
                          Text('Morador: ${s['morador_id'] ?? '-'}'),
                          Text('Endereço: ${s['endereco'] ?? '-'}'),
                          Text('Tipo: ${s['tipo_entulho'] ?? '-'}'),
                          if (s['fotos'] != null &&
                              s['fotos'] is List &&
                              s['fotos'].isNotEmpty)
                            SizedBox(
                              height: 80,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: List<Widget>.from(
                                  (s['fotos'] as List).map(
                                    (url) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Image.network(
                                        url,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
