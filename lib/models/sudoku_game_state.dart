import 'dart:math';
import '../constants/sudoku_constants.dart';

class SudokuCell {
  // セルの座標
  final int row;
  final int col;

  // セルの値と状態
  int value; // 現在の値（0は空）
  int solution; // 正解値
  bool isFixed; // 初期値か（編集不可）
  bool isSelected = false; // 選択中か
  bool isInvalid = false; // 不正な値か
  Set<int> notes = {}; // メモ（1-9のセット）

  SudokuCell({
    required this.row,
    required this.col,
    required this.value,
    required this.solution,
    required this.isFixed,
  });

  // セルの値が正しいかどうか
  bool get isCorrect => value == solution;

  // セルが空かどうか
  bool get isEmpty => value == 0;

  // セルを空にする
  void clear() {
    if (!isFixed) {
      value = 0;
      isInvalid = false;
    }
  }

  // ノートを追加または削除
  void toggleNote(int number) {
    if (isFixed) return;

    if (notes.contains(number)) {
      notes.remove(number);
    } else {
      notes.add(number);
    }
  }

  // すべてのノートを消去
  void clearNotes() {
    notes.clear();
  }
}

class SudokuGameState {
  late List<List<SudokuCell>> grid;
  SudokuDifficulty difficulty;
  InputMode inputMode = InputMode.digit;
  bool isComplete = false;
  bool hasStarted = false;
  DateTime? startTime;
  DateTime? endTime;
  int hintsUsed = 0;
  int mistakesCount = 0;
  int maxMistakesAllowed = 3;

  SudokuGameState({this.difficulty = SudokuDifficulty.easy}) {
    _generatePuzzle();
  }

  // 数独のパズルを生成する
  void _generatePuzzle() {
    // 9x9の空のグリッド
    grid = List.generate(9, (row) {
      return List.generate(9, (col) {
        return SudokuCell(
          row: row,
          col: col,
          value: 0,
          solution: 0,
          isFixed: false,
        );
      });
    });

    // ソリューションを生成
    _generateSolution();

    // 難易度に応じてセルを削除
    _removeRandomCells();

    // 固定セルをマーク
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        grid[row][col].isFixed = grid[row][col].value != 0;
      }
    }

    // 初期値をリセット
    isComplete = false;
    hasStarted = false;
    startTime = null;
    endTime = null;
    hintsUsed = 0;
    mistakesCount = 0;
  }

  // 数独の解答を生成
  void _generateSolution() {
    // 基本的な数独のソリューションを生成（バックトラッキングアルゴリズム）
    List<List<int>> solution = List.generate(9, (_) => List.filled(9, 0));

    // 最初の行をランダムに埋める
    List<int> firstRow = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    firstRow.shuffle();
    for (int i = 0; i < 9; i++) {
      solution[0][i] = firstRow[i];
    }

    // バックトラッキングで残りを埋める
    _solveSudoku(solution, 1, 0);

    // グリッドに解答をセット
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        grid[row][col].solution = solution[row][col];
        grid[row][col].value = solution[row][col];
      }
    }
  }

  // バックトラッキングで数独を解く
  bool _solveSudoku(List<List<int>> grid, int row, int col) {
    // グリッドの終わりに達した場合、解けたことになる
    if (row == 9) return true;

    // 次のセルへ
    int nextRow = (col == 8) ? row + 1 : row;
    int nextCol = (col == 8) ? 0 : col + 1;

    // すでに埋まっている場合は次へ
    if (grid[row][col] != 0) {
      return _solveSudoku(grid, nextRow, nextCol);
    }

    // このセルに1-9を試してみる
    List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    numbers.shuffle(); // ランダム性を持たせる

    for (int num in numbers) {
      if (_isValid(grid, row, col, num)) {
        grid[row][col] = num;

        if (_solveSudoku(grid, nextRow, nextCol)) {
          return true;
        }

        grid[row][col] = 0; // バックトラック
      }
    }

    return false;
  }

  // 数字が有効かどうかをチェック
  bool _isValid(List<List<int>> grid, int row, int col, int num) {
    // 行をチェック
    for (int c = 0; c < 9; c++) {
      if (grid[row][c] == num) return false;
    }

    // 列をチェック
    for (int r = 0; r < 9; r++) {
      if (grid[r][col] == num) return false;
    }

    // 3x3ボックスをチェック
    int boxRow = (row ~/ 3) * 3;
    int boxCol = (col ~/ 3) * 3;

    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (grid[boxRow + r][boxCol + c] == num) return false;
      }
    }

    return true;
  }

  // 難易度に応じてセルをランダムに削除
  void _removeRandomCells() {
    int cellsToRemove = SudokuConstants.difficultyCellsToRemove[difficulty]!;
    Random random = Random();

    while (cellsToRemove > 0) {
      int row = random.nextInt(9);
      int col = random.nextInt(9);

      if (grid[row][col].value != 0) {
        grid[row][col].value = 0;
        cellsToRemove--;
      }
    }
  }

  // セルを選択する
  void selectCell(int row, int col) {
    // 前の選択を解除
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        grid[r][c].isSelected = false;
      }
    }

    // 新しいセルを選択
    grid[row][col].isSelected = true;

    // ゲームスタート
    if (!hasStarted) {
      hasStarted = true;
      startTime = DateTime.now();
    }
  }

  // 選択中のセルに数字を入力
  void enterNumber(int number) {
    if (isComplete) return;

    SudokuCell? selectedCell;

    // 選択中のセルを見つける
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col].isSelected) {
          selectedCell = grid[row][col];
          break;
        }
      }
    }

    if (selectedCell == null || selectedCell.isFixed) return;

    if (inputMode == InputMode.digit) {
      // 数字モード
      selectedCell.value = number;
      selectedCell.clearNotes();

      // 間違いをチェック
      if (number != 0 && number != selectedCell.solution) {
        selectedCell.isInvalid = true;
        mistakesCount++;

        // 最大ミス数に達したらゲームオーバーとする
        if (mistakesCount >= maxMistakesAllowed) {
          // TODO: ゲームオーバー処理
        }
      } else {
        selectedCell.isInvalid = false;
      }

      // ゲーム完了をチェック
      checkCompletion();
    } else {
      // メモモード
      if (number != 0) {
        selectedCell.toggleNote(number);
      }
    }
  }

  // ヒントを使う
  void useHint() {
    if (isComplete) return;

    SudokuCell? selectedCell;

    // 選択中のセルを見つける
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col].isSelected) {
          selectedCell = grid[row][col];
          break;
        }
      }
    }

    if (selectedCell == null ||
        selectedCell.isFixed ||
        selectedCell.value == selectedCell.solution) return;

    // ヒントとして正解を入力
    selectedCell.value = selectedCell.solution;
    selectedCell.clearNotes();
    selectedCell.isInvalid = false;
    hintsUsed++;

    // ゲーム完了をチェック
    checkCompletion();
  }

  // 選択中のセルをクリア
  void clearSelectedCell() {
    if (isComplete) return;

    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col].isSelected && !grid[row][col].isFixed) {
          grid[row][col].clear();
          grid[row][col].clearNotes();
          break;
        }
      }
    }
  }

  // 入力モードを切り替える
  void toggleInputMode() {
    inputMode =
        (inputMode == InputMode.digit) ? InputMode.notes : InputMode.digit;
  }

  // ゲームが完了しているかチェック
  void checkCompletion() {
    bool complete = true;

    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        SudokuCell cell = grid[row][col];

        if (cell.value != cell.solution) {
          complete = false;
          break;
        }
      }
      if (!complete) break;
    }

    if (complete) {
      isComplete = true;
      endTime = DateTime.now();
    }
  }

  // 経過時間を取得
  Duration getElapsedTime() {
    if (!hasStarted) return Duration.zero;
    if (endTime != null) return endTime!.difference(startTime!);
    return DateTime.now().difference(startTime!);
  }

  // パズルをリセット
  void resetPuzzle() {
    _generatePuzzle();
  }

  // 難易度を変更して新しいパズルを生成
  void changeDifficulty(SudokuDifficulty newDifficulty) {
    difficulty = newDifficulty;
    resetPuzzle();
  }
}
