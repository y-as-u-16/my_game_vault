import 'package:flutter/material.dart';
import 'dart:async';

class GameState {
  // ゲームボードのサイズ
  static const int rowCount = 20;
  static const int colCount = 10;

  // ゲーム速度
  static const Duration initialGameSpeed = Duration(milliseconds: 800);
  Duration gameSpeed = initialGameSpeed;

  // ボード状態
  List<List<int>> board =
      List.generate(rowCount, (_) => List.filled(colCount, 0));

  // 現在のピース情報
  List<List<int>> currentPiece = [];
  int currentPieceRow = 0;
  int currentPieceCol = 0;
  int currentPieceIndex = 0;
  Color currentColor = Colors.transparent;

  // 次のピース情報
  List<List<int>>? nextPiece;
  int nextPieceIndex = 0;
  Color nextColor = Colors.transparent;

  // ゲームステータス
  bool isGameOver = false;
  bool isGamePaused = false;
  bool isGameStarted = false;

  // スコア情報
  int score = 0;
  int level = 1;
  int linesCleared = 0;

  // ゲームタイマー
  Timer? gameTimer;

  // ゲーム状態のリセット
  void reset() {
    board = List.generate(rowCount, (_) => List.filled(colCount, 0));
    score = 0;
    level = 1;
    linesCleared = 0;
    isGameOver = false;
    isGameStarted = false;
    isGamePaused = false;
    gameSpeed = initialGameSpeed;
  }
}
