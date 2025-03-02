import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/game_card.dart';
import '../screens/tetris/start_screen.dart';

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.games, color: Colors.white.withOpacity(0.9)),
            const SizedBox(width: 10),
            const Text(
              'Flutter Games',
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
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundColor, AppColors.backgroundColorDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タイトルセクション
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ゲームを選択',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'お好みのゲームを選んでプレイしましょう',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // ゲーム一覧
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      // テトリスゲーム
                      GameCard(
                        title: 'テトリス',
                        description: 'ブロックを積み重ねて消すクラシックパズルゲーム',
                        icon: Icons.grid_4x4,
                        color: Colors.indigoAccent,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TetrisStartScreen(),
                            ),
                          );
                        },
                      ),
                      
                      // 今後追加予定のゲーム（プレースホルダー）
                      GameCard(
                        title: 'Coming Soon',
                        description: '近日公開予定のゲーム',
                        icon: Icons.hourglass_empty,
                        color: Colors.grey.shade700,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('このゲームは開発中です。お楽しみに！'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),

                      // 今後追加予定のゲーム（プレースホルダー）
                      GameCard(
                        title: 'Coming Soon',
                        description: '近日公開予定のゲーム',
                        icon: Icons.hourglass_empty,
                        color: Colors.grey.shade700,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('このゲームは開発中です。お楽しみに！'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),

                      // 今後追加予定のゲーム（プレースホルダー）
                      GameCard(
                        title: 'Coming Soon',
                        description: '近日公開予定のゲーム',
                        icon: Icons.hourglass_empty,
                        color: Colors.grey.shade700,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('このゲームは開発中です。お楽しみに！'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
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
}