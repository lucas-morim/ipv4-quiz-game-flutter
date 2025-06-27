import 'dart:math';
import 'package:educatitivegame/models/ipv4.dart';
import 'package:educatitivegame/models/subnet_mask.dart';
import 'package:educatitivegame/utils/network_calculator.dart';
import 'package:flutter/material.dart';
import 'package:educatitivegame/data/database_helper.dart';
import 'package:provider/provider.dart';
import 'package:educatitivegame/utils/auth_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class QuizPage extends StatefulWidget {
  final int difficultyLevel;

  const QuizPage({super.key, required this.difficultyLevel});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final GlobalKey<_AnimatedTimerState> _timerKey = GlobalKey<_AnimatedTimerState>();
  final AudioPlayer _resultSoundPlayer = AudioPlayer();
  final AudioPlayer _quizSoundPlayer = AudioPlayer();
  late List<Question> _questions;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _wrongAnswers = 0;
  String? _selectedAnswer;
  bool _isAnswered = false;
  bool _isCorrect = false;
  bool _isTimeout = false;
  bool _isMuted = false;

  final Random _random = Random();
  final Color _primaryColor = Colors.blue.shade700;
  final Color _secondaryColor = Colors.blue.shade400;

  @override
  void initState() {
    super.initState();
    _questions = [];
    _generateQuestion();
    _playBackgroundMusic();
  }

  @override
  void dispose() {
    _quizSoundPlayer.dispose();
    _resultSoundPlayer.dispose();
    super.dispose();
  }

  Future<void> _playBackgroundMusic() async {
    await _quizSoundPlayer.stop();
    await _quizSoundPlayer.setReleaseMode(ReleaseMode.loop);
    await _quizSoundPlayer.play(AssetSource('sounds/quizSound.mp3'));
  }

  void _onTimeout() async {
    if (!_isAnswered) {
      setState(() {
        _isAnswered = true;
        _isTimeout = true;
        _selectedAnswer = null;
        _wrongAnswers++;
      });
      await _resultSoundPlayer.play(AssetSource('sounds/timeSound.mp3'));
    }
  }

  void _generateQuestion() {
    final question = _random.nextDouble() > 0.7
        ? _generateSameSegmentQuestion()
        : _generateNetworkQuestion();

    setState(() {
      _questions.add(question);
      _currentQuestionIndex = _questions.length - 1;
      _isAnswered = false;
      _selectedAnswer = null;
    });
  }

  Question _generateNetworkQuestion() {
    final type = _random.nextBool() ? QuestionType.networkId : QuestionType.broadcast;
    final ip = _generateRandomIp();
    final subnetMask = _generateSubnetMask();

    final correctAnswer = type == QuestionType.networkId
        ? NetworkCalculator.calculateNetworkId(ip, subnetMask).toString()
        : NetworkCalculator.calculateBroadcast(ip, subnetMask).toString();

    final options = _generateAnswerOptions(correctAnswer, ip);

    return Question(
      text: type == QuestionType.networkId
          ? 'Qual é o Network ID de ${ip.toString()}/${subnetMask.toString()}?'
          : 'Qual é o Broadcast de ${ip.toString()}/${subnetMask.toString()}?',
      correctAnswer: correctAnswer,
      type: type,
      ip: ip,
      subnetMask: subnetMask,
      options: options,
    );
  }

  Question _generateSameSegmentQuestion() {
    final ip1 = _generateRandomIp();
    final ip2 = _generateRandomIp();
    final subnetMask = _generateSubnetMask();
    final isSameNetwork = NetworkCalculator.isSameNetwork(ip1, ip2, subnetMask);

    return Question(
      text: '${ip1.toString()} e ${ip2.toString()} estão na mesma rede com máscara ${subnetMask.toString()}?',
      correctAnswer: isSameNetwork ? 'Sim' : 'Não',
      type: QuestionType.sameSegment,
      ip: ip1,
      ip2: ip2,
      subnetMask: subnetMask,
      options: ['Sim', 'Não'],
    );
  }

  IPv4 _generateRandomIp() {
    switch (widget.difficultyLevel) {
      case 1:
        return IPv4(192, 168, _random.nextInt(256), _random.nextInt(256));
      case 2:
        return IPv4(
          172,
          (16 + _random.nextInt(16)),
          _random.nextInt(256),
          _random.nextInt(256),
        );
      case 3:
        return switch (_random.nextInt(3)) {
          0 => IPv4(
              10,
              _random.nextInt(256),
              _random.nextInt(256),
              _random.nextInt(256),
            ),
          1 => IPv4(192, 168, _random.nextInt(256), _random.nextInt(256)),
          _ => IPv4(
              172,
              (16 + _random.nextInt(16)),
              _random.nextInt(256),
              _random.nextInt(256),
            ),
        };
      default:
        return IPv4(192, 168, 1, 1);
    }
  }

  SubnetMask _generateSubnetMask() {
    switch (widget.difficultyLevel) {
      case 1:
        return SubnetMask.fromString(['/8', '/16', '/24'][_random.nextInt(3)]);
      case 2:
        return SubnetMask.fromString('/${24 + _random.nextInt(7)}');
      case 3:
        return SubnetMask.fromString('/${16 + _random.nextInt(7)}');
      default:
        return SubnetMask.fromString('/24');  
    }
  }

  void _checkAnswer(String answer) async {
    setState(() {
      _isAnswered = true;
      _selectedAnswer = answer;
      _isTimeout = false;
      _isCorrect = answer == _questions[_currentQuestionIndex].correctAnswer;
      _timerKey.currentState?.stop();

      if (_isCorrect) {
        _score += widget.difficultyLevel * 10;
      } else {
        _score -= widget.difficultyLevel * 5;
        if (_score < 0) _score = 0;
        _wrongAnswers++;
      }
    });

    if (_isCorrect) {
      await _resultSoundPlayer.play(AssetSource('sounds/correctSound.mp3'));
    } else {
      await _resultSoundPlayer.play(AssetSource('sounds/wrongSound.mp3'));
    }
  }

  void _nextQuestion() {
    _generateQuestion();
    _playBackgroundMusic();
    _timerKey.currentState?.reset();
    setState(() {
      _isTimeout = false;
    });
  }

  int _getTimerDuration(int level) {
    switch (level) {
      case 1:
        return 30;
      case 2:
        return 20;
      case 3:
        return 10;
      default:
        return 30;
    }
  }

  void _toggleMute() async {
    setState(() {
      _isMuted = !_isMuted;
    });

    if (_isMuted) {
      await _quizSoundPlayer.setVolume(0);
      await _resultSoundPlayer.setVolume(0);
    } else {
      await _quizSoundPlayer.setVolume(1);
      await _resultSoundPlayer.setVolume(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quiz IPv4 - ${_getLevelName(widget.difficultyLevel)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primaryColor, _secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _toggleMute,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  RotationTransition(turns: animation, child: child),
              child: Icon(
                _isMuted ? Icons.volume_off : Icons.volume_up,
                key: ValueKey(_isMuted),
                color: Colors.white,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.shade600,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(
                  '$_score',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(3, (index) {
                    final isHeartActive = index < (3 - _wrongAnswers);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: PulsatingHeart(
                        icon: isHeartActive ? Icons.favorite : Icons.favorite_border,
                        color: isHeartActive ? Colors.red[400]! : Colors.grey[400]!,
                        size: 28,
                        isActive: isHeartActive,
                      ),
                    );
                  }),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Pergunta ${_currentQuestionIndex + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedTimer(
                      key: _timerKey,
                      duration: _getTimerDuration(widget.difficultyLevel),
                      onTimeout: _onTimeout,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              minHeight: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Text(
                question.text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            if (question.type != QuestionType.sameSegment)
              ..._buildNetworkOptions(question)
            else
              ..._buildSameSegmentOptions(),
            const Spacer(),
            if (_isAnswered) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  color: _isTimeout
                      ? Colors.red.shade50
                      : (_isCorrect ? Colors.green.shade50 : Colors.red.shade50),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isTimeout
                        ? Colors.red
                        : (_isCorrect ? Colors.green : Colors.red),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isTimeout
                          ? Icons.timer_off
                          : (_isCorrect ? Icons.check_circle : Icons.error),
                      color: _isTimeout
                          ? Colors.red
                          : (_isCorrect ? Colors.green : Colors.red),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isTimeout
                          ? 'Tempo esgotado!'
                          : (_isCorrect ? 'Resposta Correta!' : 'Resposta Incorreta'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Resposta correta: ${question.correctAnswer}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _wrongAnswers == 3 ? _finishQuiz : _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 3,
                ),
                child: Text(
                  _wrongAnswers == 3 ? 'Terminar Quiz' : 'Próxima Pergunta',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNetworkOptions(Question question) {
    return question.options.map((option) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _getButtonColor(option, question.correctAnswer) ??
                Colors.blue.shade50,
            foregroundColor: Colors.blue.shade900,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: _getBorderColor(option, question.correctAnswer),
                width: 2,
              ),
            ),
            elevation: 2,
          ),
          onPressed: _isAnswered ? null : () => _checkAnswer(option),
          child: Text(
            option,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildSameSegmentOptions() {
    return ['Sim', 'Não'].map((option) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _getButtonColor(
                    option, _questions[_currentQuestionIndex].correctAnswer) ??
                Colors.blue.shade50,
            foregroundColor: Colors.blue.shade900,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: _getBorderColor(
                    option, _questions[_currentQuestionIndex].correctAnswer),
                width: 2,
              ),
            ),
            elevation: 2,
          ),
          onPressed: _isAnswered ? null : () => _checkAnswer(option),
          child: Text(
            option,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }).toList();
  }

  Color? _getButtonColor(String option, String correctAnswer) {
    if (!_isAnswered) return null;
    if (option == correctAnswer) return Colors.green.shade100;
    if (option == _selectedAnswer) return Colors.red.shade100;
    return null;
  }

  Color _getBorderColor(String option, String correctAnswer) {
    if (!_isAnswered) return Colors.blue.shade200;
    if (option == correctAnswer) return Colors.green.shade400;
    if (option == _selectedAnswer) return Colors.red.shade400;
    return Colors.blue.shade200;
  }

  List<String> _generateAnswerOptions(String correctAnswer, IPv4 correctIp) {
    final options = <String>[correctAnswer];

    while (options.length < 4) {
      final offset = _random.nextInt(50) + 1;
      final wrongIp = IPv4(
        correctIp.octet1,
        correctIp.octet2,
        correctIp.octet3,
        ((correctIp.octet4 + offset) % 256),
      );
      if (!options.contains(wrongIp.toString())) {
        options.add(wrongIp.toString());
      }
    }
    return options..shuffle();
  }

  void _finishQuiz() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (userId != -1) {
        await DatabaseHelper.instance.updateLevelScore(
          userId,
          _score,
          widget.difficultyLevel,
        );
      }

      Navigator.pop(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Resultados'),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, _secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.amber.shade600,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$_score',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Pontuação Final',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nível: ${_getLevelName(widget.difficultyLevel)}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (userId == -1)
                      Text(
                        '(Pontuação não salva - modo visitante)',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
                      child: const Text('Voltar ao Início'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar pontuação: $e')));
    }
  }

  String _getLevelName(int level) {
    return ['Fácil', 'Médio', 'Difícil'][level - 1];
  }
}

class Question {
  final String text;
  final String correctAnswer;
  final QuestionType type;
  final IPv4 ip;
  final IPv4? ip2;
  final SubnetMask subnetMask;
  final List<String> options;

  Question({
    required this.text,
    required this.correctAnswer,
    required this.type,
    required this.ip,
    this.ip2,
    required this.subnetMask,
    required this.options,
  });
}

class PulsatingHeart extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool isActive;

  const PulsatingHeart({
    super.key,
    required this.icon,
    required this.color,
    required this.size,
    required this.isActive,
  });

  @override
  State<PulsatingHeart> createState() => _PulsatingHeartState();
}

class _PulsatingHeartState extends State<PulsatingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PulsatingHeart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.animateTo(1.0, duration: const Duration(milliseconds: 300));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Icon(widget.icon, color: widget.color, size: widget.size),
    );
  }
}

class AnimatedTimer extends StatefulWidget {
  final int duration;
  final VoidCallback onTimeout;

  const AnimatedTimer({
    super.key,
    required this.duration,
    required this.onTimeout,
  });

  @override
  State<AnimatedTimer> createState() => _AnimatedTimerState();
}

class _AnimatedTimerState extends State<AnimatedTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  void _initializeTimer() {
    _remainingSeconds = widget.duration;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onTimeout();
        }
      });

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller)
      ..addListener(() {
        final newSeconds =
            widget.duration - (_controller.value * widget.duration).round();
        if (newSeconds != _remainingSeconds) {
          setState(() => _remainingSeconds = newSeconds);
        }
      });

    _controller.forward();
  }

  void stop() {
    _controller.stop();
  }

  void reset() {
    _controller.reset();
    setState(() {
      _remainingSeconds = widget.duration;
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressColor = _remainingSeconds <= 5 ? Colors.red : Colors.blue.shade600;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: progressColor.withOpacity(0.2),
          width: 3,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              value: _animation.value,
              strokeWidth: 4,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          Text(
            '$_remainingSeconds',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: progressColor,
            ),
          ),
        ],
      ),
    );
  }
}

enum QuestionType { networkId, broadcast, sameSegment }