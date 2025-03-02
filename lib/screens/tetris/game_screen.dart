import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/tetris/game_state.dart';
import '../../services/tetris/game_service.dart';
import '../../painters/tetris/tetris_painter.dart';
import '../../constants/tetrominos.dart';
import '../../constants/colors.dart';

class TetrisGameScreen extends StatefulWidget {
  const TetrisGameScreen({Key? key}) : super(key: key);

  @override
  _TetrisGameScreenState createState() => _TetrisGameScreenState();
}

class _TetrisGameScreenState extends State<TetrisGameScreen> {
  late GameState gameState;
  late GameService gameService;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // ゲーム状態とサービスの初期化
    gameState = GameState();
    gameService = GameService(gameState, setState);

    // 初期ピースを生成
    gameService.spawnNewPiece();
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

  // スタート画面に戻る
  void returnToStartScreen() {
    gameState.gameTimer?.cancel();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            gameService.moveLeft();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            gameService.moveRight();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            gameService.moveDown();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            gameService.rotate();
          } else if (event.logicalKey == LogicalKeyboardKey.space) {
            if (!gameState.isGameStarted && !gameState.isGameOver) {
              gameService.startGame();
            } else {
              gameService.hardDrop();
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
              Icon(Icons.games, color: Colors.white.withOpacity(0.9)),
              const SizedBox(width: 10),
              const Text(
                'Flutter Tetris',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: AppColors.primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: returnToStartScreen,
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
              colors: [
                AppColors.backgroundColor,
                AppColors.backgroundColorDark
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // スコア表示とステータス
                _buildScorePanel(),

                // ゲームエリア（ボードと次のブロック）
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        // ゲームボード
                        Expanded(
                          flex: 3,
                          child: _buildGameBoard(),
                        ),

                        // 右サイドパネル
                        Expanded(
                          flex: 1,
                          child: _buildSidePanel(),
                        ),
                      ],
                    ),
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
                        backgroundColor: AppColors.accentColor,
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

                // ハードドロップと再起動ボタン
                _buildActionButtons(),
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
        color: AppColors.primaryColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          const BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 3),
            blurRadius: 5,
          ),
        ],
        border: Border.all(color: Colors.indigo.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _scoreItem('Score', gameState.score.toString(), Icons.score),
          _scoreItem('Level', gameState.level.toString(), Icons.trending_up),
          _scoreItem('Lines', gameState.linesCleared.toString(), Icons.layers),
        ],
      ),
    );
  }

  // ゲームボード
  Widget _buildGameBoard() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: AppColors.backgroundColorDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryColor, width: 2),
            boxShadow: [
              const BoxShadow(
                color: Colors.black38,
                offset: Offset(0, 5),
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: GameState.colCount / GameState.rowCount,
              child: CustomPaint(
                painter: TetrisPainter(
                  board: gameState.board,
                  colors: Tetrominos.colors,
                  currentPiece: gameState.currentPiece,
                  currentPieceRow: gameState.currentPieceRow,
                  currentPieceCol: gameState.currentPieceCol,
                  currentColor: gameState.currentColor,
                  checkCollision: gameService.checkCollision,
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
              aspectRatio: GameState.colCount / GameState.rowCount,
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
              aspectRatio: GameState.colCount / GameState.rowCount,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.7),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // サイドパネル（次のブロックと情報）
  Widget _buildSidePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 次のブロックプレビュー
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.backgroundColorDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryColor, width: 2),
            boxShadow: [
              const BoxShadow(
                color: Colors.black38,
                offset: Offset(0, 3),
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'NEXT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: gameState.nextPiece != null
                      ? CustomPaint(
                          size: const Size(60, 60),
                          painter: NextPiecePainter(
                            piece: gameState.nextPiece!,
                            color: gameState.nextColor,
                          ),
                        )
                      : Container(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // レベル進捗
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.backgroundColorDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryColor, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                offset: Offset(0, 3),
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LEVEL UP',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${gameState.level * 10 - gameState.linesCleared} lines to go',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 10,
                child: LinearProgressIndicator(
                  value: (gameState.linesCleared % 10) / 10,
                  backgroundColor: Colors.blueGrey.shade800,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accentColor),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ステータスメッセージの表示
  Widget _buildStatusMessage() {
    if (gameState.isGameOver) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'ゲームオーバー',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (gameState.isGamePaused) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          '一時停止中',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (!gameState.isGameStarted) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'ゲーム準備完了',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _controlButton(Icons.arrow_left, () => gameService.moveLeft()),
          _controlButton(Icons.arrow_drop_down, () => gameService.moveDown()),
          _controlButton(Icons.rotate_right, () => gameService.rotate()),
          _controlButton(Icons.arrow_right, () => gameService.moveRight()),
        ],
      ),
    );
  }

  // アクションボタン（ハードドロップ・リスタート）
  Widget _buildActionButtons() {
    // ゲームが開始していない場合は表示しない
    if (!gameState.isGameStarted && !gameState.isGameOver) {
      return const SizedBox.shrink();
    }

    // ゲームが一時停止中の場合も表示しない
    if (gameState.isGamePaused) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (gameState.isGameStarted && !gameState.isGameOver)
            ElevatedButton.icon(
              onPressed: () => gameService.hardDrop(),
              icon: const Icon(Icons.arrow_downward),
              label: const Text('一気に落とす'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                elevation: 5,
                shadowColor: Colors.black54,
              ),
            ),
          const SizedBox(width: 15),
          if (gameState.isGameOver)
            ElevatedButton.icon(
              onPressed: () => gameService.restartGame(),
              icon: const Icon(Icons.refresh),
              label: const Text('リスタート'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                elevation: 5,
                shadowColor: Colors.black54,
              ),
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
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          const BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 5,
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
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
