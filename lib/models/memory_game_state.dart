import '../constants/memory_card_constants.dart';
import 'package:flutter/material.dart';

class MemoryCard {
  final int id;
  final IconData icon;
  final int pairId; // マッチング用のID
  CardState state;

  MemoryCard({
    required this.id,
    required this.icon,
    required this.pairId,
    this.state = CardState.hidden,
  });

  bool get isHidden => state == CardState.hidden;
  bool get isRevealed => state == CardState.revealed;
  bool get isMatched => state == CardState.matched;

  MemoryCard copyWith({CardState? state}) {
    return MemoryCard(
      id: id,
      icon: icon,
      pairId: pairId,
      state: state ?? this.state,
    );
  }
}

class MemoryGameState {
  late List<MemoryCard> cards;
  MemoryCardTheme theme;
  DifficultyLevel difficulty;
  int moves = 0;
  int matchedPairs = 0;
  int firstCardIndex = -1; // 1枚目に選択されたカードのインデックス
  bool isGameComplete = false;
  int remainingSeconds = 0; // 残り時間
  bool isTimeOut = false;
  DateTime? startTime;
  int totalCards = 0;
  int requiredPairs = 0;

  MemoryGameState({
    this.difficulty = DifficultyLevel.easy,
    MemoryCardTheme? theme,
  }) : theme = theme ?? MemoryCardConstants.themes[0] {
    _initializeGame();
  }

  void _initializeGame() {
    final settings = MemoryCardConstants.difficultySettings[difficulty]!;
    requiredPairs = settings.pairCount;
    totalCards = requiredPairs * 2;
    
    // テーマからアイコンを選択
    final availableIcons = List<IconData>.from(theme.iconPairs);
    availableIcons.shuffle(); // ランダムに並び替え
    
    // 難易度に応じたアイコンを選択（重複なく）
    final selectedIcons = <IconData>[];
    
    // アイコン数が必要ペア数より少ない場合
    if (availableIcons.length < requiredPairs) {
      print('Warning: Not enough unique icons (${availableIcons.length}) for required pairs ($requiredPairs)');
      
      // まず全てのアイコンを使用
      selectedIcons.addAll(availableIcons);
      
      // 残りは新しいシャッフルセットから足りない分だけ追加
      final remainingCount = requiredPairs - selectedIcons.length;
      final extraIcons = List<IconData>.from(theme.iconPairs);
      extraIcons.shuffle();
      
      // すでに選ばれたアイコンは除外
      extraIcons.removeWhere((icon) => selectedIcons.contains(icon));
      
      // 必要な数だけ追加
      selectedIcons.addAll(extraIcons.take(remainingCount));
    } else {
      // 十分なアイコンがある場合は、必要な数だけ取得
      selectedIcons.addAll(availableIcons.take(requiredPairs));
    }
    
    // ペアを作成
    cards = [];
    for (int i = 0; i < requiredPairs; i++) {
      final icon = selectedIcons[i];
      
      // 各ペアに2枚のカードを追加
      cards.add(
        MemoryCard(
          id: i * 2,
          icon: icon,
          pairId: i,
        ),
      );
      
      cards.add(
        MemoryCard(
          id: i * 2 + 1,
          icon: icon,
          pairId: i,
        ),
      );
    }
    
    // カードをシャッフル
    cards.shuffle();
    
    // 状態のリセット
    moves = 0;
    matchedPairs = 0;
    firstCardIndex = -1;
    isGameComplete = false;
    isTimeOut = false;
    remainingSeconds = settings.timeLimit;
    startTime = null;
  }
  
  // カードの選択処理
  bool selectCard(int index) {
    if (isGameComplete || isTimeOut) return false;
    if (index < 0 || index >= cards.length) return false;
    
    final card = cards[index];
    
    // 既に開いているカードや、マッチングしたカードは選択できない
    if (!card.isHidden) return false;
    
    // ゲーム開始時間の記録
    if (startTime == null) {
      startTime = DateTime.now();
    }
    
    if (firstCardIndex == -1) {
      // 1枚目のカードを選択
      firstCardIndex = index;
      cards[index] = card.copyWith(state: CardState.revealed);
      return true;
    } else {
      // 2枚目のカードを選択
      final firstCard = cards[firstCardIndex];
      cards[index] = card.copyWith(state: CardState.revealed);
      
      // 手数をカウント
      moves++;
      
      // マッチング判定
      if (firstCard.pairId == card.pairId) {
        // マッチした場合
        cards[firstCardIndex] = firstCard.copyWith(state: CardState.matched);
        cards[index] = card.copyWith(state: CardState.matched);
        matchedPairs++;
        
        // すべてのペアがマッチしたらゲーム完了
        if (matchedPairs == requiredPairs) {
          isGameComplete = true;
        }
      }
      
      // 1枚目のカード選択をリセット
      firstCardIndex = -1;
      return true;
    }
  }
  
  // マッチしなかったカードを裏返す
  void hideUnmatchedCards() {
    for (int i = 0; i < cards.length; i++) {
      if (cards[i].isRevealed) {
        cards[i] = cards[i].copyWith(state: CardState.hidden);
      }
    }
  }
  
  // 時間の更新処理
  void updateRemainingTime() {
    if (startTime == null || isGameComplete || isTimeOut) return;
    
    final settings = MemoryCardConstants.difficultySettings[difficulty]!;
    final elapsedSeconds = DateTime.now().difference(startTime!).inSeconds;
    remainingSeconds = settings.timeLimit - elapsedSeconds;
    
    if (remainingSeconds <= 0) {
      remainingSeconds = 0;
      isTimeOut = true;
    }
  }
  
  // スコアの計算
  int calculateScore() {
    if (!isGameComplete) return 0;
    
    final settings = MemoryCardConstants.difficultySettings[difficulty]!;
    final baseScore = settings.pairCount * 100; // ペア数によるベーススコア
    final timeBonus = (remainingSeconds / settings.timeLimit * 500).round(); // 残り時間ボーナス
    final moveEfficiency = requiredPairs * 2; // 理論上の最小手数
    final moveRatio = moveEfficiency / moves; // 効率比率
    final moveBonus = (moveRatio * 500).round(); // 効率ボーナス
    
    return baseScore + timeBonus + moveBonus;
  }
  
  // 難易度変更
  void changeDifficulty(DifficultyLevel newDifficulty) {
    difficulty = newDifficulty;
    _initializeGame();
  }
  
  // テーマ変更
  void changeTheme(MemoryCardTheme newTheme) {
    theme = newTheme;
    _initializeGame();
  }
  
  // ゲームのリセット
  void resetGame() {
    _initializeGame();
  }
  
  // 制限時間のフォーマット
  String formatRemainingTime() {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
