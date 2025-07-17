import 'package:flutter/material.dart';
import '../theme/app_styles.dart';

class AppPadrao extends StatelessWidget {
  final String? titulo;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool mostrarAppBar;
  final Widget? leading;
  final Color? backgroundColor;

  const AppPadrao({
    Key? key,
    this.titulo,
    required this.child,
    this.actions,
    this.floatingActionButton,
    this.mostrarAppBar = true,
    this.leading,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      appBar: mostrarAppBar
          ? AppBar(
              title: titulo != null
                  ? Text(titulo!, style: theme.textTheme.titleLarge)
                  : null,
              centerTitle: true,
              elevation: 2,
              backgroundColor: theme.appBarTheme.backgroundColor,
              shadowColor: Colors.black12,
              leading: leading,
              actions: actions,
              iconTheme: theme.appBarTheme.iconTheme,
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: child,
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
