import 'package:flutter/material.dart';

class DialogSolicitacoesDoDia extends StatelessWidget {
  final DateTime data;
  final List<Map<String, dynamic>> solicitacoes;

  const DialogSolicitacoesDoDia({
    Key? key,
    required this.data,
    required this.solicitacoes,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.event_available, color: Colors.blue),
          const SizedBox(width: 8),
          Text('Solicitações em ${_formatDate(data)}'),
        ],
      ),
      content: solicitacoes.isEmpty
          ? const Text('Nenhuma solicitação agendada para este dia.')
          : SizedBox(
              width: 350,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: solicitacoes.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final s = solicitacoes[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.assignment_turned_in_rounded,
                      color: Colors.blue,
                    ),
                    title: Text(
                      s['nome_morador'] ?? 'Morador não identificado',
                    ),
                    subtitle: Text(s['endereco'] ?? 'Sem endereço'),
                    trailing: Text(
                      (s['data_coleta'] ?? '').toString().substring(0, 10),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                      ),
                    ),
                    onTap: () {
                      // Opcional: abrir detalhes da solicitação
                    },
                  );
                },
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
