import 'package:flutter/material.dart';
import 'package:game_vault/screens/tetris_start_screen.dart';
import 'snake_game_screen.dart';
import 'breakout_game_screen.dart';
import 'minesweeper_game_screen.dart';
import 'sudoku_game_screen.dart';
import 'memory_card_game_screen.dart';
import '../widgets/game_card.dart';

class GameSelectionScreen extends StatefulWidget {
  const GameSelectionScreen({Key? key}) : super(key: key);

  @override
  State<GameSelectionScreen> createState() => _GameSelectionScreenState();
}

class _GameSelectionScreenState extends State<GameSelectionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Animation<double>> _cardAnimations = [];
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    // 各カードのアニメーション
    // ゲーム数を考慮して確実に6個のアニメーションを作成
    const int numCards = 6;
    for (int i = 0; i < numCards; i++) {
      final interval = i * 0.1;
      _cardAnimations.add(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            interval,
            interval + 0.5,
            curve: Curves.easeOutBack,
          ),
        ),
      );
    }
    
    // アニメーションの開始
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0F3460).withOpacity(0.8),
                const Color(0xFF1A1A2E).withOpacity(0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.games, color: Colors.white.withOpacity(0.9)),
            const SizedBox(width: 10),
            const Text(
              'Game Vault',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontSize: 22,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
          ),
          image: DecorationImage(
            image: const AssetImage('assets/icon/app_icon.png'),
            fit: BoxFit.none,
            opacity: 0.05,
            scale: 0.5,
            alignment: Alignment.center,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF533483).withOpacity(0.3),
                      const Color(0xFF0F3460).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.videogame_asset,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          'ようこそ！',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F3460).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        'プレイしたいゲームを選んでください',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // カテゴリタイトル
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFF0F3460).withOpacity(0.7),
                      const Color(0xFF0F3460).withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.stars_rounded,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'ゲームコレクション',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${6} ゲーム',  // ゲーム数を表示
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // ゲームカードのグリッド表示
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GridView(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    children: [
                      _animatedGameCard(0, GameCard(
                        title: 'テトリス',
                        description: 'ブロックを積み上げて列を消していくクラシックゲーム',
                        icon: Icons.grid_4x4,
                        color: Colors.indigo.shade400,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TetrisStartScreen(),
                            ),
                          );
                        },
                      )),
                      _animatedGameCard(1, GameCard(
                        title: 'スネーク',
                        description: '蛇を操作して餌を集めながら成長させよう',
                        icon: Icons.linear_scale,
                        color: Colors.green.shade400,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SnakeGameScreen(),
                            ),
                          );
                        },
                      )),
                      _animatedGameCard(2, GameCard(
                        title: 'ブレックアウト',
                        description: 'パドルでボールを操作してブロックを壊そう',
                        icon: Icons.fitness_center,
                        color: Colors.red.shade400,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BreakoutGameScreen(),
                            ),
                          );
                        },
                      )),
                      _animatedGameCard(3, GameCard(
                        title: 'マインスイーパー',
                        description: '地雷を避けながら全てのマスを開こう',
                        icon: Icons.emoji_events_outlined,
                        color: Colors.purple.shade400,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const MinesweeperGameScreen(),
                            ),
                          );
                        },
                      )),
                      _animatedGameCard(4, GameCard(
                        title: '数独',
                        description: '論理的思考で数字のパズルを解こう',
                        icon: Icons.grid_3x3,
                        color: Colors.blue.shade400,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SudokuGameScreen(),
                            ),
                          );
                        },
                      )),
                      _animatedGameCard(5, GameCard(
                        title: 'メモリーカード',
                        description: '記憶力を鍛えてカードをマッチさせよう',
                        icon: Icons.flip,
                        color: Colors.amber.shade400,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const MemoryCardGameScreen(),
                            ),
                          );
                        },
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // アニメーション付きのゲームカード
  Widget _animatedGameCard(int index, Widget child) {
    // インデックスが範囲外でないことを確認
    if (index >= _cardAnimations.length) {
      return child; // アニメーションがない場合、そのままカードを返す
    }
    
    return AnimatedBuilder(
      animation: _cardAnimations[index],
      builder: (context, childWidget) {
        return Transform.translate(
          offset: Offset(
            0.0, 
            50 * (1.0 - _cardAnimations[index].value)
          ),
          child: Opacity(
            opacity: _cardAnimations[index].value.clamp(0.0, 1.0), // 0.0〜1.0の範囲に制限
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }
}
