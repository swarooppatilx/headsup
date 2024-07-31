// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

const teams = [
  Team(
      number: 1,
      difficulty: 5,
      achievementIdIOS: 'first_win',
      achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',
      words: [
        'Pizza',
        'Key',
        'Proxy',
        'Alacrity',
        'Salman khan',
        'Knot',
        'Cheat',
        'Timer',
        'Vijay Devarkonda',
        'Resume',
        'Maggi',
        'Paneer chilli',
        'Pasta',
        'Vicky Kaushal',
        'Phone',
        'Tree',
        'Submission',
        'ParleG',
        'Sushi',
        'ACM committee'
      ]),
  Team(
      number: 2,
      difficulty: 100,
      achievementIdIOS: 'finished',
      achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
      words: [
        'Hackathon',
        'Eraser',
        'Bit by bit',
        'Shahrukh khan',
        'Chair',
        'Garlic bread',
        'Cold',
        'Placement',
        'Clock',
        'ID card',
        'Defaulter',
        'Coffee',
        'Pani puri',
        'Ajay Devgan',
        'Timer',
        'Sai Pallavi',
        'Maggi',
        'Backlog',
        'Cheese Cake',
        'Projects'
      ]),
  Team(
      number: 3,
      difficulty: 100,
      achievementIdIOS: 'finished',
      achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
      words: [
        'Chai',
        'Biryani',
        'Jackie Shroff',
        'Bunk',
        'Amitabh Bachchan',
        'OAT',
        'Bunksheets',
        'Vijay thalapati',
        'Alia Bhatt',
        'Noodles',
        'ParleG',
        'Trampoline',
        'Cheat',
        'Kareena Kapoor',
        'Kishore Kumar',
        'Bit by bit',
        'Year down/ Drop',
        'Timer',
        'Chaat',
        'Clock'
      ]),
  Team(
      number: 4,
      difficulty: 100,
      achievementIdIOS: 'finished',
      achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
      words: [
        'Tree',
        'Eraser',
        'Chair',
        'Key',
        'Cheat',
        'Phone',
        'Cold',
        'Timer',
        'Clock',
        'Star',
        'Knot',
        'Wheel',
        'Music',
        'Trampoline',
        'Rashmika Mandana',
        'Vicky Kaushal',
        'Sai Pallavi',
        'Shahrukh khan',
        'Vijay Devarkonda',
        'Salman khan'
      ]),
];

class Team {
  final int number;

  final int difficulty;

  /// The list of words associated with the team.
  final List<String> words;

  /// The achievement to unlock when the level is finished, if any.
  final String? achievementIdIOS;

  final String? achievementIdAndroid;

  bool get awardsAchievement => achievementIdAndroid != null;

  const Team({
    required this.number,
    required this.difficulty,
    required this.words,
    this.achievementIdIOS,
    this.achievementIdAndroid,
  }) : assert(
            (achievementIdAndroid != null && achievementIdIOS != null) ||
                (achievementIdAndroid == null && achievementIdIOS == null),
            'Either both iOS and Android achievement ID must be provided, '
            'or none');
}
