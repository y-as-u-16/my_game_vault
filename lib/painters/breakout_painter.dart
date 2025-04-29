import 'package:flutter/material.dart';
import '../models/breakout_game_state.dart';
import '../constants/breakout_constants.dart';

class BreakoutPainter extends CustomPainter {
  final BreakoutGameState gameState;

  BreakoutPainter(this.gameState);

  @override
  void paint(Canvas canvas, Size size) {
    // 背景
    final backgroundPaint = Paint()
      ..color = const Color(0xFF16213E);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // パドル
    final paddlePaint = Paint()
      ..color = paddleColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(gameState.paddle, const Radius.circular(10)),
      paddlePaint,
    );

    // ブロック
    for (var block in gameState.blocks) {
      if (block.isVisible) {
        final blockPaint = Paint()
          ..color = block.color
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(block.rect, const Radius.circular(5)),
          blockPaint,
        );

        // ブロックの枠線
        final borderPaint = Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawRRect(
          RRect.fromRectAndRadius(block.rect, const Radius.circular(5)),
          borderPaint,
        );
      }
    }

    // ボール
    final ballPaint = Paint()
      ..color = ballColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(gameState.ballPosition, ballRadius, ballPaint);

    // スコア表示
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: 'スコア: ${gameState.score}',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, 10));

    // ゲームオーバー表示
    if (gameState.isGameOver) {
      const gameOverTextStyle = TextStyle(
        color: Colors.white,
        fontSize: 50,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            blurRadius: 10.0,
            color: Colors.black,
            offset: Offset(2.0, 2.0),
          ),
        ],
      );
      const gameOverTextSpan = TextSpan(
        text: 'ゲームオーバー',
        style: gameOverTextStyle,
      );
      final gameOverTextPainter = TextPainter(
        text: gameOverTextSpan,
        textDirection: TextDirection.ltr,
      );
      gameOverTextPainter.layout();
      gameOverTextPainter.paint(
        canvas,
        Offset(
          (size.width - gameOverTextPainter.width) / 2,
          (size.height - gameOverTextPainter.height) / 2,
        ),
      );
    }

    // 開始前の表示
    if (!gameState.hasGameStarted && !gameState.isGameOver) {
      const startTextStyle = TextStyle(
        color: Colors.white,
        fontSize: 30,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            blurRadius: 10.0,
            color: Colors.black,
            offset: Offset(2.0, 2.0),
          ),
        ],
      );
      const startTextSpan = TextSpan(
        text: 'タップしてスタート',
        style: startTextStyle,
      );
      final startTextPainter = TextPainter(
        text: startTextSpan,
        textDirection: TextDirection.ltr,
      );
      startTextPainter.layout();
      startTextPainter.paint(
        canvas,
        Offset(
          (size.width - startTextPainter.width) / 2,
          (size.height - startTextPainter.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(BreakoutPainter oldDelegate) {
    return true; // 常に再描画
  }
}
