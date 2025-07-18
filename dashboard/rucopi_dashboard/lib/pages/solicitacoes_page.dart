import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import '../theme/app_styles.dart';
import '../widgets/app_padrao.dart';

class SolicitacoesPage extends StatefulWidget {
  const SolicitacoesPage({super.key});

  @override
  State<SolicitacoesPage> createState() => _SolicitacoesPageState();
}

class _SolicitacoesPageState extends State<SolicitacoesPage> {
  List<dynamic> solicitacoes = [];
  List<dynamic> solicitacoesFiltradas = [];
  bool carregando = true;
  String? erro;
  String filtroStatus = 'todas';
  String termoPesquisa = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    buscarSolicitacoes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        solicitacoesFiltradas = response;
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

  void filtrarSolicitacoes() {
    setState(() {
      solicitacoesFiltradas = solicitacoes.where((s) {
        final matchStatus =
            filtroStatus == 'todas' || s['status'] == filtroStatus;
        final matchPesquisa =
            termoPesquisa.isEmpty ||
            s['descricao']?.toLowerCase().contains(
                  termoPesquisa.toLowerCase(),
                ) ==
                true ||
            s['endereco']?.toLowerCase().contains(
                  termoPesquisa.toLowerCase(),
                ) ==
                true ||
            s['morador_id']?.toLowerCase().contains(
                  termoPesquisa.toLowerCase(),
                ) ==
                true;
        return matchStatus && matchPesquisa;
      }).toList();
    });
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pendente':
        return const Color(0xFFFF9800);
      case 'em andamento':
        return const Color(0xFF2196F3);
      case 'concluida':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'pendente':
        return Icons.schedule;
      case 'em andamento':
        return Icons.local_shipping;
      case 'concluida':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pendente':
        return 'Aguardando Coleta';
      case 'em andamento':
        return 'Em Andamento';
      case 'concluida':
        return 'Concluída';
      default:
        return 'Indefinido';
    }
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? theme.primaryColor : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSolicitacaoCard(dynamic solicitacao) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(solicitacao['status']);
    final statusIcon = _getStatusIcon(solicitacao['status']);
    final statusText = _getStatusText(solicitacao['status']);
    final data = solicitacao['criado_em'] != null
        ? DateTime.tryParse(solicitacao['criado_em'])
        : null;
    final dataStr = data != null
        ? '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}'
        : 'Sem data';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF1A1A1A)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF2A2A2A)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  statusText,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                dataStr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.disabledColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.description, color: theme.primaryColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  solicitacao['descricao'] ?? 'Sem descrição',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  solicitacao['endereco'] ?? '-',
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.category, color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  solicitacao['tipo_entulho'] ?? '-',
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(ThemeData theme) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: Container(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF1A1A1A)
            : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        alignment: Alignment.centerLeft,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 72,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Text(
                    'Solicitações',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF606A45),
                    ),
                  ),
                ),
                const Spacer(),
                // Nenhum ícone à direita
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('solicitacoes')
          .stream(primaryKey: ['id'])
          .order('criado_em', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erro ao buscar solicitações: ${snapshot.error}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          );
        }
        final solicitacoes = snapshot.data ?? [];
        // Aplicar filtro e pesquisa
        final solicitacoesFiltradas = solicitacoes.where((s) {
          final matchStatus =
              filtroStatus == 'todas' || s['status'] == filtroStatus;
          final matchPesquisa =
              termoPesquisa.isEmpty ||
              (s['descricao']?.toLowerCase().contains(
                    termoPesquisa.toLowerCase(),
                  ) ??
                  false) ||
              (s['endereco']?.toLowerCase().contains(
                    termoPesquisa.toLowerCase(),
                  ) ??
                  false) ||
              (s['morador_id']?.toLowerCase().contains(
                    termoPesquisa.toLowerCase(),
                  ) ??
                  false);
          return matchStatus && matchPesquisa;
        }).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtros e pesquisa
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Pesquisar por descrição, endereço ou morador...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.brightness == Brightness.dark
                          ? const Color(0xFF1A1A1A)
                          : Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                      suffixIcon: termoPesquisa.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  termoPesquisa = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        termoPesquisa = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                _buildFilterChip(
                  label: 'Todas',
                  value: 'todas',
                  isSelected: filtroStatus == 'todas',
                  onTap: () {
                    setState(() {
                      filtroStatus = 'todas';
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Pendentes',
                  value: 'pendente',
                  isSelected: filtroStatus == 'pendente',
                  onTap: () {
                    setState(() {
                      filtroStatus = 'pendente';
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Em Andamento',
                  value: 'em andamento',
                  isSelected: filtroStatus == 'em andamento',
                  onTap: () {
                    setState(() {
                      filtroStatus = 'em andamento';
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Concluídas',
                  value: 'concluida',
                  isSelected: filtroStatus == 'concluida',
                  onTap: () {
                    setState(() {
                      filtroStatus = 'concluida';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: solicitacoesFiltradas.isEmpty
                  ? Center(
                      child: Text(
                        termoPesquisa.isNotEmpty || filtroStatus != 'todas'
                            ? 'Nenhuma solicitação encontrada com os filtros aplicados.'
                            : 'Nenhuma solicitação encontrada.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: solicitacoesFiltradas.length,
                      itemBuilder: (context, index) {
                        return _buildSolicitacaoCard(
                          solicitacoesFiltradas[index],
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
