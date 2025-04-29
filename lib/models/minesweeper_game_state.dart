import 'dart:math';
import '../constants/minesweeper_constants.dart';

class Cell {
  final int row;
  final int col;
  final bool isMine;
  int adjacentMines;
  CellState state;

  Cell({
    required this.row,
    required this.col,
    this.isMine = false,
    this.adjacentMines = 0,
    this.state = CellState.covered,
  });

  Cell copyWith({
    bool? isMine,
    int? adjacentMines,
    CellState? state,
  }) {
    return Cell(
      row: row,
      col: col,
      isMine: isMine ?? this.isMine,
      adjacentMines: adjacentMines ?? this.adjacentMines,
      state: state ?? this.state,
    );
  }

  CellContent get content {
    if (isMine) return CellContent.mine;
    if (adjacentMines > 0) return CellContent.number;
    return CellContent.empty;
  }
}

class MinesweeperGameState {
  late List<List<Cell>> grid;
  late DifficultyLevel difficulty;
  bool isFirstClick = true;
  bool isGameOver = false;
  bool isWin = false;
  int flagsUsed = 0;
  DateTime? startTime;
  DateTime? endTime;
  late int totalMines;
  late int rows;
  late int columns;

  MinesweeperGameState({DifficultyLevel difficulty = DifficultyLevel.easy}) {
    this.difficulty = difficulty;
    _initializeGame();
  }

  void _initializeGame() {
    // 難易度に基づいて設定を取得
    final settings = DifficultySettings.difficultyMap[difficulty]!;
    rows = settings.rows;
    columns = settings.columns;
    totalMines = settings.mines;
    flagsUsed = 0;
    isFirstClick = true;
    isGameOver = false;
    isWin = false;
    startTime = null;
    endTime = null;

    // 空のグリッドを作成
    grid = List.generate(
      rows,
      (row) => List.generate(
        columns,
        (col) => Cell(row: row, col: col),
      ),
    );
  }

  void _placeMines(int startRow, int startCol) {
    // 最初にクリックした場所とその周囲には地雷を置かない
    final safeCells = <String>{};
    for (int r = max(0, startRow - 1); r <= min(rows - 1, startRow + 1); r++) {
      for (int c = max(0, startCol - 1); c <= min(columns - 1, startCol + 1); c++) {
        safeCells.add('$r,$c');
      }
    }

    // 地雷をランダムに配置
    final random = Random();
    int minesPlaced = 0;
    while (minesPlaced < totalMines) {
      final row = random.nextInt(rows);
      final col = random.nextInt(columns);
      final cellKey = '$row,$col';

      // 安全エリアでなく、まだ地雷がない場所に地雷を設置
      if (!safeCells.contains(cellKey) && !grid[row][col].isMine) {
        grid[row][col] = grid[row][col].copyWith(isMine: true);
        minesPlaced++;
      }
    }

    // 隣接する地雷の数を計算
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        if (!grid[row][col].isMine) {
          int count = _countAdjacentMines(row, col);
          grid[row][col] = grid[row][col].copyWith(adjacentMines: count);
        }
      }
    }
  }

  int _countAdjacentMines(int row, int col) {
    int count = 0;
    for (int r = max(0, row - 1); r <= min(rows - 1, row + 1); r++) {
      for (int c = max(0, col - 1); c <= min(columns - 1, col + 1); c++) {
        if (grid[r][c].isMine) count++;
      }
    }
    return count;
  }

  void revealCell(int row, int col) {
    // ゲームオーバーまたは既に開かれているセルは無視
    if (isGameOver || grid[row][col].state == CellState.revealed) return;

    // フラグが立っているセルは開けない
    if (grid[row][col].state == CellState.flagged) return;

    // 初回クリック時に地雷を配置
    if (isFirstClick) {
      isFirstClick = false;
      startTime = DateTime.now();
      _placeMines(row, col);
    }

    // セルを開く
    grid[row][col] = grid[row][col].copyWith(state: CellState.revealed);

    // 地雷をクリックした場合はゲームオーバー
    if (grid[row][col].isMine) {
      isGameOver = true;
      isWin = false;
      endTime = DateTime.now();
      _revealAllMines();
      return;
    }

    // 周囲に地雷がない場合は隣接するセルも開く
    if (grid[row][col].adjacentMines == 0) {
      _revealAdjacentCells(row, col);
    }

    // 勝利条件をチェック
    _checkWinCondition();
  }

  void toggleFlag(int row, int col) {
    // ゲームオーバーまたは既に開かれているセルは無視
    if (isGameOver || grid[row][col].state == CellState.revealed) return;

    Cell cell = grid[row][col];
    
    if (cell.state == CellState.covered) {
      // フラグを立てる（利用可能なフラグ数を超えないように）
      if (flagsUsed < totalMines) {
        grid[row][col] = cell.copyWith(state: CellState.flagged);
        flagsUsed++;
      }
    } else if (cell.state == CellState.flagged) {
      // ?マークにする
      grid[row][col] = cell.copyWith(state: CellState.questioned);
      flagsUsed--;
    } else if (cell.state == CellState.questioned) {
      // カバーに戻す
      grid[row][col] = cell.copyWith(state: CellState.covered);
    }
  }

  void _revealAdjacentCells(int row, int col) {
    for (int r = max(0, row - 1); r <= min(rows - 1, row + 1); r++) {
      for (int c = max(0, col - 1); c <= min(columns - 1, col + 1); c++) {
        Cell cell = grid[r][c];
        if (cell.state == CellState.covered || cell.state == CellState.questioned) {
          revealCell(r, c);
        }
      }
    }
  }

  void _revealAllMines() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        if (grid[row][col].isMine) {
          grid[row][col] = grid[row][col].copyWith(state: CellState.revealed);
        }
      }
    }
  }

  void _checkWinCondition() {
    // 勝利条件：地雷以外のすべてのセルが開かれている
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        Cell cell = grid[row][col];
        if (!cell.isMine && cell.state != CellState.revealed) {
          return; // まだすべてのセルが開かれていない
        }
      }
    }
    
    // すべての非地雷セルが開かれていたら勝利
    isGameOver = true;
    isWin = true;
    endTime = DateTime.now();
  }

  int getRemainingMines() {
    return totalMines - flagsUsed;
  }

  Duration getElapsedTime() {
    if (startTime == null) return Duration.zero;
    if (endTime != null) return endTime!.difference(startTime!);
    return DateTime.now().difference(startTime!);
  }

  void restartGame() {
    _initializeGame();
  }

  void changeDifficulty(DifficultyLevel newDifficulty) {
    difficulty = newDifficulty;
    _initializeGame();
  }
}
