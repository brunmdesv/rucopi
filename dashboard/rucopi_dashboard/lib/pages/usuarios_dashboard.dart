import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_styles.dart';

class UsuariosDashboard extends StatefulWidget {
  const UsuariosDashboard({Key? key}) : super(key: key);

  @override
  State<UsuariosDashboard> createState() => _UsuariosDashboardState();
}

class _UsuariosDashboardState extends State<UsuariosDashboard> {
  late Future<List<dynamic>> _usuariosFuture;
  bool _isAdmin = false;
  String? _cargoUsuario;

  @override
  void initState() {
    super.initState();
    _usuariosFuture = _fetchUsuarios();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final response = await Supabase.instance.client
        .from('usuarios')
        .select('cargo')
        .eq('id', user.id)
        .single();
    setState(() {
      _cargoUsuario = response != null ? response['cargo'] as String? : null;
      _isAdmin = _cargoUsuario == 'administrador';
    });
  }

  Future<List<dynamic>> _fetchUsuarios() async {
    final response = await Supabase.instance.client
        .from('usuarios')
        .select('id, nome, cargo, criado_em')
        .order('criado_em', ascending: false);
    return response;
  }

  void _showNovoUsuarioDialog() {
    showDialog(
      context: context,
      builder: (context) => NovoUsuarioDialog(
        onUsuarioCriado: () {
          setState(() {
            _usuariosFuture = _fetchUsuarios();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: width < 600 ? width * 0.95 : 800,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.card),
                  topRight: Radius.circular(AppRadius.card),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.people_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gerenciar Usuários',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (_isAdmin)
                    IconButton(
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      tooltip: 'Novo Usuário',
                      onPressed: _showNovoUsuarioDialog,
                    ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _usuariosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erro ao carregar usuários',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final usuarios = snapshot.data ?? [];
                  if (usuarios.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 48,
                            color: theme.disabledColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum usuário cadastrado',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.disabledColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: usuarios.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final usuario = usuarios[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.primaryColor.withOpacity(
                              0.1,
                            ),
                            child: Icon(
                              Icons.person,
                              color: theme.primaryColor,
                            ),
                          ),
                          title: Text(
                            usuario['nome'] ?? 'Nome não informado',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getCargoColor(
                                    usuario['cargo'],
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  usuario['cargo'] ?? 'Cargo não informado',
                                  style: TextStyle(
                                    color: _getCargoColor(usuario['cargo']),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            usuario['criado_em'] != null
                                ? _formatDate(usuario['criado_em'])
                                : '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.disabledColor,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCargoColor(String? cargo) {
    switch (cargo) {
      case 'administrador':
        return const Color(0xFFD32F2F);
      case 'operador':
        return const Color(0xFF1976D2);
      default:
        return Colors.grey;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final dateTime = DateTime.tryParse(date.toString());
      if (dateTime != null) {
        return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return date.toString().substring(0, 10);
  }
}

class NovoUsuarioDialog extends StatefulWidget {
  final VoidCallback onUsuarioCriado;
  const NovoUsuarioDialog({required this.onUsuarioCriado, Key? key})
    : super(key: key);

  @override
  State<NovoUsuarioDialog> createState() => _NovoUsuarioDialogState();
}

class _NovoUsuarioDialogState extends State<NovoUsuarioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  String _cargo = 'operador';
  bool _loading = false;
  String? _erro;

  Future<void> _criarUsuario() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final jwt = session?.accessToken;
      if (jwt == null)
        throw Exception('Sessão expirada. Faça login novamente.');
      const url = 'http://localhost:8010/proxy/criar-usuario';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nome': _nomeController.text.trim(),
          'email': _emailController.text.trim(),
          'cargo': _cargo,
          'senha': _senhaController.text.trim(),
        }),
      );
      if (response.statusCode == 200) {
        widget.onUsuarioCriado();
        Navigator.of(context).pop();
      } else {
        final body = response.body;
        String msg = 'Erro ao criar usuário.';
        if (body.contains('not_admin')) {
          msg = 'Apenas administradores podem criar usuários.';
        } else if (body.isNotEmpty) {
          msg = 'Erro: $body';
        }
        setState(() {
          _erro = msg;
        });
      }
    } catch (e) {
      setState(() {
        _erro = 'Erro ao criar usuário: ${e.toString()}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      title: Row(
        children: [
          Icon(Icons.person_add, color: theme.primaryColor),
          const SizedBox(width: 8),
          const Text('Novo Usuário'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Informe o e-mail' : null,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _senhaController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (v) =>
                  v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _cargo,
              decoration: const InputDecoration(
                labelText: 'Cargo',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'administrador',
                  child: Text('Administrador'),
                ),
                DropdownMenuItem(value: 'operador', child: Text('Operador')),
              ],
              onChanged: (v) => setState(() => _cargo = v ?? 'operador'),
            ),
            if (_erro != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _erro!,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _loading
              ? null
              : () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _criarUsuario();
                  }
                },
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Criar'),
        ),
      ],
    );
  }
}
