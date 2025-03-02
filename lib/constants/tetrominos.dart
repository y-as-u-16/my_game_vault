import 'package:flutter/material.dart';
import 'colors.dart';

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
    AppColors.tetrisI, // I - ターコイズ
    AppColors.tetrisO, // O - ゴールド
    AppColors.tetrisT, // T - ミディアムパープル
    AppColors.tetrisL, // L - ダークオレンジ
    AppColors.tetrisJ, // J - ドジャーブルー
    AppColors.tetrisS, // S - ライムグリーン
    AppColors.tetrisZ, // Z - オレンジレッド
  ];
}
