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
        'Submission',
        'Proxy',
        'Bunk',
        'Alacrity',
        'Placement',
        'Projects',
        'Resume',
        'Defaulter',
        'ACM committee',
        'Bunksheets'
      ]),
  Team(
      number: 2,
      difficulty: 100,
      achievementIdIOS: 'finished',
      achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
      words: [
        'OAT',
        'Hackathon',
        'Bit by bit',
        'ID card',
        'Backlog',
        'Year down/ Drop',
        'Maggi',
        'Biryani',
        'Pizza',
        'Garlic bread'
      ]),
  Team(
      number: 3,
      difficulty: 100,
      achievementIdIOS: 'finished',
      achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
      words: [
        'Chaat',
        'Sushi',
        'Noodles',
        'Coffee',
        'Paneer chilli',
        'Pani puri',
        'Chai',
        'ParleG',
        'Cheese Cake',
        'Pasta'
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
        'Star'
      ]),
  Team(
      number: 5,
      difficulty: 100,
      achievementIdIOS: 'finished',
      achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
      words: [
        'Knot',
        'Wheel',
        'Music',
        'Trampoline',
        'Amitabh Bachchan',
        'Shahrukh khan',
        'Jackie Shroff',
        'Kareena Kapoor',
        'Salman khan',
        'Kishore Kumar'
      ]),
  Team(
      number: 6,
      difficulty: 100,
      achievementIdIOS: 'finished',
      achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
      words: [
        'Alia Bhatt',
        'Vicky Kaushal',
        'Siddhart Malhotra',
        'Ajay Devgan',
        'Rashmika Mandana',
        'Vijay Devarkonda',
        'Vijay thalapati',
        'Sai Pallavi',
        'Submission',
        'Proxy'
      ]),
  Team(
      number: 7,
      difficulty: 100,
      achievementIdIOS: 'finished',
      achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
      words: [
        'Bunk',
        'Alacrity',
        'Placement',
        'Projects',
        'Resume',
        'Defaulter',
        'ACM committee',
        'Bunksheets',
        'OAT',
        'Hackathon'
      ]),
  Team(
      number: 8,
      difficulty: 100,
      achievementIdIOS: 'finished',
      achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
      words: [
        'Bit by bit',
        'ID card',
        'Backlog',
        'Year down/ Drop',
        'Maggi',
        'Biryani',
        'Pizza',
        'Garlic bread',
        'Chaat',
        'Sushi'
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
