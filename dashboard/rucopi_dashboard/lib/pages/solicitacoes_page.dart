import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import '../theme/app_styles.dart';
import '../widgets/app_padrao.dart';
import 'detalhes_solicitacao_dialog.dart';

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
      case 'agendada':
        return const Color(0xFF2196F3);
      case 'coletando':
        return const Color(0xFF673AB7);
      case 'concluido':
        return const Color(0xFF4CAF50);
      case 'cancelado':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'pendente':
        return Icons.schedule;
      case 'agendada':
        return Icons.event_available;
      case 'coletando':
        return Icons.local_shipping;
      case 'concluido':
        return Icons.check_circle;
      case 'cancelado':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pendente':
        return 'Pendente';
      case 'agendada':
        return 'Agendada';
      case 'coletando':
        return 'Coletando';
      case 'concluido':
        return 'Concluído';
      case 'cancelado':
        return 'Cancelado';
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
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor
              : theme.brightness == Brightness.dark
              ? const Color(0xFF2A2A2A)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : theme.brightness == Brightness.dark
                ? const Color(0xFF3A3A3A)
                : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(value == 'todas' ? null : value),
              size: 16,
              color: isSelected ? Colors.white : theme.disabledColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : theme.disabledColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF3A3A3A)
              : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nome...',
          hintStyle: TextStyle(color: theme.disabledColor, fontSize: 13),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.disabledColor,
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          suffixIcon: termoPesquisa.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      size: 16,
                      color: theme.primaryColor,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        termoPesquisa = '';
                      });
                    },
                  ),
                )
              : null,
        ),
        style: TextStyle(fontSize: 13, color: theme.textTheme.bodyLarge?.color),
        onChanged: (value) {
          setState(() {
            termoPesquisa = value;
          });
        },
      ),
    );
  }

  Widget _buildFiltersMenu() {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.tune_rounded, color: theme.primaryColor, size: 20),
      ),
      tooltip: 'Filtros',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      offset: const Offset(0, 8),
      constraints: const BoxConstraints(minWidth: 280),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cabeçalho do menu
                Row(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      color: theme.primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filtrar por Status',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Separador
                Container(
                  height: 1,
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF3A3A3A)
                      : Colors.grey.shade200,
                ),
                const SizedBox(height: 16),
                // Opções de filtro
                _buildFilterOption(
                  theme: theme,
                  label: 'Todas as Solicitações',
                  value: 'todas',
                  isSelected: filtroStatus == 'todas',
                  icon: Icons.list_alt_rounded,
                  onTap: () {
                    setState(() {
                      filtroStatus = 'todas';
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
                _buildFilterOption(
                  theme: theme,
                  label: 'Pendentes',
                  value: 'pendente',
                  isSelected: filtroStatus == 'pendente',
                  icon: Icons.schedule_rounded,
                  onTap: () {
                    setState(() {
                      filtroStatus = 'pendente';
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
                _buildFilterOption(
                  theme: theme,
                  label: 'Agendadas',
                  value: 'agendada',
                  isSelected: filtroStatus == 'agendada',
                  icon: Icons.event_available,
                  onTap: () {
                    setState(() {
                      filtroStatus = 'agendada';
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
                _buildFilterOption(
                  theme: theme,
                  label: 'Coletando',
                  value: 'coletando',
                  isSelected: filtroStatus == 'coletando',
                  icon: Icons.local_shipping,
                  onTap: () {
                    setState(() {
                      filtroStatus = 'coletando';
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
                _buildFilterOption(
                  theme: theme,
                  label: 'Concluídas',
                  value: 'concluido',
                  isSelected: filtroStatus == 'concluido',
                  icon: Icons.check_circle,
                  onTap: () {
                    setState(() {
                      filtroStatus = 'concluido';
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
                _buildFilterOption(
                  theme: theme,
                  label: 'Canceladas',
                  value: 'cancelado',
                  isSelected: filtroStatus == 'cancelado',
                  icon: Icons.cancel,
                  onTap: () {
                    setState(() {
                      filtroStatus = 'cancelado';
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterOption({
    required ThemeData theme,
    required String label,
    required String value,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? theme.primaryColor : theme.disabledColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? theme.primaryColor
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, size: 16, color: theme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF1A1A1A)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF2A2A2A)
              : Colors.grey.shade100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildSearchField()),
          const SizedBox(width: 16),
          _buildFiltersMenu(),
        ],
      ),
    );
  }

  Widget _buildSolicitacaoTabela(dynamic solicitacao) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(solicitacao['status']);
    final statusIcon = _getStatusIcon(solicitacao['status']);
    final statusText = _getStatusText(solicitacao['status']);

    // Formatação da data e hora
    final data = solicitacao['criado_em'] != null
        ? DateTime.tryParse(solicitacao['criado_em'])
        : null;
    final dataStr = data != null
        ? '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}'
        : 'Sem data';
    final horaStr = data != null
        ? '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}'
        : '';

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) =>
              DetalhesSolicitacaoDialog(solicitacao: solicitacao),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF1A1A1A)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Status com tag
            Container(
              width: 100,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 12),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        statusText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Morador
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Morador',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.disabledColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    solicitacao['nome_morador'] ??
                        solicitacao['morador_id'] ??
                        'Morador não identificado',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Endereço
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Endereço',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.disabledColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    solicitacao['endereco'] ?? 'Endereço não informado',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Data e Hora
            Container(
              width: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data/Hora',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.disabledColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$dataStr\n$horaStr',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabelaHeader() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            child: Text(
              'Status',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              'Morador',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              'Endereço',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 80,
            child: Text(
              'Data/Hora',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
                fontSize: 12,
              ),
            ),
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

  Widget _buildMobileLayout() {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Ações mobile sem título
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Campo de busca compacto
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 250),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF2A2A2A)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF3A3A3A)
                        : Colors.grey.shade200,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome...',
                    hintStyle: TextStyle(
                      color: theme.disabledColor,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: theme.disabledColor,
                      size: 18,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    suffixIcon: termoPesquisa.isNotEmpty
                        ? Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                size: 16,
                                color: theme.primaryColor,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  termoPesquisa = '';
                                });
                              },
                            ),
                          )
                        : null,
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  onChanged: (value) {
                    setState(() {
                      termoPesquisa = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Botão de filtros
            Container(
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.tune_rounded,
                  color: theme.primaryColor,
                  size: 18,
                ),
                tooltip: 'Filtros',
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                offset: const Offset(0, 8),
                constraints: const BoxConstraints(minWidth: 200),
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Cabeçalho
                          Row(
                            children: [
                              Icon(
                                Icons.filter_list_rounded,
                                color: theme.primaryColor,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Filtrar por Status',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Separador
                          Container(
                            height: 1,
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF3A3A3A)
                                : Colors.grey.shade200,
                          ),
                          const SizedBox(height: 12),
                          // Opções
                          _buildFilterOption(
                            theme: theme,
                            label: 'Todas',
                            value: 'todas',
                            isSelected: filtroStatus == 'todas',
                            icon: Icons.list_alt_rounded,
                            onTap: () {
                              setState(() {
                                filtroStatus = 'todas';
                              });
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(height: 6),
                          _buildFilterOption(
                            theme: theme,
                            label: 'Pendentes',
                            value: 'pendente',
                            isSelected: filtroStatus == 'pendente',
                            icon: Icons.schedule_rounded,
                            onTap: () {
                              setState(() {
                                filtroStatus = 'pendente';
                              });
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(height: 6),
                          _buildFilterOption(
                            theme: theme,
                            label: 'Agendadas',
                            value: 'agendada',
                            isSelected: filtroStatus == 'agendada',
                            icon: Icons.event_available,
                            onTap: () {
                              setState(() {
                                filtroStatus = 'agendada';
                              });
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(height: 6),
                          _buildFilterOption(
                            theme: theme,
                            label: 'Coletando',
                            value: 'coletando',
                            isSelected: filtroStatus == 'coletando',
                            icon: Icons.local_shipping,
                            onTap: () {
                              setState(() {
                                filtroStatus = 'coletando';
                              });
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(height: 6),
                          _buildFilterOption(
                            theme: theme,
                            label: 'Concluídas',
                            value: 'concluido',
                            isSelected: filtroStatus == 'concluido',
                            icon: Icons.check_circle,
                            onTap: () {
                              setState(() {
                                filtroStatus = 'concluido';
                              });
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(height: 6),
                          _buildFilterOption(
                            theme: theme,
                            label: 'Canceladas',
                            value: 'cancelado',
                            isSelected: filtroStatus == 'cancelado',
                            icon: Icons.cancel,
                            onTap: () {
                              setState(() {
                                filtroStatus = 'cancelado';
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSolicitacaoCardMobile(dynamic solicitacao) {
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
    final horaStr = data != null
        ? '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}'
        : '';
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) =>
              DetalhesSolicitacaoDialog(solicitacao: solicitacao),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primeira linha: Status e Data
            Row(
              children: [
                // Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Data e Hora
                Text(
                  '$dataStr $horaStr',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.disabledColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Segunda linha: Morador e Endereço
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Morador
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Morador',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.disabledColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        solicitacao['nome_morador'] ??
                            solicitacao['morador_id'] ??
                            'Morador não identificado',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Endereço
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Endereço',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.disabledColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        solicitacao['endereco'] ?? 'Endereço não informado',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;
    // Responsividade: padding menor em telas pequenas (igual ao dashboard)
    final horizontalPadding = width < 600 ? 8.0 : (width < 900 ? 16.0 : 32.0);
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isMobile) ...[_buildMobileLayout()],
              if (!isMobile) ...[
                // Nova seção de filtros moderna (desktop/tablet)
                _buildFiltersSection(),
                const SizedBox(height: 32),
              ],
              // Lista de solicitações
              SizedBox(
                height: width < 900 ? 600 : 700,
                child: StreamBuilder<List<Map<String, dynamic>>>(
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
                    final solicitacoesFiltradas = solicitacoes.where((s) {
                      final matchStatus =
                          filtroStatus == 'todas' ||
                          s['status'] == filtroStatus;
                      final matchPesquisa =
                          termoPesquisa.isEmpty ||
                          (s['nome_morador']?.toLowerCase().contains(
                                termoPesquisa.toLowerCase(),
                              ) ??
                              false);
                      return matchStatus && matchPesquisa;
                    }).toList();
                    if (solicitacoesFiltradas.isEmpty) {
                      return Center(
                        child: Text(
                          termoPesquisa.isNotEmpty || filtroStatus != 'todas'
                              ? 'Nenhuma solicitação encontrada com os filtros aplicados.'
                              : 'Nenhuma solicitação encontrada.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.disabledColor,
                          ),
                        ),
                      );
                    }
                    // Visualização em tabela (desktop) ou cards (mobile)
                    if (isMobile) {
                      return ListView.separated(
                        itemCount: solicitacoesFiltradas.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return _buildSolicitacaoCardMobile(
                            solicitacoesFiltradas[index],
                          );
                        },
                      );
                    } else {
                      return Column(
                        children: [
                          _buildTabelaHeader(),
                          Expanded(
                            child: ListView.separated(
                              itemCount: solicitacoesFiltradas.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 4),
                              itemBuilder: (context, index) {
                                return _buildSolicitacaoTabela(
                                  solicitacoesFiltradas[index],
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
