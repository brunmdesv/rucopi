import 'package:flutter/material.dart';
import 'configuracoes_page.dart';
import '../widgets/app_padrao.dart';

class ConfiguracoesRoute extends StatelessWidget {
  const ConfiguracoesRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPadrao(mostrarAppBar: true, child: const ConfiguracoesPage());
  }
}
