import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'nova_solicitacao_page.dart';
import 'historico_solicitacoes_page.dart';
import 'meu_perfil_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String nomeUsuario = '';
  int solicitacoesPendentes = 0;
  int solicitacoesTotais = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        nomeUsuario = 'Usuário';
        loading = false;
      });
      return;
    }
    final moradorId = user.id;
    // Buscar nome do morador
    final moradorResp = await Supabase.instance.client
        .from('moradores')
        .select('nome')
        .eq('id', moradorId)
        .single();
    final nome = moradorResp != null && moradorResp['nome'] != null
        ? moradorResp['nome'] as String
        : 'Usuário';
    // Buscar solicitações
    final solicitacoesResp = await Supabase.instance.client
        .from('solicitacoes')
        .select('status')
        .eq('morador_id', moradorId);
    final total = solicitacoesResp.length;
    final pendentes = solicitacoesResp
        .where((s) => s['status'] == 'pendente')
        .length;
    setState(() {
      nomeUsuario = nome;
      solicitacoesTotais = total;
      solicitacoesPendentes = pendentes;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rucopi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MeuPerfilPage()),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, $nomeUsuario',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Solicitações',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HistoricoSolicitacoesPage(),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: const [
                                    Text(
                                      'Histórico',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(Icons.archive_outlined),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pendentes: $solicitacoesPendentes',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Total: $solicitacoesTotais',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const NovaSolicitacaoPage(),
                                  ),
                                );
                              },
                              child: const Text('Solicitar coleta'),
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
}
