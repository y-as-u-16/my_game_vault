import 'dart:async';
import 'dart:math';
import '../constants/snake_constants.dart';

class SnakeGameState {
  // ゲームボードのサイズ
  final int rowCount = SnakeConstants.rowCount;
  final int colCount = SnakeConstants.colCount;

  // ゲーム速度
  Duration gameSpeed = SnakeConstants.initialGameSpeed;

  // スネークの位置情報（座標のリスト、先頭が頭）
  List<Point<int>> snake = [];

  // 餌の位置
  Point<int>? food;

  // 障害物の位置（レベルが上がると増える）
  List<Point<int>> obstacles = [];

  // 方向（0:上, 1:右, 2:下, 3:左）
  int direction = SnakeConstants.right;
  int nextDirection = SnakeConstants.right; // 次のフレームでの方向

  // ゲームステータス
  bool isGameOver = false;
  bool isGamePaused = false;
  bool isGameStarted = false;

  // スコア情報
  int score = 0;
  int level = 1;
  int foodEaten = 0;

  // ゲームタイマー
  Timer? gameTimer;

  // 初期化
  SnakeGameState() {
    reset();
  }

  // ゲーム状態のリセット
  void reset() {
    // スネークの初期位置（中央付近から始める）
    snake = [
      Point(colCount ~/ 2, rowCount ~/ 2),
      Point(colCount ~/ 2 - 1, rowCount ~/ 2),
      Point(colCount ~/ 2 - 2, rowCount ~/ 2),
    ];

    // 餌を配置
    placeFood();

    // 障害物をリセット
    obstacles = [];

    // 最初のレベルでは障害物なし
    // レベル2以降で障害物を追加

    // ゲーム設定をリセット
    direction = SnakeConstants.right;
    nextDirection = SnakeConstants.right;
    score = 0;
    level = 1;
    foodEaten = 0;
    isGameOver = false;
    isGameStarted = false;
    isGamePaused = false;
    gameSpeed = SnakeConstants.initialGameSpeed;
  }

  // 餌を配置する
  void placeFood() {
    final random = Random();
    int x, y;
    bool validPosition;

    // スネークや障害物と重ならない位置を探す
    do {
      x = random.nextInt(colCount);
      y = random.nextInt(rowCount);
      validPosition = true;

      // スネークと重なっていないか確認
      for (var segment in snake) {
        if (segment.x == x && segment.y == y) {
          validPosition = false;
          break;
        }
      }

      // 障害物と重なっていないか確認
      if (validPosition) {
        for (var obstacle in obstacles) {
          if (obstacle.x == x && obstacle.y == y) {
            validPosition = false;
            break;
          }
        }
      }
    } while (!validPosition);

    food = Point(x, y);
  }

  // 障害物を追加（レベルアップ時）
  void addObstacles(int count) {
    final random = Random();

    for (int i = 0; i < count; i++) {
      int x, y;
      bool validPosition;

      do {
        x = random.nextInt(colCount);
        y = random.nextInt(rowCount);
        validPosition = true;

        // スネークと重なっていないか確認
        for (var segment in snake) {
          if (segment.x == x && segment.y == y) {
            validPosition = false;
            break;
          }
        }

        // 餌と重なっていないか確認
        if (food != null && food!.x == x && food!.y == y) {
          validPosition = false;
        }

        // 既存の障害物と重なっていないか確認
        if (validPosition) {
          for (var obstacle in obstacles) {
            if (obstacle.x == x && obstacle.y == y) {
              validPosition = false;
              break;
            }
          }
        }

        // スネークの頭の周囲には置かない（動きづらくなるため）
        if (validPosition && snake.isNotEmpty) {
          int headX = snake[0].x;
          int headY = snake[0].y;
          if ((x == headX && (y == headY - 1 || y == headY + 1)) ||
              (y == headY && (x == headX - 1 || x == headX + 1))) {
            validPosition = false;
          }
        }
      } while (!validPosition);

      obstacles.add(Point(x, y));
    }
  }
}
