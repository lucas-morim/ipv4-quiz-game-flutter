import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:educatitivegame/utils/auth_provider.dart';
import 'package:educatitivegame/utils/profile_icons.dart';
import 'package:educatitivegame/data/database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>?> _userFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = Provider.of<AuthProvider>(context).currentUserId;
    if (userId != null) {
      _userFuture = DatabaseHelper.instance.getUserById(userId);
    }
  }

  void _refreshUserData() {
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUserId;
    if (userId != null) {
      setState(() {
        _userFuture = DatabaseHelper.instance.getUserById(userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;
    final userId = authProvider.currentUserId;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildUserStatusBar(context, isLoggedIn),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo/Header
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade800,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lan,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'IPv4 Quiz Game',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Teste seu conhecimento sobre endereçamento IP',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      _buildActionButton(
                        context: context,
                        icon: Icons.play_arrow,
                        label: 'INICIAR QUIZ',
                        color: Colors.blue.shade800,
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/difficulty',
                          arguments: userId,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildActionButton(
                        context: context,
                        icon: Icons.leaderboard,
                        label: 'VER SCORES',
                        color: Colors.green.shade800,
                        onPressed: () => Navigator.pushNamed(context, '/score'),
                      ),
                      const SizedBox(height: 16),

                      _buildActionButton(
                        context: context,
                        icon: Icons.person,
                        label: 'MEU PERFIL',
                        color: Colors.purple.shade800,
                        onPressed: () async {
                          if (isLoggedIn) {
                            await Navigator.pushNamed(context, '/profile');
                            _refreshUserData(); // Atualiza após voltar da tela de perfil
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Faça login para acessar seu perfil')),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildActionButton(
                        context: context,
                        icon: isLoggedIn ? Icons.logout : Icons.login,
                        label: isLoggedIn ? 'SAIR' : 'ENTRAR',
                        color: isLoggedIn ? Colors.red.shade800 : Colors.orange.shade800,
                        onPressed: () => isLoggedIn
                            ? _showExitDialog(context)
                            : Navigator.pushNamed(context, '/login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatusBar(BuildContext context, bool isLoggedIn) {
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUserId;
    if (!isLoggedIn || userId == null) {
      return _buildDefaultStatusBar();
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: _userFuture,
      builder: (context, snapshot) {
        final userData = snapshot.data;
        final username = userData?['username'] ?? 'Visitante';
        final profileIcon = userData?['profile_icon'] ?? 0;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade800.withOpacity(0.8),
          ),
          child: Row(
            children: [
              SizedBox(height: 60),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: profileIcon == 0
                    ? ProfileIcons.getDefaultIcon(username, size: 50)
                    : ProfileIcons.getIcon(profileIcon, size: 50),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefaultStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade800.withOpacity(0.8),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visitante',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Não logado',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.exit_to_app, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Sair do Aplicativo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Deseja realmente sair do IPv4 Quiz Game?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<AuthProvider>(context, listen: false).logout();
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Sair'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
