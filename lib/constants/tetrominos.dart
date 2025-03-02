import 'package:flutter/material.dart';

class Tetrominos {
  // テトロミノの形状定義
  static const List<List<List<int>>> shapes = [
    // I形
    [
      [1, 1, 1, 1],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    // O形
    [
      [1, 1],
      [1, 1],
    ],
    // T形
    [
      [0, 1, 0],
      [1, 1, 1],
      [0, 0, 0],
    ],
    // L形
    [
      [1, 0, 0],
      [1, 1, 1],
      [0, 0, 0],
    ],
    // J形
    [
      [0, 0, 1],
      [1, 1, 1],
      [0, 0, 0],
    ],
    // S形
    [
      [0, 1, 1],
      [1, 1, 0],
      [0, 0, 0],
    ],
    // Z形
    [
      [1, 1, 0],
      [0, 1, 1],
      [0, 0, 0],
    ],
  ];

  // テトロミノの色定義
  static const List<Color> colors = [
    Color(0xFF00CED1), // I - ターコイズ
    Color(0xFFFFD700), // O - ゴールド
    Color(0xFF9370DB), // T - ミディアムパープル
    Color(0xFFFF8C00), // L - ダークオレンジ
    Color(0xFF1E90FF), // J - ドジャーブルー
    Color(0xFF32CD32), // S - ライムグリーン
    Color(0xFFFF4500), // Z - オレンジレッド
  ];
}
