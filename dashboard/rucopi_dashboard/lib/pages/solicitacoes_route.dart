import 'package:flutter/material.dart';
import 'solicitacoes_page.dart';
import '../widgets/app_padrao.dart';

class SolicitacoesRoute extends StatelessWidget {
  const SolicitacoesRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPadrao(mostrarAppBar: true, child: const SolicitacoesPage());
  }
}
