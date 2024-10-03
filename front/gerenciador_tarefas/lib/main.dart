import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicativo de Usuários',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

// Tela de Login
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = '';
  String senha = '';

  // Função para realizar o login consultando o backend
  Future<void> login() async {
    var url = Uri.parse('http://localhost:8000/login'); // URL do seu backend

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'email': email,
          'senha': senha,
        }),
      );

      if (response.statusCode == 200) {
        // Login bem-sucedido, exibe a próxima tela
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoggedInPage()),
        );
      } else {
        // Login falhou, exibe mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro no login: ${jsonDecode(response.body)['error']}'),
        ));
      }
    } catch (e) {
      // Em caso de erro na requisição (falha na conexão, etc.)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro na requisição: $e'),
      ));
    }
  }

  // Navegar para a página de cadastro
  void goToCadastro() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CadastroPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (value) => email = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
              onChanged: (value) => senha = value,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: Text('Login'),
            ),
            TextButton(
              onPressed: goToCadastro,
              child: Text('Não tem uma conta? Cadastre-se aqui'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => UserListPage()),
                );
              },
              child: Text('Ver Lista de Usuários'),
            ),
          ],
        ),
      ),
    );
  }
}

// Tela de "Foi" após login bem-sucedido
class LoggedInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela após login'),
      ),
      body: Center(
        child: Text(
          'Foi', // Texto exibido
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// Tela de Lista de Usuários
class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<dynamic> usuarios = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // Função para buscar os usuários da API
  Future<void> fetchUsers() async {
    var url = Uri.parse('http://localhost:8000/usuarios');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        setState(() {
          usuarios = jsonDecode(response.body);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao processar os dados: $e'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Erro ao buscar os usuários. Status: ${response.statusCode}, Body: ${response.body}'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Usuários'),
      ),
      body: usuarios.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                var usuario = usuarios[index];
                return ListTile(
                  title: Text(usuario['nome']),
                  subtitle: Text(usuario['email']),
                  trailing: Text(usuario['cargo']),
                );
              },
            ),
    );
  }
}

// Tela de Cadastro
class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  String nome = '';
  String senha = '';
  String confirmarSenha = '';
  String email = '';
  String cargo = '';

  Future<void> cadastrarUsuario() async {
    if (senha != confirmarSenha) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Senhas não correspondem'),
      ));
      return;
    }

    var url = Uri.parse('http://localhost:8000/cadastro');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'nome': nome,
          'senha': senha,
          'confirmar_senha': confirmarSenha,
          'email': email,
          'cargo': cargo,
        }));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Usuário cadastrado com sucesso!'),
      ));
      Navigator.of(context).pop(); // Volta para a página de login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao cadastrar o usuário'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Nome'),
                onChanged: (value) => nome = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                onChanged: (value) => senha = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a senha';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Confirmar Senha'),
                obscureText: true,
                onChanged: (value) => confirmarSenha = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, confirme a senha';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (value) => email = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o email';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Cargo'),
                onChanged: (value) => cargo = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o cargo';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    cadastrarUsuario();
                  }
                },
                child: Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
