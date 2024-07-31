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
      'Paneer chilli',
      'Cold',
      'ParleG',
      'Proxy',
      'Clock',
      'OAT',
      'Sai Pallavi',
      'Submission'
    ],
  ),
  Team(
    number: 2,
    difficulty: 100,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
    words: [
      'Shinchan',
      'Cheat',
      'Alacrity',
      'Noodles',
      'Chai',
      'Salman khan',
      'Resume',
      'Roll no 21',
      'Super Man'
    ],
  ),
  Team(
    number: 3,
    difficulty: 100,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
    words: [
      'Biryani',
      'Projects',
      'Vijay Devarkonda',
      'Chaat',
      'Eraser',
      'Tree',
      'Paneer chilli',
      'Star',
      'Music'
    ],
  ),
  Team(
    number: 4,
    difficulty: 100,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
    words: [
      'Phone',
      'Alia Bhatt',
      'Pasta',
      'Defaulter',
      'Sushi',
      'Bunk',
      'Knot',
      'Bunksheets',
      'Kiteratasu'
    ],
  ),
  Team(
    number: 5,
    difficulty: 100,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
    words: [
      'Pani puri',
      'Mr Bean',
      'ACM committee',
      'ID card',
      'Coffee',
      'Chota Bheem',
      'Trampoline',
      'Perman',
      'Ajay Devgan'
    ],
  ),
  Team(
    number: 6,
    difficulty: 100,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
    words: [
      'Amitabh Bachchan',
      'Shahrukh khan',
      'Year down/ Drop',
      'Bit by bit',
      'Cheese Cake',
      'Siddhart Malhotra',
      'Ben 10',
      'Backlog',
      'Batman'
    ],
  ),
  Team(
    number: 7,
    difficulty: 100,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
    words: [
      'Hackathon',
      'Garlic bread',
      'Shahrukh khan',
      'Pasta',
      'Vicky Kaushal',
      'Wheel',
      'Defaulter',
      'Kareena Kapoor',
      'Spongebob'
    ],
  ),
  Team(
    number: 8,
    difficulty: 100,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
    words: [
      'Timer',
      'Music',
      'Proxy',
      'Projects',
      'Pizza',
      'Vijay thalapati',
      'Submission',
      'ID card',
      'Tree'
    ],
  ),
  Team(
    number: 9,
    difficulty: 100,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
    words: [
      'OAT',
      'Babu bhaiya',
      'Paneer chilli',
      'Rashmika Mandana',
      'Roll no 21',
      'Hackathon',
      'Cold',
      'ParleG',
      'Eraser'
    ],
  ),
  Team(
    number: 10,
    difficulty: 100,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
    words: [
      'Siddhart Malhotra',
      'Year down/ Drop',
      'Garlic bread',
      'Clock',
      'Chota Bheem',
      'Biryani',
      'Roll no 21',
      'Kareena Kapoor',
      'Tree'
    ],
  ),
  Team(
    number: 11,
    difficulty: 100,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
    words: [
      'Shinchan',
      'Timer',
      'Wheel',
      'Proxy',
      'Music',
      'Alacrity',
      'Super Man',
      'Spongebob',
      'Trampoline'
    ],
  ),
  Team(
    number: 12,
    difficulty: 100,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
    words: [
      'Paneer chilli',
      'Spongebob',
      'Cold',
      'ParleG',
      'Tree',
      'Batman',
      'Phone',
      'Cheat',
      'Bunk'
    ],
  ),
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
