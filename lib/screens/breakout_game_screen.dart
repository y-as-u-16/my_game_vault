import 'package:flutter/material.dart';
import 'dart:async';
import '../models/breakout_game_state.dart';
import '../painters/breakout_painter.dart';

class BreakoutGameScreen extends StatefulWidget {
  const BreakoutGameScreen({super.key});

  @override
  State<BreakoutGameScreen> createState() => _BreakoutGameScreenState();
}

class _BreakoutGameScreenState extends State<BreakoutGameScreen> {
  late BreakoutGameState gameState;
  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      gameState = BreakoutGameState(
        screenWidth: size.width,
        screenHeight: size.height -
            MediaQuery.of(context).padding.top -
            kToolbarHeight -
            MediaQuery.of(context).padding.bottom,
      );
      setState(() {});

      // ゲームループ
      gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
        if (mounted) {
          setState(() {
            gameState.update(Size(
              size.width,
              size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight -
                  MediaQuery.of(context).padding.bottom,
            ));
          });
        }
      });
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (gameState.hasGameStarted) {
      setState(() {
        final size = MediaQuery.of(context).size;
        gameState.updatePaddlePosition(
          details.delta.dx,
          size.width,
        );
      });
    }
  }

  void _handleTap() {
    if (!gameState.hasGameStarted && !gameState.isGameOver) {
      setState(() {
        gameState.startGame();
      });
    } else if (gameState.isGameOver) {
      setState(() {
        final size = MediaQuery.of(context).size;
        gameState.resetGame(
          screenWidth: size.width,
          screenHeight: size.height -
              MediaQuery.of(context).padding.top -
              kToolbarHeight -
              MediaQuery.of(context).padding.bottom,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ブレックアウト'),
        centerTitle: true,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: _handleTap,
        onPanUpdate: _handlePanUpdate,
        child: Container(
          color: const Color(0xFF16213E),
          child: CustomPaint(
            painter: BreakoutPainter(gameState),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}
