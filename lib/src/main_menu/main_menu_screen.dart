// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
// import '../games_services/games_services.dart';
// import '../settings/settings.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    // final gamesServicesController = context.watch<GamesServicesController?>();
    // final settingsController = context.watch<SettingsController>();
    final audioController = context.watch<AudioController>();

    return Scaffold(
      backgroundColor: palette.backgroundMain,
      body: ResponsiveScreen(
        mainAreaProminence: 0.45,
        squarishMainArea: Center(
          child: Transform.rotate(
            angle: 0,
            child: const Text(
              'HeadsUP ACM',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Permanent Marker',
                  fontSize: 80,
                  height: 1,
                  color: Colors.white),
            ),
          ),
        ),
        rectangularMenuArea: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue[300],
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildButton(
                  'Play',
                  () {
                    audioController.playSfx(SfxType.buttonTap);
                    GoRouter.of(context).go('/play');
                  },
                ),
                const SizedBox(height: 20),
                _buildButton(
                  'Settings',
                  () => GoRouter.of(context).push('/settings'),
                ),
                const SizedBox(height: 30),
                RichText(
                  text: TextSpan(
                    text: 'Made by ',
                    style: TextStyle(
                        color: Colors.grey.shade100,
                        fontSize: 16.0), // Set default text color and size
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Aditya Godse',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0), // URL text color and size
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse('https://adimail.github.io'));
                          },
                      ),
                      TextSpan(
                        text: ' for ACM IOIT',
                        style: TextStyle(
                            color: Colors.grey.shade100,
                            fontSize: 16.0), // Default text color and size
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          iconColor: Colors.teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  /// Prevents the game from showing game-services-related menu items
  /// until we're sure the player is signed in.
  ///
  /// This normally happens immediately after game start, so players will not
  /// see any flash. The exception is folks who decline to use Game Center
  /// or Google Play Game Services, or who haven't yet set it up.
  Widget _hideUntilReady({required Widget child, required Future<bool> ready}) {
    return FutureBuilder<bool>(
      future: ready,
      builder: (context, snapshot) {
        // Use Visibility here so that we have the space for the buttons
        // ready.
        return Visibility(
          visible: snapshot.data ?? false,
          maintainState: true,
          maintainSize: true,
          maintainAnimation: true,
          child: child,
        );
      },
    );
  }
}
