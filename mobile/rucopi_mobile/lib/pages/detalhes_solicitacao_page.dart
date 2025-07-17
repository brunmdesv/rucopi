import 'package:flutter/material.dart';

class DetalhesSolicitacaoPage extends StatelessWidget {
  final Map<String, dynamic> solicitacao;
  const DetalhesSolicitacaoPage({Key? key, required this.solicitacao})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data =
        DateTime.tryParse(solicitacao['criado_em'] ?? '') ?? DateTime.now();
    final fotos = solicitacao['fotos'] is List
        ? List<String>.from(solicitacao['fotos'])
        : [];
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Solicitação')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descrição:', style: Theme.of(context).textTheme.titleMedium),
            Text(
              solicitacao['descricao'] ?? '-',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text('Status: ${solicitacao['status'] ?? '-'}'),
            Text('Tipo de entulho: ${solicitacao['tipo_entulho'] ?? '-'}'),
            Text('Endereço: ${solicitacao['endereco'] ?? '-'}'),
            Text('Data: ${data.day}/${data.month}/${data.year}'),
            const SizedBox(height: 12),
            if (fotos.isNotEmpty) ...[
              Text('Fotos:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: fotos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => Image.network(
                    fotos[i],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
