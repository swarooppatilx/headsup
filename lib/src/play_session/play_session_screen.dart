import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../ads/ads_controller.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/level_state.dart';
import '../games_services/games_services.dart';
import '../games_services/score.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../level_selection/teams.dart';
import '../player_progress/player_progress.dart';
import '../style/confetti.dart';
import '../style/palette.dart';

class PlaySessionScreen extends StatefulWidget {
  final Team level;

  const PlaySessionScreen(this.level, {super.key});

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends State<PlaySessionScreen> {
  static final _log = Logger('PlaySessionScreen');

  static const _celebrationDuration = Duration(milliseconds: 2000);
  static const _preCelebrationDuration = Duration(milliseconds: 500);

  bool _duringCelebration = false;
  bool _countdownActive = true;
  int _countdownSeconds = 5;

  late DateTime _startOfPlay;
  int _currentWordIndex = 0;
  int _corrctWords = 0;

  Timer? _timer;
  int _remainingSeconds = 90;

  final List<AccelerometerEvent> _accelerometerValues = [];
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _startCountdown();

    final adsRemoved = context.read<InAppPurchaseController?>()?.adRemoval.active ?? false;
    if (!adsRemoved) {
      context.read<AdsController?>()?.preloadAd();
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _accelerometerSubscription.cancel();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _startCountdown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        setState(() => _countdownSeconds--);
      } else {
        timer.cancel();
        setState(() => _countdownActive = false);
        _startOfPlay = DateTime.now();
        _startTimer();
        _startAccelerometer();
      }
    });
  }

  void _startAccelerometer() {
    bool actionInProgress = false;
    _accelerometerSubscription = accelerometerEvents.listen((event) async {
      if (!actionInProgress) {
        if (event.z > 8) {
          _nextWord();
          actionInProgress = true;
          await Future.delayed(Duration(seconds: 1));
          actionInProgress = false;
        } else if (event.z < -7) {
          _nextWordAndCount();
          actionInProgress = true;
          await Future.delayed(Duration(seconds: 1));
          actionInProgress = false;
        }
      }
    });
  }

  int get _maxItems =>
      [widget.level.imagePaths.length, widget.level.words.length].reduce((a, b) => a > b ? a : b);

  void _nextWord() {
    if (_currentWordIndex < _maxItems - 1) {
      setState(() => _currentWordIndex++);
      context.read<AudioController>().playSfx(SfxType.wrong);
    } else {
      _playerWon();
    }
  }

  void _nextWordAndCount() {
    if (_currentWordIndex < _maxItems - 1) {
      setState(() {
        _currentWordIndex++;
        _corrctWords++;
      });
      context.read<AudioController>().playSfx(SfxType.correct);
    } else {
      _playerWon();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LevelState(goal: widget.level.difficulty, onWin: _playerWon),
        ),
      ],
      child: IgnorePointer(
        ignoring: _duringCelebration || _countdownActive,
        child: Scaffold(
          backgroundColor: palette.backgroundPlaySession,
          body: Stack(
            children: [
              GestureDetector(
                onTap: _nextWord,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final hasImage = _currentWordIndex < widget.level.imagePaths.length;
                        final hasWord = _currentWordIndex < widget.level.words.length;
                        final wordText = hasWord ? widget.level.words[_currentWordIndex] : '';

                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_countdownActive)
                                Text(
                                  _countdownSeconds.toString(),
                                  style: const TextStyle(
                                    fontSize: 100,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                )
                              else if (!hasImage && hasWord)
                              // Word-only layout (big and centered)
                                Text(
                                  wordText,
                                  style: const TextStyle(
                                    fontSize: 72,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              else if (hasImage || hasWord)
                                // Word + Image layout
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (hasImage)
                                        Flexible(
                                          child: Image.asset(
                                            widget.level.imagePaths[_currentWordIndex],
                                            fit: BoxFit.contain,
                                            height: constraints.maxHeight * 0.4,
                                          ),
                                        ),
                                      if (hasWord)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 16.0),
                                          child: Text(
                                            wordText,
                                            style: const TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                    ],
                                  ),
                              const SizedBox(height: 24),
                              Text(
                                'Correct Guesses: $_corrctWords',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() {}),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => setState(() {}),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 30,
                left: 16,
                child: FilledButton(
                  onPressed: () => GoRouter.of(context).go('/play'),
                  child: const Icon(Icons.arrow_back),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    _formatTime(_remainingSeconds),
                    style: const TextStyle(fontSize: 24, color: Colors.red),
                  ),
                ),
              ),
              if (_duringCelebration)
                const Positioned.fill(
                  child: IgnorePointer(child: Confetti(isStopped: false)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '$minutes:${remaining.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _playerWon();
      }
    });
  }

  Future<void> _playerWon() async {
    _log.info('Level ${widget.level.number} won');

    final score = Score(
      widget.level.number,
      _corrctWords,
      DateTime.now().difference(_startOfPlay),
    );

    context.read<PlayerProgress>().setLevelReached(widget.level.number);

    await Future.delayed(_preCelebrationDuration);
    if (!mounted) return;

    setState(() => _duringCelebration = true);
    context.read<AudioController>().playSfx(SfxType.over);

    final gamesServices = context.read<GamesServicesController?>();
    if (gamesServices != null && widget.level.awardsAchievement) {
      await gamesServices.awardAchievement(
        android: widget.level.achievementIdAndroid!,
        iOS: widget.level.achievementIdIOS!,
      );
      await gamesServices.submitLeaderboardScore(score);
    }

    await Future.delayed(_celebrationDuration);
    if (!mounted) return;

    GoRouter.of(context).go('/play/won', extra: {'score': score});
  }
}
