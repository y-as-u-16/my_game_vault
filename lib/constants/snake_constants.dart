import 'package:flutter/material.dart';

class SnakeConstants {
  // ゲームボードのサイズ
  static const int rowCount = 20;
  static const int colCount = 20;

  // ゲーム速度
  static const Duration initialGameSpeed = Duration(milliseconds: 300);

  // スネークの色
  static const Color snakeHeadColor = Color(0xFF4CAF50);
  static const Color snakeBodyColor = Color(0xFF8BC34A);

  // 餌の色
  static const Color foodColor = Color(0xFFE94560);

  // 障害物の色
  static const Color obstacleColor = Color(0xFF607D8B);

  // 方向
  static const int up = 0;
  static const int right = 1;
  static const int down = 2;
  static const int left = 3;
}
