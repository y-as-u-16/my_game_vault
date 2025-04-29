import 'package:flutter/material.dart';
import '../constants/breakout_constants.dart';
import 'dart:math';

class Block {
  final Rect rect;
  final Color color;
  bool isVisible;

  Block({required this.rect, required this.color, this.isVisible = true});
}

class BreakoutGameState {
  late Rect paddle;
  late Offset ballPosition;
  late Offset ballDirection;
  late double ballSpeed;
  List<Block> blocks = [];
  int score = 0;
  bool isGameOver = false;
  bool hasGameStarted = false;

  BreakoutGameState(
      {required double screenWidth, required double screenHeight}) {
    // パドルの初期位置
    double paddleX = (screenWidth - paddleWidth) / 2;
    double paddleY = screenHeight - paddleHeight - 20;
    paddle = Rect.fromLTWH(paddleX, paddleY, paddleWidth, paddleHeight);

    // ボールの初期位置
    ballPosition = Offset(
      screenWidth / 2,
      screenHeight - paddleHeight - 30 - ballRadius,
    );

    // ボールの初期方向（上向き）
        ballDirection = _normalizeOffset(Offset(0.5, -1.0));
    ballSpeed = initialBallSpeed;

    // ブロックの生成
    _generateBlocks(screenWidth);
  }

  void _generateBlocks(double screenWidth) {
    Random random = Random();
    int rows = 5;
    int blocksPerRow = (screenWidth / (blockWidth + 10)).floor();
    double startX = (screenWidth - (blocksPerRow * (blockWidth + 10))) / 2 + 5;
    double startY = 50.0;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < blocksPerRow; col++) {
        double x = startX + col * (blockWidth + 10);
        double y = startY + row * (blockHeight + 10);
        Color color = blockColors[random.nextInt(blockColors.length)];
        blocks.add(
          Block(
            rect: Rect.fromLTWH(x, y, blockWidth, blockHeight),
            color: color,
          ),
        );
      }
    }
  }

  void startGame() {
    hasGameStarted = true;
  }

  void resetGame({required double screenWidth, required double screenHeight}) {
    double paddleX = (screenWidth - paddleWidth) / 2;
    double paddleY = screenHeight - paddleHeight - 20;
    paddle = Rect.fromLTWH(paddleX, paddleY, paddleWidth, paddleHeight);

    ballPosition = Offset(
      screenWidth / 2,
      screenHeight - paddleHeight - 30 - ballRadius,
    );

        ballDirection = _normalizeOffset(Offset(0.5, -1.0));
    ballSpeed = initialBallSpeed;

    blocks.clear();
    _generateBlocks(screenWidth);
    score = 0;
    isGameOver = false;
    hasGameStarted = false;
  }

  void updatePaddlePosition(double dx, double screenWidth) {
    double newX = paddle.left + dx;
    if (newX < 0) {
      newX = 0;
    } else if (newX + paddleWidth > screenWidth) {
      newX = screenWidth - paddleWidth;
    }
    paddle = Rect.fromLTWH(newX, paddle.top, paddleWidth, paddleHeight);
  }

  void update(Size screenSize) {
    if (!hasGameStarted || isGameOver) return;

    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    // ボールの移動
    ballPosition += ballDirection * ballSpeed;

    // 壁との衝突検出
    if (ballPosition.dx <= ballRadius ||
        ballPosition.dx >= screenWidth - ballRadius) {
      ballDirection = Offset(-ballDirection.dx, ballDirection.dy);
    }
    if (ballPosition.dy <= ballRadius) {
      ballDirection = Offset(ballDirection.dx, -ballDirection.dy);
    }

    // パドルとの衝突検出
    if (ballPosition.dy >= paddle.top - ballRadius &&
        ballPosition.dy <= paddle.bottom &&
        ballPosition.dx >= paddle.left &&
        ballPosition.dx <= paddle.right) {
      // パドルの中心からの距離に基づいて跳ね返り角度を計算
      double hitPoint = (ballPosition.dx - (paddle.left + paddleWidth / 2)) /
          (paddleWidth / 2);
            ballDirection = _normalizeOffset(Offset(hitPoint, -1));
    }

    // ブロックとの衝突検出
    for (int i = 0; i < blocks.length; i++) {
      if (blocks[i].isVisible) {
        Rect blockRect = blocks[i].rect;
        if (_checkBallBlockCollision(blockRect)) {
          blocks[i] = Block(
            rect: blockRect,
            color: blocks[i].color,
            isVisible: false,
          );
          score += 10;

          // ブロックとの衝突時の跳ね返り方向を決定
          double overlapLeft = ballPosition.dx + ballRadius - blockRect.left;
          double overlapRight =
              blockRect.right - (ballPosition.dx - ballRadius);
          double overlapTop = ballPosition.dy + ballRadius - blockRect.top;
          double overlapBottom =
              blockRect.bottom - (ballPosition.dy - ballRadius);

          bool fromLeft = overlapLeft < overlapRight;
          bool fromTop = overlapTop < overlapBottom;

          double minXOverlap = fromLeft ? overlapLeft : overlapRight;
          double minYOverlap = fromTop ? overlapTop : overlapBottom;

          if (minXOverlap < minYOverlap) {
            ballDirection = Offset(-ballDirection.dx, ballDirection.dy);
          } else {
            ballDirection = Offset(ballDirection.dx, -ballDirection.dy);
          }
          break;
        }
      }
    }

    // 画面下に落ちた場合
    if (ballPosition.dy >= screenHeight) {
      isGameOver = true;
    }

    // すべてのブロックが破壊されたかチェック
    bool allBlocksDestroyed = true;
    for (Block block in blocks) {
      if (block.isVisible) {
        allBlocksDestroyed = false;
        break;
      }
    }

    // すべてのブロックが破壊された場合、新しいレベルを生成
    if (allBlocksDestroyed) {
      _generateBlocks(screenWidth);
      ballSpeed += 0.5; // 速度を少し上げる
    }
  }

  bool _checkBallBlockCollision(Rect blockRect) {
    // 円と矩形の衝突判定
    double closestX = ballPosition.dx.clamp(blockRect.left, blockRect.right);
    double closestY = ballPosition.dy.clamp(blockRect.top, blockRect.bottom);
    double distanceX = ballPosition.dx - closestX;
    double distanceY = ballPosition.dy - closestY;
    double distanceSquared = distanceX * distanceX + distanceY * distanceY;
    return distanceSquared <= (ballRadius * ballRadius);
  }

  Offset _normalizeOffset(Offset offset) {
    double length = sqrt(offset.dx * offset.dx + offset.dy * offset.dy);
    return Offset(offset.dx / length, offset.dy / length);
  }
}
