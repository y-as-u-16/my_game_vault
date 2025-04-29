import 'package:flutter/material.dart';

// 数独のデザイン関連の定数
class SudokuConstants {
  // 基本色設定
  static const Color backgroundColor = Color(0xFF1A1A2E);
  static const Color gridLineColor = Color(0xFFCCCCCC);
  static const Color accentColor = Color(0xFF0F3460);
  static const Color selectedCellColor = Color(0xFF533483);
  static const Color hintColor = Color(0xFFE94560);
  static const Color defaultNumberColor = Colors.white;
  static const Color fixedNumberColor = Color(0xFFAAAAAA);
  static const Color invalidNumberColor = Color(0xFFFF6B6B);
  
  // 難易度設定
  static const Map<SudokuDifficulty, int> difficultyCellsToRemove = {
    SudokuDifficulty.easy: 30,       // 30セルを削除
    SudokuDifficulty.medium: 40,     // 40セルを削除
    SudokuDifficulty.hard: 50,       // 50セルを削除
    SudokuDifficulty.expert: 60,     // 60セルを削除
  };
  
  // 操作モード
  static const double cellSize = 40.0;
  static const double digitButtonSize = 50.0;
  static const double digitButtonFontSize = 24.0;
  static const EdgeInsets digitButtonMargin = EdgeInsets.all(4.0);
}

// 数独の難易度
enum SudokuDifficulty {
  easy,
  medium,
  hard,
  expert,
}

// 操作モード
enum InputMode {
  digit,    // 数字を入れる
  notes,    // メモを入れる
}
