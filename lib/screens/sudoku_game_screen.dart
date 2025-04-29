import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/sudoku_constants.dart';
import '../models/sudoku_game_state.dart';

class SudokuGameScreen extends StatefulWidget {
  const SudokuGameScreen({Key? key}) : super(key: key);

  @override
  State<SudokuGameScreen> createState() => _SudokuGameScreenState();
}

class _SudokuGameScreenState extends State<SudokuGameScreen> {
  late SudokuGameState gameState;
  late Timer _timer;
  int _elapsedSeconds = 0;
  String _statusMessage = '';
  bool _showStatusMessage = false;
  
  @override
  void initState() {
    super.initState();
    gameState = SudokuGameState();
    _startTimer();
  }
  
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && gameState.hasStarted && !gameState.isComplete) {
        setState(() {
          _elapsedSeconds = gameState.getElapsedTime().inSeconds;
        });
      }
    });
  }
  
  void _showMessage(String message) {
    setState(() {
      _statusMessage = message;
      _showStatusMessage = true;
    });
    
    // 3秒後にメッセージを非表示にする
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showStatusMessage = false;
        });
      }
    });
  }
  
  void _selectCell(int row, int col) {
    setState(() {
      gameState.selectCell(row, col);
    });
  }
  
  void _enterNumber(int number) {
    setState(() {
      gameState.enterNumber(number);
      
      if (gameState.isComplete) {
        _showMessage('パズル完成！おめでとう！');
      }
    });
  }
  
  void _useHint() {
    setState(() {
      gameState.useHint();
      _showMessage('ヒントを使用しました');
      
      if (gameState.isComplete) {
        _showMessage('パズル完成！おめでとう！');
      }
    });
  }
  
  void _clearSelectedCell() {
    setState(() {
      gameState.clearSelectedCell();
      _showMessage('セルをクリアしました');
    });
  }
  
  void _toggleInputMode() {
    setState(() {
      gameState.toggleInputMode();
      _showMessage(
        gameState.inputMode == InputMode.digit 
        ? '入力モード: 数字' 
        : '入力モード: メモ'
      );
    });
  }
  
  void _resetPuzzle() {
    setState(() {
      gameState.resetPuzzle();
      _elapsedSeconds = 0;
      _showMessage('パズルをリセットしました');
    });
  }
  
  void _changeDifficulty(SudokuDifficulty difficulty) {
    setState(() {
      gameState.changeDifficulty(difficulty);
      _elapsedSeconds = 0;
      
      String difficultyText = '';
      switch (difficulty) {
        case SudokuDifficulty.easy:
          difficultyText = '初級';
          break;
        case SudokuDifficulty.medium:
          difficultyText = '中級';
          break;
        case SudokuDifficulty.hard:
          difficultyText = '上級';
          break;
        case SudokuDifficulty.expert:
          difficultyText = '達人';
          break;
      }
      
      _showMessage('難易度を$difficultyTextに変更しました');
    });
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final gridSize = size.width - 32;
    // セルサイズを若干小さくして余裕を持たせる
    final cellSize = (gridSize / 9) - 0.5;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('数独'),
        centerTitle: true,
        actions: [
          PopupMenuButton<SudokuDifficulty>(
            icon: const Icon(Icons.settings),
            onSelected: _changeDifficulty,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SudokuDifficulty.easy,
                child: Text('初級'),
              ),
              const PopupMenuItem(
                value: SudokuDifficulty.medium,
                child: Text('中級'),
              ),
              const PopupMenuItem(
                value: SudokuDifficulty.hard,
                child: Text('上級'),
              ),
              const PopupMenuItem(
                value: SudokuDifficulty.expert,
                child: Text('達人'),
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
              color: SudokuConstants.accentColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 経過時間
                Column(
                  children: [
                    const Icon(Icons.timer, color: Colors.white),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(_elapsedSeconds),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                // 残りミス回数
                Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(height: 4),
                    Text(
                      '${gameState.maxMistakesAllowed - gameState.mistakesCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                // モード
                Column(
                  children: [
                    Icon(
                      gameState.inputMode == InputMode.digit 
                      ? Icons.edit 
                      : Icons.edit_note,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gameState.inputMode == InputMode.digit 
                      ? '数字モード' 
                      : 'メモモード',
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
          
          // ステータスメッセージ
          if (_showStatusMessage)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SudokuConstants.selectedCellColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusMessage,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
          // ゲーム完了表示
          if (gameState.isComplete)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                children: [
                  const Text(
                    'パズル完成！',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '時間: ${_formatTime(_elapsedSeconds)}  ヒント: ${gameState.hintsUsed}回  ミス: ${gameState.mistakesCount}回',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _resetPuzzle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SudokuConstants.accentColor,
                    ),
                    child: const Text('新しいパズル'),
                  ),
                ],
              ),
            ),
          
          // 数独グリッド
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: gridSize,
                  height: gridSize,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 垂直方向のマージンを小さく
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: SudokuConstants.gridLineColor,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(9, (row) {
                      return Row(
                        mainAxisSize: MainAxisSize.max, // minからmaxに変更
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 均等に配置
                        children: List.generate(9, (col) {
                          return _buildCell(row, col, cellSize);
                        }),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
          
          // 数字入力パッド
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 数字ボタン
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: List.generate(9, (index) {
                      final number = index + 1;
                      return Container(
                        margin: SudokuConstants.digitButtonMargin,
                        width: SudokuConstants.digitButtonSize,
                        height: SudokuConstants.digitButtonSize,
                        child: ElevatedButton(
                          onPressed: () => _enterNumber(number),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: SudokuConstants.accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            '$number',
                            style: const TextStyle(
                              fontSize: SudokuConstants.digitButtonFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                
                // 操作ボタン
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // クリアボタン
                    IconButton(
                      onPressed: _clearSelectedCell,
                      icon: const Icon(Icons.backspace),
                      tooltip: 'クリア',
                      color: Colors.red,
                    ),
                    // モード切り替えボタン
                    IconButton(
                      onPressed: _toggleInputMode,
                      icon: Icon(
                        gameState.inputMode == InputMode.digit 
                        ? Icons.edit_note 
                        : Icons.edit,
                      ),
                      tooltip: 'モード切替',
                      color: Colors.blue,
                    ),
                    // ヒントボタン
                    IconButton(
                      onPressed: _useHint,
                      icon: const Icon(Icons.lightbulb),
                      tooltip: 'ヒント',
                      color: Colors.amber,
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
  
  Widget _buildCell(int row, int col, double cellSize) {
    final cell = gameState.grid[row][col];
    
    // セルの背景色を決定
    Color backgroundColor = SudokuConstants.backgroundColor;
    
    // 選択中のセル
    if (cell.isSelected) {
      backgroundColor = SudokuConstants.selectedCellColor;
    }
    // 3x3ブロックの背景色を交互に
    else if ((row ~/ 3 + col ~/ 3) % 2 == 0) {
      backgroundColor = backgroundColor.withOpacity(0.8);
    }
    
    // テキストの色を決定
    Color textColor = SudokuConstants.defaultNumberColor;
    
    if (cell.isFixed) {
      textColor = SudokuConstants.fixedNumberColor;
    } else if (cell.isInvalid) {
      textColor = SudokuConstants.invalidNumberColor;
    }
    
    // 太線の境界を描画
    Border border = Border(
      top: BorderSide(
        width: row % 3 == 0 ? 2 : 0.5,
        color: SudokuConstants.gridLineColor,
      ),
      left: BorderSide(
        width: col % 3 == 0 ? 2 : 0.5,
        color: SudokuConstants.gridLineColor,
      ),
      right: BorderSide(
        width: col % 3 == 2 || col == 8 ? 2 : 0.5,
        color: SudokuConstants.gridLineColor,
      ),
      bottom: BorderSide(
        width: row % 3 == 2 || row == 8 ? 2 : 0.5,
        color: SudokuConstants.gridLineColor,
      ),
    );
    
    return GestureDetector(
      onTap: () => _selectCell(row, col),
      child: Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: border,
        ),
        child: SizedBox(
          width: cellSize,
          height: cellSize,
          child: cell.isEmpty
              ? (cell.notes.isNotEmpty
                  ? _buildNotes(cell.notes)
                  : null)
              : Center(
                  child: Text(
                    '${cell.value}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: cell.isFixed
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
  
  Widget _buildNotes(Set<int> notes) {
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(2),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(9, (index) {
        final number = index + 1;
        return notes.contains(number)
            ? Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 10,
                    color: SudokuConstants.defaultNumberColor.withOpacity(0.7),
                  ),
                ),
              )
            : const SizedBox.shrink();
      }),
    );
  }
}
