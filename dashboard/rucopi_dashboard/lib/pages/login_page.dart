import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_styles.dart';
import '../theme/theme_provider.dart';
import '../widgets/app_padrao.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool carregando = false;
  bool _obscurePassword = true;
  String? erro;

  void login() async {
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: senhaController.text,
      );
      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login realizado com sucesso'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        // Redirecionar para a home do dashboard
        Future.delayed(const Duration(milliseconds: 300), () {
          if (context.mounted) context.go('/home');
        });
      } else {
        setState(() {
          erro = 'Usuário ou senha inválidos.';
        });
      }
    } on AuthException catch (e) {
      setState(() {
        erro = e.message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        erro = 'Erro inesperado. Tente novamente.';
      });
    } finally {
      setState(() {
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return AppPadrao(
      mostrarAppBar: false,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(AppSpacing.page),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: isDark ? AppShadows.dark : AppShadows.light,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.item),
                Text(
                  'Entrar',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: AppSpacing.section * 2),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Endereço de e-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                TextField(
                  controller: senhaController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.item),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: carregando ? null : login,
                    child: carregando
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                        : const Text('Continuar'),
                  ),
                ),
                if (erro != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      erro!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: AppSpacing.section * 1.5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
