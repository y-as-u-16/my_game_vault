import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/minesweeper_constants.dart';
import '../models/minesweeper_game_state.dart';

class MinesweeperGameScreen extends StatefulWidget {
  const MinesweeperGameScreen({Key? key}) : super(key: key);

  @override
  State<MinesweeperGameScreen> createState() => _MinesweeperGameScreenState();
}

class _MinesweeperGameScreenState extends State<MinesweeperGameScreen> {
  late MinesweeperGameState gameState;
  late Timer _timer;
  int _elapsedSeconds = 0;
  DifficultyLevel _currentDifficulty = DifficultyLevel.easy;

  @override
  void initState() {
    super.initState();
    gameState = MinesweeperGameState(difficulty: _currentDifficulty);
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !gameState.isGameOver) {
        setState(() {
          if (gameState.startTime != null) {
            _elapsedSeconds = gameState.getElapsedTime().inSeconds;
          }
        });
      }
    });
  }

  void _restartGame() {
    setState(() {
      gameState.restartGame();
      _elapsedSeconds = 0;
    });
  }

  void _changeDifficulty(DifficultyLevel newDifficulty) {
    setState(() {
      _currentDifficulty = newDifficulty;
      gameState.changeDifficulty(newDifficulty);
      _elapsedSeconds = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マインスイーパー'),
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton<DifficultyLevel>(
            icon: const Icon(Icons.settings),
            onSelected: _changeDifficulty,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: DifficultyLevel.easy,
                child: Text('初級 (9x9, 10地雷)'),
              ),
              const PopupMenuItem(
                value: DifficultyLevel.medium,
                child: Text('中級 (16x16, 40地雷)'),
              ),
              const PopupMenuItem(
                value: DifficultyLevel.hard,
                child: Text('上級 (24x24, 99地雷)'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ゲーム情報表示
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F3460),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                ),
              ],
            ),
            margin: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 残り地雷数
                Column(
                  children: [
                    const Icon(Icons.flag, color: flagColor),
                    const SizedBox(height: 5),
                    Text(
                      '${gameState.getRemainingMines()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                // リスタートボタン
                ElevatedButton(
                  onPressed: _restartGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16213E),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(15),
                  ),
                  child: Icon(
                    gameState.isWin
                        ? Icons.sentiment_very_satisfied
                        : (gameState.isGameOver
                            ? Icons.sentiment_very_dissatisfied
                            : Icons.refresh),
                    color: gameState.isWin
                        ? Colors.green
                        : (gameState.isGameOver ? Colors.red : Colors.white),
                  ),
                ),
                
                // 経過時間
                Column(
                  children: [
                    const Icon(Icons.timer, color: Colors.white),
                    const SizedBox(height: 5),
                    Text(
                      '$_elapsedSeconds秒',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ゲームステータス表示
          if (gameState.isGameOver)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: gameState.isWin
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                gameState.isWin ? 'ゲームクリア！' : 'ゲームオーバー',
                style: TextStyle(
                  color: gameState.isWin ? Colors.green : Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // マインスイーパーのグリッド
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: gameState.columns / gameState.rows,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gameState.columns,
                    ),
                    itemCount: gameState.rows * gameState.columns,
                    itemBuilder: (context, index) {
                      final row = index ~/ gameState.columns;
                      final col = index % gameState.columns;
                      final cell = gameState.grid[row][col];
                      
                      return GestureDetector(
                        onTap: () {
                          if (!gameState.isGameOver) {
                            setState(() {
                              gameState.revealCell(row, col);
                            });
                          }
                        },
                        onLongPress: () {
                          if (!gameState.isGameOver) {
                            setState(() {
                              gameState.toggleFlag(row, col);
                            });
                          }
                        },
                        child: _buildCell(cell),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // ゲーム操作方法の説明
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F3460).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              children: [
                Text(
                  '操作方法',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'タップ: セルを開く',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '長押し: フラグを立てる/解除',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(Cell cell) {
    // セルがまだ開かれていない場合
    if (cell.state == CellState.covered) {
      return Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: coveredCellColor,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }
    
    // フラグが立てられている場合
    else if (cell.state == CellState.flagged) {
      return Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: coveredCellColor,
          borderRadius: BorderRadius.circular(2),
        ),
        child: const Center(
          child: Icon(
            Icons.flag,
            color: flagColor,
            size: 18,
          ),
        ),
      );
    }
    
    // ?マークが付けられている場合
    else if (cell.state == CellState.questioned) {
      return Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: coveredCellColor,
          borderRadius: BorderRadius.circular(2),
        ),
        child: const Center(
          child: Text(
            '?',
            style: TextStyle(
              color: questionColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      );
    }
    
    // 開かれた場合
    else {
      // 地雷の場合
      if (cell.content == CellContent.mine) {
        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: mineColor,
            borderRadius: BorderRadius.circular(2),
          ),
          child: const Center(
            child: Icon(
              Icons.dangerous,
              color: Colors.white,
              size: 18,
            ),
          ),
        );
      }
      
      // 数字の場合
      else if (cell.content == CellContent.number) {
        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: revealedCellColor,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Center(
            child: Text(
              '${cell.adjacentMines}',
              style: TextStyle(
                color: numberColors[cell.adjacentMines],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
      }
      
      // 空のセルの場合
      else {
        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: revealedCellColor,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }
    }
  }
}
