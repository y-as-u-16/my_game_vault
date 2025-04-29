import 'package:flutter/material.dart';

class MemoryCardConstants {
  // テーマの定義
  static const List<MemoryCardTheme> themes = [
    MemoryCardTheme(
      name: '動物',
      iconPairs: [
        Icons.pets,         // ペット
        Icons.bug_report,   // 虫
        Icons.catching_pokemon, // ポケモン風
        Icons.emoji_nature, // 植物
        Icons.back_hand,    // 手
        Icons.cruelty_free, // 動物フリー
        Icons.egg_alt,      // 卵
        Icons.all_inclusive, // 無限
        Icons.attractions,  // アトラクション
        Icons.umbrella,     // 傘
        Icons.park,         // 公園
        Icons.water,        // 水
      ],
    ),
    MemoryCardTheme(
      name: '食べ物',
      iconPairs: [
        Icons.lunch_dining,     // ランチ
        Icons.breakfast_dining, // 朝食
        Icons.dinner_dining,    // 夕食
        Icons.local_pizza,      // ピザ
        Icons.local_cafe,       // カフェ
        Icons.emoji_food_beverage, // 食べ物
        Icons.icecream,         // アイスクリーム
        Icons.fastfood,         // ファストフード
        Icons.cake,             // ケーキ
        Icons.coffee,           // コーヒー
        Icons.local_bar,        // バー
        Icons.set_meal,         // 食事
      ],
    ),
    MemoryCardTheme(
      name: '交通',
      iconPairs: [
        Icons.directions_car,    // 車
        Icons.directions_bike,   // バイク
        Icons.directions_boat,   // ボート
        Icons.directions_bus,    // バス
        Icons.directions_railway, // 鉄道
        Icons.directions_subway, // 地下鉄
        Icons.flight,            // 飛行機
        Icons.local_shipping,    // 配送
        Icons.motorcycle,        // オートバイ
        Icons.airport_shuttle,   // シャトル
        Icons.pedal_bike,        // 自転車
        Icons.sailing,           // ヨット
      ],
    ),
  ];

  // 難易度の定義
  static const Map<DifficultyLevel, DifficultySettings> difficultySettings = {
    DifficultyLevel.easy: DifficultySettings(
      gridSize: 4,
      pairCount: 8,
      timeLimit: 60,  // 1分
    ),
    DifficultyLevel.medium: DifficultySettings(
      gridSize: 6,
      pairCount: 18,
      timeLimit: 120, // 2分
    ),
    DifficultyLevel.hard: DifficultySettings(
      gridSize: 8,
      pairCount: 32,
      timeLimit: 180, // 3分
    ),
  };

  // カードの色設定
  static const Color cardBackColor = Color(0xFF0F3460);
  static const Color cardFrontColor = Color(0xFF1A1A2E);
  static const Color cardMatchedColor = Color(0xFF10B981); // マッチした時の色
  static const Color iconColor = Color(0xFFE94560);
  static const List<Color> gradientColors = [
    Color(0xFF533483),
    Color(0xFF0F3460),
  ];
}

class MemoryCardTheme {
  final String name;
  final List<IconData> iconPairs;

  const MemoryCardTheme({
    required this.name,
    required this.iconPairs,
  });
}

class DifficultySettings {
  final int gridSize;  // グリッドの辺の長さ (4x4, 6x6, 8x8)
  final int pairCount; // 必要なペアの数 (8, 18, 32)
  final int timeLimit; // 制限時間（秒）

  const DifficultySettings({
    required this.gridSize,
    required this.pairCount,
    required this.timeLimit,
  });
}

enum DifficultyLevel {
  easy,
  medium,
  hard,
}

enum CardState {
  hidden,  // カードが裏向き
  revealed, // カードが表向き
  matched,  // カードがマッチした
}
