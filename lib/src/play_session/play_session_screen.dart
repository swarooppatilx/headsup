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
  double _fontSize = 120;

  Timer? _timer;
  int _remainingSeconds = 90;

  // ignore: unused_field
  final List<AccelerometerEvent> _accelerometerValues = [];
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  @override
  void initState() {
    super.initState();

    _startCountdown();

    // Preload ad for the win screen.
    final adsRemoved =
        context.read<InAppPurchaseController?>()?.adRemoval.active ?? false;
    if (!adsRemoved) {
      final adsController = context.read<AdsController?>();
      adsController?.preloadAd();
    }

    // Set preferred orientations to landscape only.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _accelerometerSubscription.cancel();

    // Reset preferred orientations to allow both landscape and portrait.
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
        setState(() {
          _countdownSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _countdownActive = false;
        });
        _startOfPlay = DateTime.now();
        _startTimer();
        _startAccelerometer();
      }
    });
  }

  void _startAccelerometer() {
    bool actionInProgress = false;

    // ignore: deprecated_member_use
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

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LevelState(
            goal: widget.level.difficulty,
            onWin: _playerWon,
          ),
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return FittedBox(
                        fit: BoxFit.contain,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            if (_countdownActive)
                              Center(
                                child: Text(
                                  _countdownSeconds.toString(),
                                  style: TextStyle(
                                    fontSize: 100,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            else
                              Text(
                                widget.level.words[_currentWordIndex],
                                style: TextStyle(
                                  fontSize: _fontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (!_countdownActive) ...[
                              Text('Correct words: $_corrctWords'),
                              SizedBox(height: 20),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: _increaseFontSize,
                    ),
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: _decreaseFontSize,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 30,
                left: 16,
                child: FilledButton(
                  onPressed: () => GoRouter.of(context).go('/play'),
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_back),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              SizedBox.expand(
                child: Visibility(
                  visible: _duringCelebration,
                  child: IgnorePointer(
                    child: Confetti(
                      isStopped: !_duringCelebration,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextWord() {
    if (_currentWordIndex < widget.level.words.length - 1) {
      setState(() {
        _currentWordIndex++;
      });
      final audioController = context.read<AudioController>();
      audioController.playSfx(SfxType.wrong);
    } else {
      _playerWon();
    }
  }

  void _nextWordAndCount() {
    if (_currentWordIndex < widget.level.words.length - 1) {
      setState(() {
        _currentWordIndex++;
        _corrctWords++;
      });

      final audioController = context.read<AudioController>();
      audioController.playSfx(SfxType.correct);
    } else {
      _playerWon();
    }
  }

  void _increaseFontSize() {
    setState(() {
      _fontSize += 10;
    });
  }

  void _decreaseFontSize() {
    setState(() {
      _fontSize = _fontSize > 2 ? _fontSize - 10 : _fontSize;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
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

    final playerProgress = context.read<PlayerProgress>();
    playerProgress.setLevelReached(widget.level.number);

    await Future<void>.delayed(_preCelebrationDuration);
    if (!mounted) return;

    setState(() {
      _duringCelebration = true;
    });

    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.over);

    final gamesServicesController = context.read<GamesServicesController?>();
    if (gamesServicesController != null) {
      if (widget.level.awardsAchievement) {
        await gamesServicesController.awardAchievement(
          android: widget.level.achievementIdAndroid!,
          iOS: widget.level.achievementIdIOS!,
        );
      }

      await gamesServicesController.submitLeaderboardScore(score);
    }

    await Future<void>.delayed(_celebrationDuration);
    if (!mounted) return;

    GoRouter.of(context).go('/play/won', extra: {'score': score});
  }
}
