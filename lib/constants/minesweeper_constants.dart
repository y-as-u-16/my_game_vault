// マインスイーパー用の定数
import 'package:flutter/material.dart';

// ゲーム難易度
enum DifficultyLevel {
  easy, // 9x9, 10マイン
  medium, // 16x16, 40マイン
  hard, // 24x24, 99マイン
}

// 難易度ごとの設定
class DifficultySettings {
  final int rows;
  final int columns;
  final int mines;

  const DifficultySettings({
    required this.rows,
    required this.columns,
    required this.mines,
  });

  static const Map<DifficultyLevel, DifficultySettings> difficultyMap = {
    DifficultyLevel.easy: DifficultySettings(rows: 9, columns: 9, mines: 10),
    DifficultyLevel.medium: DifficultySettings(rows: 16, columns: 16, mines: 40),
    DifficultyLevel.hard: DifficultySettings(rows: 24, columns: 24, mines: 99),
  };
}

// セルの状態
enum CellState {
  covered, // 覆われている
  flagged, // フラグが立てられている
  questioned, // ?マーク
  revealed, // 開かれている
}

// セルの内容
enum CellContent {
  empty, // 空（周囲に地雷なし）
  number, // 数字（周囲の地雷数）
  mine, // 地雷
}

// マインスイーパーの色
const Color coveredCellColor = Color(0xFF4D4D70);
const Color revealedCellColor = Color(0xFF2B2B3D);
const Color mineColor = Color(0xFFE94560);
const Color flagColor = Color(0xFFED8936);
const Color questionColor = Color(0xFF38B2AC);

// 数字の色
const List<Color> numberColors = [
  Color(0xFF6B7280), // 0: グレー（使わない）
  Color(0xFF3B82F6), // 1: 青
  Color(0xFF10B981), // 2: 緑
  Color(0xFFEF4444), // 3: 赤
  Color(0xFF6366F1), // 4: 紫
  Color(0xFFB91C1C), // 5: 濃い赤
  Color(0xFF0EA5E9), // 6: 水色
  Color(0xFF4B5563), // 7: 暗いグレー
  Color(0xFF64748B), // 8: 暗い青グレー
];
