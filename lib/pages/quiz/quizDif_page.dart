import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:educatitivegame/utils/auth_provider.dart';

class QuizDifficultyPage extends StatelessWidget {
  const QuizDifficultyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.blue.shade700;
    final Color secondaryColor = Colors.blue.shade400;
    final Color textColor = Colors.blue.shade800;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Selecione a Dificuldade',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, secondaryColor],
            ),
          ),
        ),
        elevation: 4,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Teste seu conhecimento em IPv4',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView(
                children: [
                  _buildDifficultyCard(
                    context,
                    level: 1,
                    title: 'Fácil',
                    description: 'Endereços IP /8, /16 e /24',
                    color: Colors.green.shade600,
                    icon: Icons.school,
                  ),
                  const SizedBox(height: 20),
                  _buildDifficultyCard(
                    context,
                    level: 2,
                    title: 'Médio',
                    description: 'Sub-redes com máscaras variadas',
                    color: Colors.orange.shade600,
                    icon: Icons.workspace_premium,
                  ),
                  const SizedBox(height: 20),
                  _buildDifficultyCard(
                    context,
                    level: 3,
                    title: 'Difícil',
                    description: 'Super-redes e agregação',
                    color: Colors.red.shade600,
                    icon: Icons.star,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text(
                  'Voltar ao menu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyCard(
    BuildContext context, {
    required int level,
    required String title,
    required String description,
    required Color color,
    required IconData icon,
  }) {
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: Colors.blue.shade100,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _startQuiz(context, level, userId),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.3), width: 2),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startQuiz(BuildContext context, int difficultyLevel, int userId) {
    Navigator.pushNamed(
      context,
      '/quiz',
      arguments: {
        'difficultyLevel': difficultyLevel,
        'userId': userId,
      },
    );
  }
}