import 'package:flutter/material.dart';
import 'package:game_vault/screens/tetris_start_screen.dart';
import 'snake_game_screen.dart';

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
              'Flutter Game Vault',
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
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ヘッダー
              const Text(
                'ゲームを選択',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 50),

              // ゲーム選択ボタン
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGameCard(
                    context,
                    'テトリス',
                    Icons.grid_4x4,
                    Colors.indigo.shade400,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TetrisStartScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 30),
                  _buildGameCard(
                    context,
                    'スネーク',
                    Icons.linear_scale,
                    Colors.green.shade400,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SnakeGameScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: color,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'プレイ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
