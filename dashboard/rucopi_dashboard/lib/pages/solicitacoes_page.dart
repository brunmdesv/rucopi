import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class SolicitacoesPage extends StatefulWidget {
  const SolicitacoesPage({super.key});

  @override
  State<SolicitacoesPage> createState() => _SolicitacoesPageState();
}

class _SolicitacoesPageState extends State<SolicitacoesPage> with TickerProviderStateMixin {
  List<dynamic> solicitacoes = [];
  List<dynamic> solicitacoesFiltradas = [];
  bool carregando = true;
  String? erro;
  String filtroStatus = 'todas';
  String termoPesquisa = '';
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    buscarSolicitacoes();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
      
      _animationController.forward();
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
        final matchStatus = filtroStatus == 'todas' || s['status'] == filtroStatus;
        final matchPesquisa = termoPesquisa.isEmpty ||
            s['descricao']?.toLowerCase().contains(termoPesquisa.toLowerCase()) == true ||
            s['endereco']?.toLowerCase().contains(termoPesquisa.toLowerCase()) == true ||
            s['morador_id']?.toLowerCase().contains(termoPesquisa.toLowerCase()) == true;
        return matchStatus && matchPesquisa;
      }).toList();
    });
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

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pendente':
        return const Color(0xFFf093fb);
      case 'em andamento':
        return const Color(0xFF4facfe);
      case 'concluida':
        return const Color(0xFF43e97b);
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSolicitacaoCard(dynamic solicitacao, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animation)),
          child: Opacity(
            opacity: animation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header do card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getStatusColor(solicitacao['status']),
                          _getStatusColor(solicitacao['status']).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getStatusIcon(solicitacao['status']),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getStatusText(solicitacao['status']),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                solicitacao['criado_em']?.toString().substring(0, 19) ?? '-',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Conteúdo do card
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Descrição
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.description,
                                color: Colors.blue.shade600,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Descrição',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    solicitacao['descricao'] ?? 'Sem descrição',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Informações em grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                icon: Icons.person,
                                label: 'Morador',
                                value: solicitacao['morador_id'] ?? '-',
                                color: Colors.purple,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoItem(
                                icon: Icons.category,
                                label: 'Tipo',
                                value: solicitacao['tipo_entulho'] ?? '-',
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Endereço
                        _buildInfoItem(
                          icon: Icons.location_on,
                          label: 'Endereço',
                          value: solicitacao['endereco'] ?? '-',
                          color: Colors.red,
                          isFullWidth: true,
                        ),
                        
                        // Fotos
                        if (solicitacao['fotos'] != null &&
                            solicitacao['fotos'] is List &&
                            solicitacao['fotos'].isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.photo_library,
                                  color: Colors.green.shade600,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Fotos (${(solicitacao['fotos'] as List).length})',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: (solicitacao['fotos'] as List).length,
                              itemBuilder: (context, photoIndex) {
                                final url = solicitacao['fotos'][photoIndex];
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      url,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.error,
                                            color: Colors.grey.shade400,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.list_alt,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solicitações de Coleta',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Gestão de Entulho',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.grey),
                    tooltip: 'Atualizar dados',
                    onPressed: () {
                      _animationController.reset();
                      buscarSolicitacoes();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.logout, color: Colors.red.shade600),
                    tooltip: 'Sair',
                    onPressed: logout,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: carregando
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Carregando solicitações...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : erro != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.red.shade400,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        erro!,
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: buscarSolicitacoes,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header com filtros e pesquisa
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Barra de pesquisa
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Pesquisar por descrição, endereço ou morador...',
                                prefixIcon: const Icon(Icons.search),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                                suffixIcon: termoPesquisa.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            termoPesquisa = '';
                                          });
                                          filtrarSolicitacoes();
                                        },
                                      )
                                    : null,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  termoPesquisa = value;
                                });
                                filtrarSolicitacoes();
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Filtros por status
                          Row(
                            children: [
                              const Text(
                                'Filtrar por:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildFilterChip(
                                        label: 'Todas',
                                        value: 'todas',
                                        isSelected: filtroStatus == 'todas',
                                        onTap: () {
                                          setState(() {
                                            filtroStatus = 'todas';
                                          });
                                          filtrarSolicitacoes();
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
                                          filtrarSolicitacoes();
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
                                          filtrarSolicitacoes();
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
                                          filtrarSolicitacoes();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Contador de resultados
                          Row(
                            children: [
                              Text(
                                '${solicitacoesFiltradas.length} solicitação${solicitacoesFiltradas.length != 1 ? 'ões' : ''} encontrada${solicitacoesFiltradas.length != 1 ? 's' : ''}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              if (solicitacoesFiltradas.length != solicitacoes.length)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      filtroStatus = 'todas';
                                      termoPesquisa = '';
                                      _searchController.clear();
                                    });
                                    filtrarSolicitacoes();
                                  },
                                  child: const Text('Limpar filtros'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Lista de solicitações
                    Expanded(
                      child: solicitacoesFiltradas.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.inbox_outlined,
                                      color: Colors.grey.shade400,
                                      size: 48,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    termoPesquisa.isNotEmpty || filtroStatus != 'todas'
                                        ? 'Nenhuma solicitação encontrada\ncom os filtros aplicados'
                                        : 'Nenhuma solicitação encontrada',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: buscarSolicitacoes,
                              child: ListView.builder(
                                padding: const EdgeInsets.only(top: 16, bottom: 24),
                                itemCount: solicitacoesFiltradas.length,
                                itemBuilder: (context, index) {
                                  return _buildSolicitacaoCard(solicitacoesFiltradas[index], index);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
}