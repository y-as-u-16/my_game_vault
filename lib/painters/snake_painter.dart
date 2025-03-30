import 'package:flutter/material.dart';
import 'dart:math';

import 'package:game_vault/constants/snake_constants.dart';

// スネークゲームボードの描画
class SnakePainter extends CustomPainter {
  final List<Point<int>> snake;
  final Point<int>? food;
  final List<Point<int>> obstacles;
  final int rowCount;
  final int colCount;

  SnakePainter({
    required this.snake,
    required this.food,
    required this.obstacles,
    required this.rowCount,
    required this.colCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cellWidth = size.width / colCount;
    final double cellHeight = size.height / rowCount;

    // 背景のグリッド線を描画
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int r = 0; r <= rowCount; r++) {
      canvas.drawLine(
        Offset(0, r * cellHeight),
        Offset(size.width, r * cellHeight),
        gridPaint,
      );
    }

    for (int c = 0; c <= colCount; c++) {
      canvas.drawLine(
        Offset(c * cellWidth, 0),
        Offset(c * cellWidth, size.height),
        gridPaint,
      );
    }

    // 障害物の描画
    for (var obstacle in obstacles) {
      final rect = Rect.fromLTWH(
        obstacle.x * cellWidth + 1,
        obstacle.y * cellHeight + 1,
        cellWidth - 2,
        cellHeight - 2,
      );

      final RRect roundedRect =
          RRect.fromRectAndRadius(rect, const Radius.circular(2.0));

      // グラデーションで立体感を出す
      final obstaclePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SnakeConstants.obstacleColor.withOpacity(1.0),
            SnakeConstants.obstacleColor.withOpacity(0.7),
          ],
        ).createShader(rect);

      canvas.drawRRect(roundedRect, obstaclePaint);

      // 境界線
      final borderPaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawRRect(roundedRect, borderPaint);
    }

    // 餌の描画
    if (food != null) {
      final rect = Rect.fromLTWH(
        food!.x * cellWidth + 1,
        food!.y * cellHeight + 1,
        cellWidth - 2,
        cellHeight - 2,
      );

      // 円形の餌
      final foodPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            SnakeConstants.foodColor,
            SnakeConstants.foodColor.withOpacity(0.7),
          ],
        ).createShader(rect);

      canvas.drawCircle(
        rect.center,
        rect.width / 2.2,
        foodPaint,
      );

      // 光沢効果
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(
            rect.center.dx - rect.width / 6, rect.center.dy - rect.height / 6),
        rect.width / 6,
        highlightPaint,
      );
    }

    // スネークの描画（体から描画して頭を最後に）
    for (int i = snake.length - 1; i >= 0; i--) {
      final segment = snake[i];
      final rect = Rect.fromLTWH(
        segment.x * cellWidth + 1,
        segment.y * cellHeight + 1,
        cellWidth - 2,
        cellHeight - 2,
      );

      final RRect roundedRect =
          RRect.fromRectAndRadius(rect, const Radius.circular(4.0));

      // 頭と体で色を変える
      final Color segmentColor = i == 0
          ? SnakeConstants.snakeHeadColor
          : SnakeConstants.snakeBodyColor;

      // グラデーションで立体感を出す
      final segmentPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            segmentColor.withOpacity(1.0),
            segmentColor.withOpacity(0.7),
          ],
        ).createShader(rect);

      canvas.drawRRect(roundedRect, segmentPaint);

      // ハイライト（上部と左側に光沢）
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final Path highlightPath = Path()
        ..moveTo(rect.left + 2, rect.bottom - 2)
        ..lineTo(rect.left + 2, rect.top + 2)
        ..lineTo(rect.right - 2, rect.top + 2);

      canvas.drawPath(highlightPath, highlightPaint);

      // 境界線
      final borderPaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawRRect(roundedRect, borderPaint);

      // スネークの頭には目を追加
      if (i == 0) {
        // 目の位置を決定（方向に応じて変える場合はここで調整）
        final leftEyeX = rect.left + rect.width * 0.3;
        final rightEyeX = rect.left + rect.width * 0.7;
        final eyeY = rect.top + rect.height * 0.4;
        final eyeRadius = rect.width * 0.12;

        // 目を描画
        final eyePaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(leftEyeX, eyeY),
          eyeRadius,
          eyePaint,
        );
        canvas.drawCircle(
          Offset(rightEyeX, eyeY),
          eyeRadius,
          eyePaint,
        );

        // 瞳を描画
        final pupilPaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(leftEyeX, eyeY),
          eyeRadius / 2,
          pupilPaint,
        );
        canvas.drawCircle(
          Offset(rightEyeX, eyeY),
          eyeRadius / 2,
          pupilPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(SnakePainter oldDelegate) {
    return true;
  }
}
