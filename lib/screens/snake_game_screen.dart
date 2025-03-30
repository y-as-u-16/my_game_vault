import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_vault/constants/snake_constants.dart';
import 'package:game_vault/models/snake_game_state.dart';
import 'package:game_vault/painters/snake_painter.dart';
import 'package:game_vault/services/snake_game_service.dart';
import 'game_selection_screen.dart';

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({Key? key}) : super(key: key);

  @override
  _SnakeGameScreenState createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  late SnakeGameState gameState;
  late SnakeGameService gameService;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // ゲーム状態とサービスの初期化
    gameState = SnakeGameState();
    gameService = SnakeGameService(gameState, setState);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  void dispose() {
    gameService.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ゲーム選択画面に戻る
  void returnToSelectionScreen() {
    gameState.gameTimer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const GameSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            gameService.changeDirection(SnakeConstants.left);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            gameService.changeDirection(SnakeConstants.right);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            gameService.changeDirection(SnakeConstants.down);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            gameService.changeDirection(SnakeConstants.up);
          } else if (event.logicalKey == LogicalKeyboardKey.space) {
            if (!gameState.isGameStarted && !gameState.isGameOver) {
              gameService.startGame();
            }
          } else if (event.logicalKey == LogicalKeyboardKey.keyP) {
            gameService.togglePause();
          } else if (event.logicalKey == LogicalKeyboardKey.keyR &&
              gameState.isGameOver) {
            gameService.restartGame();
          } else if (event.logicalKey == LogicalKeyboardKey.keyS &&
              !gameState.isGameStarted) {
            gameService.startGame();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.linear_scale, color: Colors.white.withOpacity(0.9)),
              const SizedBox(width: 10),
              const Text(
                'スネークゲーム',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF0F3460),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: returnToSelectionScreen,
          ),
          actions: [
            if (gameState.isGameStarted && !gameState.isGameOver)
              IconButton(
                icon: Icon(
                    gameState.isGamePaused ? Icons.play_arrow : Icons.pause),
                onPressed: () => gameService.togglePause(),
              ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // スコア表示
                _buildScorePanel(),

                // ゲームエリア
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildGameBoard(),
                  ),
                ),

                const SizedBox(height: 10),

                // ゲーム未開始の場合はスタートボタンを表示
                if (!gameState.isGameStarted && !gameState.isGameOver)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton.icon(
                      onPressed: () => gameService.startGame(),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text(
                        'ゲーム開始',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  )
                else if (gameState.isGamePaused)
                  // 一時停止時のメッセージ
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '一時停止中',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  // コントロールボタン
                  _buildControlButtons(),

                const SizedBox(height: 10),

                // リスタートボタン（ゲームオーバー時）
                if (gameState.isGameOver)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton.icon(
                      onPressed: () => gameService.restartGame(),
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        'リスタート',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 12),
                        elevation: 5,
                        shadowColor: Colors.black54,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // スコアパネル
  Widget _buildScorePanel() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460).withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: const Offset(0, 3),
            blurRadius: 5,
          ),
        ],
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _scoreItem('Score', gameState.score.toString(), Icons.score),
          _scoreItem('Level', gameState.level.toString(), Icons.trending_up),
          _scoreItem('Food', gameState.foodEaten.toString(), Icons.apple),
        ],
      ),
    );
  }

  // ゲームボード
  Widget _buildGameBoard() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF4CAF50), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                offset: const Offset(0, 5),
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 1.0, // 正方形のボード
              child: CustomPaint(
                painter: SnakePainter(
                  snake: gameState.snake,
                  food: gameState.food,
                  obstacles: gameState.obstacles,
                  rowCount: gameState.rowCount,
                  colCount: gameState.colCount,
                ),
              ),
            ),
          ),
        ),
        // ゲームオーバーオーバーレイ
        if (gameState.isGameOver)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'GAME OVER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'スコア: ${gameState.score}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'レベル: ${gameState.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => gameService.restartGame(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: const Text(
                          'リトライ',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        // ゲーム未開始オーバーレイ
        if (!gameState.isGameStarted && !gameState.isGameOver)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text(
                          '準備OK？',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '← → ↑ ↓ キーで操作',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // コントロールボタン
  Widget _buildControlButtons() {
    if (!gameState.isGameStarted ||
        gameState.isGamePaused ||
        gameState.isGameOver) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // 上ボタン
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _controlButton(Icons.arrow_drop_up,
                  () => gameService.changeDirection(SnakeConstants.up)),
            ],
          ),
          // 左・下・右ボタン
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _controlButton(Icons.arrow_left,
                  () => gameService.changeDirection(SnakeConstants.left)),
              const SizedBox(width: 20),
              _controlButton(Icons.arrow_drop_down,
                  () => gameService.changeDirection(SnakeConstants.down)),
              const SizedBox(width: 20),
              _controlButton(Icons.arrow_right,
                  () => gameService.changeDirection(SnakeConstants.right)),
            ],
          ),
        ],
      ),
    );
  }

  // スコア表示用のウィジェット
  Widget _scoreItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // コントロールボタン用のウィジェット
  Widget _controlButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: const Offset(0, 2),
            blurRadius: 5,
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          splashColor: Colors.white24,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }
}
