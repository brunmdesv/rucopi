import 'package:flutter/material.dart';

class AppPadrao extends StatelessWidget {
  final String? titulo;
  final Widget child;
  final List<Widget>? actions;
  final Widget? leading;
  final bool mostrarAppBar;
  final Color? backgroundColor;
  final PreferredSizeWidget? customAppBar;

  const AppPadrao({
    Key? key,
    this.titulo,
    required this.child,
    this.actions,
    this.leading,
    this.mostrarAppBar = true,
    this.backgroundColor,
    this.customAppBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      appBar: mostrarAppBar ? (customAppBar ?? _defaultAppBar(theme)) : null,
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(32), child: child),
      ),
    );
  }

  PreferredSizeWidget _defaultAppBar(ThemeData theme) {
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
                if (leading != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: leading,
                  ),
                if (titulo != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 24, left: 8),
                    child: Text(
                      titulo!,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF606A45),
                      ),
                    ),
                  ),
                const Spacer(),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
