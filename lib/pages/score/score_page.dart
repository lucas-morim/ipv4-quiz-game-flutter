import 'package:flutter/material.dart';
import 'package:educatitivegame/data/database_helper.dart';
import 'package:provider/provider.dart';
import 'package:educatitivegame/utils/auth_provider.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  late Future<Map<String, dynamic>?> _userData;
  late Future<List<Map<String, dynamic>>> _topScoresLevel1;
  late Future<List<Map<String, dynamic>>> _topScoresLevel2;
  late Future<List<Map<String, dynamic>>> _topScoresLevel3;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    
    try {
      _userData = DatabaseHelper.instance.getUserStats(userId);
      _topScoresLevel1 = DatabaseHelper.instance.getTopScoresByLevel(1);
      _topScoresLevel2 = DatabaseHelper.instance.getTopScoresByLevel(2);
      _topScoresLevel3 = DatabaseHelper.instance.getTopScoresByLevel(3);
    } catch (e) {
      print('Erro ao carregar dados: $e');
      _userData = Future.value(null);
      _topScoresLevel1 = Future.value([]);
      _topScoresLevel2 = Future.value([]);
      _topScoresLevel3 = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthProvider>(context).userId;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Top Scores'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Fácil'),
              Tab(text: 'Médio'),
              Tab(text: 'Difícil'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildScoreTab(_topScoresLevel1, 1, userId),
            _buildScoreTab(_topScoresLevel2, 2, userId),
            _buildScoreTab(_topScoresLevel3, 3, userId),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreTab(Future<List<Map<String, dynamic>>> topScores, int level, int userId) {
    return FutureBuilder(
      future: Future.wait([topScores, _userData]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('Erro ao carregar dados'));
        }

        final scores = snapshot.data![0] as List<Map<String, dynamic>>;
        final userStats = snapshot.data![1] as Map<String, dynamic>?;

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                'Top 5 Jogadores',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildLeaderboard(scores, userId),
              const SizedBox(height: 24),
              if (userStats != null && 
                  !scores.any((score) => score['user_id'] == userId))
                _buildUserScoreCard(userStats, level),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeaderboard(List<Map<String, dynamic>> scores, int userId) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: scores.length,
      itemBuilder: (context, index) {
        final score = scores[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text('${index + 1}'),
          ),
          title: Text(score['username'] ?? 'Anônimo'),
          trailing: Text('${score['score']} pontos'),
          tileColor: score['user_id'] == userId 
              ? Colors.blue.withOpacity(0.1) 
              : null,
        );
      },
    );
  }

  Widget _buildUserScoreCard(Map<String, dynamic> userStats, int level) {
    final score = userStats['level${level}_score'] ?? 0;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Seu Desempenho',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Pontuação: $score'),
            Text('Posição: ${_getPositionText(score, level)}'),
          ],
        ),
      ),
    );
  }

  String _getPositionText(int score, int level) {
    if (score == 0) return 'Não classificado';
    return 'Fora do Top 5';
  }
}