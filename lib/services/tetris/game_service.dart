import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:game_vault/constants/tetrominos.dart';
import 'package:game_vault/models/tetris/game_state.dart';

class GameService {
  final GameState gameState;
  final Function(VoidCallback) setState;

  GameService(this.gameState, this.setState);

  // ゲームを開始する
  void startGame() {
    if (gameState.isGameStarted) return;

    setState(() {
      gameState.isGameStarted = true;

      // ゲームタイマーの開始
      gameState.gameTimer = Timer.periodic(gameState.gameSpeed, (timer) {
        moveDown();
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
          moveDown();
        });
      }
    });
  }

  // 新しいピースをランダムに生成
  List<dynamic> generateRandomPiece() {
    final random = Random();
    final index = random.nextInt(Tetrominos.shapes.length);
    final piece = List.from(Tetrominos.shapes[index])
        .map((row) => List<int>.from(row))
        .toList();
    return [piece, index];
  }

  // 新しいピースを生成する
  void spawnNewPiece() {
    // 次のピースが現在のピースになる
    if (gameState.nextPiece != null) {
      gameState.currentPiece = gameState.nextPiece!;
      gameState.currentPieceIndex = gameState.nextPieceIndex;
      gameState.currentColor = Tetrominos.colors[gameState.currentPieceIndex];
    } else {
      // 初回のみランダム生成
      final pieceData = generateRandomPiece();
      gameState.currentPiece = pieceData[0];
      gameState.currentPieceIndex = pieceData[1];
      gameState.currentColor = Tetrominos.colors[gameState.currentPieceIndex];
    }

    // 次のピースを生成
    final nextPieceData = generateRandomPiece();
    gameState.nextPiece = nextPieceData[0];
    gameState.nextPieceIndex = nextPieceData[1];
    gameState.nextColor = Tetrominos.colors[gameState.nextPieceIndex];

    // ピースの初期位置
    gameState.currentPieceRow = 0;
    gameState.currentPieceCol =
        GameState.colCount ~/ 2 - gameState.currentPiece[0].length ~/ 2;

    // 新しいピースがボードと衝突するか確認
    if (isCollision()) {
      // ゲームオーバー
      gameState.gameTimer?.cancel();
      gameState.gameTimer = null;
      setState(() {
        gameState.isGameOver = true;
      });
    }
  }

  // 衝突チェック
  bool isCollision() {
    for (int r = 0; r < gameState.currentPiece.length; r++) {
      for (int c = 0; c < gameState.currentPiece[r].length; c++) {
        if (gameState.currentPiece[r][c] != 0) {
          int boardRow = gameState.currentPieceRow + r;
          int boardCol = gameState.currentPieceCol + c;

          // ボードの範囲外かチェック
          if (boardRow >= GameState.rowCount ||
              boardCol < 0 ||
              boardCol >= GameState.colCount) {
            return true;
          }

          // 既に埋まっているマスと衝突するかチェック
          if (boardRow >= 0 && gameState.board[boardRow][boardCol] != 0) {
            return true;
          }
        }
      }
    }
    return false;
  }

  // 左に移動
  void moveLeft() {
    if (!gameState.isGameStarted ||
        gameState.isGamePaused ||
        gameState.isGameOver) return;

    setState(() {
      gameState.currentPieceCol--;
      if (isCollision()) {
        gameState.currentPieceCol++;
      }
    });
  }

  // 右に移動
  void moveRight() {
    if (!gameState.isGameStarted ||
        gameState.isGamePaused ||
        gameState.isGameOver) return;

    setState(() {
      gameState.currentPieceCol++;
      if (isCollision()) {
        gameState.currentPieceCol--;
      }
    });
  }

  // 下に移動
  void moveDown() {
    if (!gameState.isGameStarted ||
        gameState.isGamePaused ||
        gameState.isGameOver) return;

    setState(() {
      gameState.currentPieceRow++;
      if (isCollision()) {
        // 一つ上に戻す
        gameState.currentPieceRow--;
        // ピースをボードに固定
        placePiece();
        // ライン消去チェック
        clearLines();
        // 新しいピースを生成
        spawnNewPiece();
      }
    });
  }

  // 回転
  void rotate() {
    if (!gameState.isGameStarted ||
        gameState.isGamePaused ||
        gameState.isGameOver) return;

    setState(() {
      // 時計回りに90度回転
      final List<List<int>> rotated = List.generate(
        gameState.currentPiece[0].length,
        (i) => List.generate(
          gameState.currentPiece.length,
          (j) =>
              gameState.currentPiece[gameState.currentPiece.length - 1 - j][i],
        ),
      );

      // 回転後のピースを一時的に保存
      final originalPiece = gameState.currentPiece;
      gameState.currentPiece = rotated;

      // 衝突する場合は元に戻す
      if (isCollision()) {
        gameState.currentPiece = originalPiece;
      }
    });
  }

  // ピースをボードに固定
  void placePiece() {
    for (int r = 0; r < gameState.currentPiece.length; r++) {
      for (int c = 0; c < gameState.currentPiece[r].length; c++) {
        if (gameState.currentPiece[r][c] != 0) {
          int boardRow = gameState.currentPieceRow + r;
          int boardCol = gameState.currentPieceCol + c;

          if (boardRow >= 0 &&
              boardRow < GameState.rowCount &&
              boardCol >= 0 &&
              boardCol < GameState.colCount) {
            // 色のインデックスを保存（+1して0が空白と区別できるようにする）
            gameState.board[boardRow][boardCol] =
                gameState.currentPieceIndex + 1;
          }
        }
      }
    }
  }

  // ライン消去
  // ライン消去
  void clearLines() {
    List<int> linesToClear = [];

    // 消去する行を探す
    for (int r = 0; r < GameState.rowCount; r++) {
      bool isLineFull = true;
      for (int c = 0; c < GameState.colCount; c++) {
        if (gameState.board[r][c] == 0) {
          isLineFull = false;
          break;
        }
      }
      if (isLineFull) {
        linesToClear.add(r);
      }
    }

    if (linesToClear.isEmpty) return;

    // 消去する行数に応じてスコアを加算
    int clearedLines = linesToClear.length;
    gameState.linesCleared += clearedLines;

    // スコア計算（テトリスの一般的なスコアリング）
    int pointsGained;
    switch (clearedLines) {
      case 1:
        pointsGained = 100 * gameState.level;
        break;
      case 2:
        pointsGained = 300 * gameState.level;
        break;
      case 3:
        pointsGained = 500 * gameState.level;
        break;
      case 4:
        pointsGained = 800 * gameState.level; // テトリス！
        break;
      default:
        pointsGained = 0;
    }

    gameState.score += pointsGained;

    // レベルアップ（10ラインごと）
    int newLevel = (gameState.linesCleared ~/ 10) + 1;

    // レベルが上がった場合はゲームスピードを調整
    if (newLevel > gameState.level) {
      gameState.level = newLevel;
      // レベルが上がるごとに少しずつ速くなる（ただし最低200msまで）
      gameState.gameTimer?.cancel();
      gameState.gameSpeed = Duration(
          milliseconds: max(
              200,
              GameState.initialGameSpeed.inMilliseconds -
                  (gameState.level - 1) * 50));
      gameState.gameTimer = Timer.periodic(gameState.gameSpeed, (timer) {
        moveDown();
      });
    }

    // 新しいボードを作成（消去行を除外）
    List<List<int>> newBoard = [];

    // 消去しない行だけを新しいボードに追加
    for (int r = 0; r < GameState.rowCount; r++) {
      if (!linesToClear.contains(r)) {
        newBoard.add(List<int>.from(gameState.board[r]));
      }
    }

    // 消去した行数分の空行を上部に追加
    for (int i = 0; i < clearedLines; i++) {
      newBoard.insert(0, List.filled(GameState.colCount, 0));
    }

    // 新しいボードで更新
    gameState.board = newBoard;
  }

  // 一気に落とす
  void hardDrop() {
    if (!gameState.isGameStarted ||
        gameState.isGamePaused ||
        gameState.isGameOver) return;

    setState(() {
      // 衝突するまで下に移動
      while (!isCollision()) {
        gameState.currentPieceRow++;
      }

      // 一つ上に戻す
      gameState.currentPieceRow--;
      // ピースをボードに固定
      placePiece();
      // ライン消去チェック
      clearLines();
      // 新しいピースを生成
      spawnNewPiece();
    });
  }

  // ゲームを再起動
  void restartGame() {
    gameState.gameTimer?.cancel();
    setState(() {
      gameState.reset();
      spawnNewPiece();
    });
  }

  // 特定の位置でのピースの衝突をチェック（ヘルパーメソッド）
  bool checkCollision(List<List<int>> piece, int pieceRow, int pieceCol) {
    for (int r = 0; r < piece.length; r++) {
      for (int c = 0; c < piece[r].length; c++) {
        if (piece[r][c] != 0) {
          int boardRow = pieceRow + r;
          int boardCol = pieceCol + c;

          // ボードの範囲外かチェック
          if (boardRow >= gameState.board.length ||
              boardCol < 0 ||
              boardCol >= gameState.board[0].length) {
            return true;
          }

          // 既に埋まっているマスと衝突するかチェック
          if (boardRow >= 0 && gameState.board[boardRow][boardCol] != 0) {
            return true;
          }
        }
      }
    }
    return false;
  }

  // リソースの解放
  void dispose() {
    gameState.gameTimer?.cancel();
  }
}
