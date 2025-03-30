import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:game_vault/constants/snake_constants.dart';
import 'package:game_vault/models/snake_game_state.dart';

class SnakeGameService {
  final SnakeGameState gameState;
  final Function(VoidCallback) setState;

  SnakeGameService(this.gameState, this.setState);

  // ゲームを開始する
  void startGame() {
    if (gameState.isGameStarted) return;

    setState(() {
      gameState.isGameStarted = true;

      // ゲームタイマーの開始
      gameState.gameTimer = Timer.periodic(gameState.gameSpeed, (timer) {
        moveSnake();
      });
    });
  }

  // ゲームを一時停止/再開
  void togglePause() {
    if (!gameState.isGameStarted || gameState.isGameOver) return;

    setState(() {
      gameState.isGamePaused = !gameState.isGamePaused;

      if (gameState.isGamePaused) {
        // タイマーを停止
        gameState.gameTimer?.cancel();
        gameState.gameTimer = null;
      } else {
        // タイマーを再開
        gameState.gameTimer = Timer.periodic(gameState.gameSpeed, (timer) {
          moveSnake();
        });
      }
    });
  }

  // 方向を変更する
  void changeDirection(int newDirection) {
    // 反対方向への移動は無効（例：右に進んでいる時に左へは向けない）
    if ((gameState.direction == SnakeConstants.right &&
            newDirection == SnakeConstants.left) ||
        (gameState.direction == SnakeConstants.left &&
            newDirection == SnakeConstants.right) ||
        (gameState.direction == SnakeConstants.up &&
            newDirection == SnakeConstants.down) ||
        (gameState.direction == SnakeConstants.down &&
            newDirection == SnakeConstants.up)) {
      return;
    }

    // 次のフレームでの向きを設定
    setState(() {
      gameState.nextDirection = newDirection;
    });
  }

  // スネークを移動させる
  void moveSnake() {
    if (!gameState.isGameStarted ||
        gameState.isGamePaused ||
        gameState.isGameOver) return;

    setState(() {
      // 方向を更新
      gameState.direction = gameState.nextDirection;

      // 頭の現在位置を取得
      final head = gameState.snake[0];
      Point<int> newHead;

      // 方向に応じて新しい頭の位置を計算
      switch (gameState.direction) {
        case SnakeConstants.up:
          newHead = Point(head.x, head.y - 1);
          break;
        case SnakeConstants.right:
          newHead = Point(head.x + 1, head.y);
          break;
        case SnakeConstants.down:
          newHead = Point(head.x, head.y + 1);
          break;
        case SnakeConstants.left:
          newHead = Point(head.x - 1, head.y);
          break;
        default:
          newHead = Point(head.x + 1, head.y);
      }

      // 壁に衝突したかチェック
      if (newHead.x < 0 ||
          newHead.x >= gameState.colCount ||
          newHead.y < 0 ||
          newHead.y >= gameState.rowCount) {
        _gameOver();
        return;
      }

      // 自分自身に衝突したかチェック
      for (var segment in gameState.snake) {
        if (newHead.x == segment.x && newHead.y == segment.y) {
          _gameOver();
          return;
        }
      }

      // 障害物に衝突したかチェック
      for (var obstacle in gameState.obstacles) {
        if (newHead.x == obstacle.x && newHead.y == obstacle.y) {
          _gameOver();
          return;
        }
      }

      // 餌を食べたかチェック
      bool ateFood = false;
      if (gameState.food != null &&
          newHead.x == gameState.food!.x &&
          newHead.y == gameState.food!.y) {
        ateFood = true;
        gameState.foodEaten++;
        gameState.score += gameState.level * 10; // レベルに応じてスコアを増やす

        // レベルアップ判定（5個の餌で1レベルアップ）
        if (gameState.foodEaten % 5 == 0) {
          _levelUp();
        }

        // 新しい餌を配置
        gameState.placeFood();
      }

      // 新しい頭を追加
      gameState.snake.insert(0, newHead);

      // 餌を食べなかった場合は尻尾を削除
      if (!ateFood) {
        gameState.snake.removeLast();
      }
    });
  }

  // レベルアップ処理
  void _levelUp() {
    gameState.level++;

    // ゲームスピードを上げる（最低100msまで）
    gameState.gameSpeed = Duration(
        milliseconds: max(
            100,
            SnakeConstants.initialGameSpeed.inMilliseconds -
                (gameState.level - 1) * 30));

    // タイマーを更新
    gameState.gameTimer?.cancel();
    gameState.gameTimer = Timer.periodic(gameState.gameSpeed, (timer) {
      moveSnake();
    });

    // レベル2以降は障害物を追加
    if (gameState.level >= 2) {
      // レベルに応じて障害物を追加（最大で各レベル2個まで）
      int obstacleCount = min(2, gameState.level - 1);
      gameState.addObstacles(obstacleCount);
    }
  }

  // ゲームオーバー処理
  void _gameOver() {
    gameState.gameTimer?.cancel();
    gameState.isGameOver = true;
  }

  // ゲームをリセットして再開
  void restartGame() {
    gameState.gameTimer?.cancel();
    setState(() {
      gameState.reset();
    });
  }

  // リソース解放
  void dispose() {
    gameState.gameTimer?.cancel();
  }
}
