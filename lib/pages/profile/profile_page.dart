import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:educatitivegame/data/database_helper.dart';
import 'package:educatitivegame/utils/auth_provider.dart';
import 'package:educatitivegame/utils/profile_icons.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>?> _userData;
  late Future<Map<String, dynamic>?> _userStats;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isEditing = false;
  bool _obscurePassword = true;
  int _selectedIconIndex = 0;
  bool _showIconSelection = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUserId;
    _loadUserData(userId!);
  }

  void _loadUserData(int userId) {
    _userData = DatabaseHelper.instance.getUserById(userId);
    _userStats = DatabaseHelper.instance.getUserStats(userId);
    
    _userData.then((user) {
      if (user != null) {
        _usernameController.text = user['username'];
        _emailController.text = user['email'] ?? '';
        _passwordController.text = user['password'];
        _selectedIconIndex = user['profile_icon'] ?? 0;
      }
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final userId = Provider.of<AuthProvider>(context, listen: false).currentUserId;
      
      await DatabaseHelper.instance.updateUserProfile(
        userId!,
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      await DatabaseHelper.instance.updateProfileIcon(userId, _selectedIconIndex);
      
      setState(() {
        _isEditing = false;
        _showIconSelection = false;
        _loadUserData(userId);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([_userData, _userStats]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Erro ao carregar perfil'));
          }

          final userData = snapshot.data![0] as Map<String, dynamic>?;
          final userStats = snapshot.data![1] as Map<String, dynamic>?;

          if (userData == null) {
            return const Center(child: Text('Usuário não encontrado'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_isEditing) {
                              setState(() => _showIconSelection = !_showIconSelection);
                            }
                          },
                          child: CircleAvatar(
                            radius: 40,
                            child: ProfileIcons.getIcon(
                              _selectedIconIndex,
                              size: 80,
                            ),
                          ),
                        ),
                        if (_showIconSelection) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Escolha seu ícone:',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: List.generate(5, (index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() => _selectedIconIndex = index);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: _selectedIconIndex == index
                                        ? Border.all(
                                            color: Theme.of(context).primaryColor,
                                            width: 3,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: CircleAvatar(
                                    radius: 25,
                                    child: index == 0
                                        ? ProfileIcons.getDefaultIcon(
                                            _usernameController.text,
                                            size: 50,
                                          )
                                        : ProfileIcons.getIcon(
                                            index,
                                            size: 50,
                                          ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Seção de Informações do Usuário
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Nome de Usuário'),
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor insira um nome de usuário';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor insira um email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor insira uma senha';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 30),
                  const Text(
                    'Estatísticas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  
                  // Seção de Estatísticas
                  _buildStatCard('Fácil', userStats?['level1_score'] ?? 0),
                  _buildStatCard('Médio', userStats?['level2_score'] ?? 0),
                  _buildStatCard('Difícil', userStats?['level3_score'] ?? 0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String level, int score) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(level, style: const TextStyle(fontSize: 16)),
            Text('$score pontos', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}