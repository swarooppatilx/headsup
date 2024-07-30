import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this package for SystemChrome
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart'; // Import the sensors_plus package

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

  late DateTime _startOfPlay;
  int _currentWordIndex = 0;
  int _corrctWords = 0;
  double _fontSize = 120;

  Timer? _timer;
  int _remainingSeconds = 90;

  // ignore: unused_field
  List<AccelerometerEvent> _accelerometerValues = [];
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  @override
  void initState() {
    super.initState();

    _startOfPlay = DateTime.now();
    _startTimer();

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

    // Subscribe to accelerometer events
    // ignore: deprecated_member_use
    bool _actionInProgress = false;

// Subscribe to accelerometer events
// ignore: deprecated_member_use
    _accelerometerSubscription = accelerometerEvents.listen((event) async {
      if (!_actionInProgress) {
        if (event.z > 8) {
          _nextWord();
          _actionInProgress = true;
          await Future.delayed(Duration(seconds: 1));
          _actionInProgress = false;
        } else if (event.z < -7) {
          _nextWordAndCount();
          _actionInProgress = true;
          await Future.delayed(Duration(seconds: 1));
          _actionInProgress = false;
        }
      }
    });
  }

  @override
  void dispose() {
    // Cancel the timer if it's still running
    _timer?.cancel();

    // Cancel the accelerometer event subscription to prevent memory leaks
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
        ignoring: _duringCelebration,
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
                            Text(
                              widget.level.words[_currentWordIndex],
                              style: TextStyle(
                                fontSize: _fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Correct words: $_corrctWords'),
                            SizedBox(height: 20),
                            // Text(
                            //   'Accelerometer Data:',
                            //   style: TextStyle(fontSize: 20),
                            // ),
                            // SizedBox(height: 10),
                            // if (_accelerometerValues.isNotEmpty)
                            //   Text(
                            //     'X: ${_accelerometerValues[0].x.toStringAsFixed(2)}, '
                            //     'Y: ${_accelerometerValues[0].y.toStringAsFixed(2)}, '
                            //     'Z: ${_accelerometerValues[0].z.toStringAsFixed(2)}',
                            //     style: TextStyle(fontSize: 16),
                            //   )
                            // else
                            //   Text(
                            //     'No data available',
                            //     style: TextStyle(fontSize: 16),
                            //   ),
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

    // Let the player see the game just after winning for a bit.
    await Future<void>.delayed(_preCelebrationDuration);
    if (!mounted) return;

    setState(() {
      _duringCelebration = true;
    });

    // final audioController = context.read<AudioController>();
    // audioController.playSfx(SfxType.congrats);

    final gamesServicesController = context.read<GamesServicesController?>();
    if (gamesServicesController != null) {
      // Award achievement.
      if (widget.level.awardsAchievement) {
        await gamesServicesController.awardAchievement(
          android: widget.level.achievementIdAndroid!,
          iOS: widget.level.achievementIdIOS!,
        );
      }

      // Send score to leaderboard.
      await gamesServicesController.submitLeaderboardScore(score);
    }

    // Give the player some time to see the celebration animation.
    await Future<void>.delayed(_celebrationDuration);
    if (!mounted) return;

    GoRouter.of(context).go('/play/won', extra: {'score': score});
  }
}
