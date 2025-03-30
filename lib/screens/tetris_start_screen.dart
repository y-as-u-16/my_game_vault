import 'package:flutter/material.dart';
import 'package:game_vault/constants/colors.dart';
import 'game_screen.dart';

class TetrisStartScreen extends StatelessWidget {
  const TetrisStartScreen({Key? key}) : super(key: key);

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
              'テトリス',
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
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundColor, AppColors.backgroundColorDark],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ロゴまたはタイトル
              Icon(
                Icons.grid_4x4,
                size: 80,
                color: Colors.indigo.shade200,
              ),
              const SizedBox(height: 20),
              Text(
                'TETRIS',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 8,
                  shadows: [
                    Shadow(
                      color: Colors.indigo.withOpacity(0.7),
                      offset: const Offset(3, 3),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // ルール説明
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.indigo.withOpacity(0.3)),
                ),
                child: Column(
                  children: const [
                    Text(
                      'ルール',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'ブロックを操作して横一列を揃えると消えます。\n'
                      '画面の上までブロックが積み上がるとゲームオーバーです。',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ゲーム開始ボタン
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TetrisGameScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'ゲーム開始',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                  shadowColor: Colors.black.withOpacity(0.5),
                ),
              ),

              const SizedBox(height: 20),

              // 操作方法
              const Text(
                '← → : 左右移動  ↑ : 回転  ↓ : 落下  Space : 一気に落とす',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}