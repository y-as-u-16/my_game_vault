import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../constants/memory_card_constants.dart';
import '../models/memory_game_state.dart';

class MemoryCardGameScreen extends StatefulWidget {
  const MemoryCardGameScreen({super.key});

  @override
  State<MemoryCardGameScreen> createState() => _MemoryCardGameScreenState();
}

class _MemoryCardGameScreenState extends State<MemoryCardGameScreen>
    with TickerProviderStateMixin {
  late MemoryGameState gameState;
  late Timer gameTimer;
  List<AnimationController> flipControllers = [];
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    gameState = MemoryGameState();
    _initializeCards();
    _startGameTimer();
  }

  @override
  void dispose() {
    gameTimer.cancel();
    for (var controller in flipControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeCards() {
    // 以前のコントローラーを破棄
    for (var controller in flipControllers) {
      controller.dispose();
    }

    // 新しいカードアニメーションコントローラーを作成
    flipControllers = List.generate(
      gameState.totalCards,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _startGameTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          gameState.updateRemainingTime();

          if (gameState.isTimeOut || gameState.isGameComplete) {
            timer.cancel();
          }
        });
      }
    });
  }

  void _selectCard(int index) async {
    if (isProcessing) return;
    if (index >= flipControllers.length || index >= gameState.cards.length) return; // インデックス範囲外の場合は処理しない

    // カードを選択
    final success = gameState.selectCard(index);

    if (success) {
      // アニメーション実行
      flipControllers[index].forward();

      // 2枚目のカードを選んだ場合
      if (gameState.firstCardIndex == -1) {
        // マッチしない場合、少し待ってから裏返す
        setState(() {
          isProcessing = true;
        });

        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          // マッチしないカードを裏返す
          for (int i = 0; i < gameState.cards.length && i < flipControllers.length; i++) {
            if (gameState.cards[i].isRevealed) {
              flipControllers[i].reverse();
            }
          }

          gameState.hideUnmatchedCards();
          isProcessing = false;
        });
      }

      setState(() {});
    }
  }

  void _resetGame() {
    setState(() {
      gameState.resetGame();
      _initializeCards();
      _startGameTimer();
    });
  }

  void _changeDifficulty(DifficultyLevel difficulty) {
    setState(() {
      gameState.changeDifficulty(difficulty);
      _initializeCards(); // 新しい難易度に合わせてカードを初期化
      _startGameTimer();
    });
  }

  void _changeTheme(MemoryCardTheme theme) {
    setState(() {
      gameState.changeTheme(theme);
      _initializeCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gridSize =
        MemoryCardConstants.difficultySettings[gameState.difficulty]!.gridSize;

    return Scaffold(
      appBar: AppBar(
        title: const Text('メモリーカード'),
        centerTitle: true,
        actions: [
          // テーマ選択メニュー
          PopupMenuButton<MemoryCardTheme>(
            icon: const Icon(Icons.color_lens),
            onSelected: _changeTheme,
            itemBuilder: (context) => MemoryCardConstants.themes.map((theme) {
              return PopupMenuItem(
                value: theme,
                child: Text(theme.name),
              );
            }).toList(),
          ),

          // 難易度選択メニュー
          PopupMenuButton<DifficultyLevel>(
            icon: const Icon(Icons.settings),
            onSelected: _changeDifficulty,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: DifficultyLevel.easy,
                child: Text('初級 (4x4)'),
              ),
              const PopupMenuItem(
                value: DifficultyLevel.medium,
                child: Text('中級 (6x6)'),
              ),
              const PopupMenuItem(
                value: DifficultyLevel.hard,
                child: Text('上級 (8x8)'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 情報表示エリア
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: MemoryCardConstants.gradientColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // ペア数
                Column(
                  children: [
                    const Icon(Icons.extension, color: Colors.white),
                    const SizedBox(height: 4),
                    Text(
                      '${gameState.matchedPairs}/${gameState.requiredPairs}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // 手数
                Column(
                  children: [
                    const Icon(Icons.touch_app, color: Colors.white),
                    const SizedBox(height: 4),
                    Text(
                      '${gameState.moves}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // 残り時間
                Column(
                  children: [
                    const Icon(Icons.timer, color: Colors.white),
                    const SizedBox(height: 4),
                    Text(
                      gameState.formatRemainingTime(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ゲーム終了メッセージ
          if (gameState.isGameComplete || gameState.isTimeOut)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: gameState.isGameComplete
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: gameState.isGameComplete ? Colors.green : Colors.red,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    gameState.isGameComplete ? 'ゲームクリア！' : 'タイムオーバー',
                    style: TextStyle(
                      color:
                          gameState.isGameComplete ? Colors.green : Colors.red,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (gameState.isGameComplete)
                    Column(
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'スコア: ${gameState.calculateScore()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _resetGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          gameState.isGameComplete ? Colors.green : Colors.blue,
                    ),
                    child: const Text('もう一度プレイ'),
                  ),
                ],
              ),
            ),

          // カードグリッド
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: gameState.cards.length,
              itemBuilder: (context, index) {
                return _buildCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    final card = gameState.cards[index];
    
    // インデックスが配列範囲内かチェック
    final bool hasValidController = index < flipControllers.length;

    return GestureDetector(
      onTap: () {
        if (!gameState.isGameComplete && !gameState.isTimeOut) {
          _selectCard(index);
        }
      },
      child: hasValidController 
          ? AnimatedBuilder(
              animation: flipControllers[index],
              builder: (context, child) {
                // 回転角度の計算
                final rotationValue = flipControllers[index].value;
                final isReversed = card.isHidden && rotationValue == 0.0;
                final rotation = isReversed ? 0.0 : (rotationValue * pi);

                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // パースペクティブ効果
                    ..rotateY(rotation),
                  alignment: Alignment.center,
                  child: rotationValue >= 0.5 || card.isMatched || card.isRevealed
                      ? _buildCardFront(card) // 表面
                      : _buildCardBack(), // 裏面
                );
              },
            )
          : card.isMatched || card.isRevealed 
              ? _buildCardFront(card) // 表面
              : _buildCardBack(), // 裏面 (フォールバック処理)
    );
  }

  Widget _buildCardFront(MemoryCard card) {
    // カードの表面
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: card.isMatched
            ? MemoryCardConstants.cardMatchedColor
            : MemoryCardConstants.cardFrontColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          card.icon,
          size: 40,
          color: MemoryCardConstants.iconColor,
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    // カードの裏面
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: MemoryCardConstants.cardBackColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.question_mark,
          size: 40,
          color: Colors.white54,
        ),
      ),
    );
  }
}
