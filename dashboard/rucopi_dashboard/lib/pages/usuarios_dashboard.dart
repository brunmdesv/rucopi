import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Usuários'),
        actions: [
          // Apenas administradores veem o botão de adicionar usuário
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: 'Novo Usuário',
              onPressed: _showNovoUsuarioDialog,
            ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _usuariosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar usuários.'));
          }
          final usuarios = snapshot.data ?? [];
          if (usuarios.isEmpty) {
            return const Center(child: Text('Nenhum usuário cadastrado.'));
          }
          return ListView.separated(
            itemCount: usuarios.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(usuario['nome'] ?? ''),
                subtitle: Text('Cargo: ${usuario['cargo'] ?? ''}'),
                trailing: Text(
                  usuario['criado_em'] != null
                      ? usuario['criado_em'].toString().substring(0, 10)
                      : '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
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
    return AlertDialog(
      title: const Text('Novo Usuário'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Informe o nome' : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Informe o e-mail' : null,
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              controller: _senhaController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
              validator: (v) =>
                  v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
            ),
            DropdownButtonFormField<String>(
              value: _cargo,
              items: const [
                DropdownMenuItem(
                  value: 'administrador',
                  child: Text('Administrador'),
                ),
                DropdownMenuItem(value: 'operador', child: Text('Operador')),
              ],
              onChanged: (v) => setState(() => _cargo = v ?? 'operador'),
              decoration: const InputDecoration(labelText: 'Cargo'),
            ),
            if (_erro != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_erro!, style: const TextStyle(color: Colors.red)),
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
