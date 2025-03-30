import 'package:flutter/material.dart';

// ゲームボードの描画
class TetrisPainter extends CustomPainter {
  final List<List<int>> board;
  final List<Color> colors;
  final List<List<int>> currentPiece;
  final int currentPieceRow;
  final int currentPieceCol;
  final Color currentColor;
  final Function(List<List<int>>, int, int) checkCollision;

  TetrisPainter({
    required this.board,
    required this.colors,
    required this.currentPiece,
    required this.currentPieceRow,
    required this.currentPieceCol,
    required this.currentColor,
    required this.checkCollision,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cellWidth = size.width / board[0].length;
    final double cellHeight = size.height / board.length;

    // 背景のグリッド線を描画
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int r = 0; r <= board.length; r++) {
      canvas.drawLine(
        Offset(0, r * cellHeight),
        Offset(size.width, r * cellHeight),
        gridPaint,
      );
    }

    for (int c = 0; c <= board[0].length; c++) {
      canvas.drawLine(
        Offset(c * cellWidth, 0),
        Offset(c * cellWidth, size.height),
        gridPaint,
      );
    }

    // ボードの描画
    for (int r = 0; r < board.length; r++) {
      for (int c = 0; c < board[r].length; c++) {
        if (board[r][c] != 0) {
          final Color blockColor = colors[board[r][c] - 1];

          // ブロックの本体
          final rect = Rect.fromLTWH(
            c * cellWidth + 1,
            r * cellHeight + 1,
            cellWidth - 2,
            cellHeight - 2,
          );

          final RRect roundedRect =
              RRect.fromRectAndRadius(rect, const Radius.circular(4.0));

          // グラデーションで立体感を出す
          final paint = Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                blockColor.withOpacity(1.0),
                blockColor.withOpacity(0.7),
              ],
            ).createShader(rect);

          canvas.drawRRect(roundedRect, paint);

          // ハイライト（上部と左側に光沢）
          final highlightPaint = Paint()
            ..color = Colors.white.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;

          final Path highlightPath = Path()
            ..moveTo(rect.left + 2, rect.bottom - 2)
            ..lineTo(rect.left + 2, rect.top + 2)
            ..lineTo(rect.right - 2, rect.top + 2);

          canvas.drawPath(highlightPath, highlightPaint);

          // 内側の境界線
          final borderPaint = Paint()
            ..color = Colors.black.withOpacity(0.2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0;

          canvas.drawRRect(roundedRect, borderPaint);
        }
      }
    }

    // 現在落下中のピースの描画（固定ブロックと同じスタイルで）
    for (int r = 0; r < currentPiece.length; r++) {
      for (int c = 0; c < currentPiece[r].length; c++) {
        if (currentPiece[r][c] != 0) {
          int boardRow = currentPieceRow + r;
          int boardCol = currentPieceCol + c;

          if (boardRow >= 0) {
            final rect = Rect.fromLTWH(
              boardCol * cellWidth + 1,
              boardRow * cellHeight + 1,
              cellWidth - 2,
              cellHeight - 2,
            );

            final RRect roundedRect =
                RRect.fromRectAndRadius(rect, const Radius.circular(4.0));

            // グラデーションで立体感を出す
            final paint = Paint()
              ..shader = LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  currentColor.withOpacity(1.0),
                  currentColor.withOpacity(0.7),
                ],
              ).createShader(rect);

            canvas.drawRRect(roundedRect, paint);

            // ハイライト（上部と左側に光沢）
            final highlightPaint = Paint()
              ..color = Colors.white.withOpacity(0.3)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5;

            final Path highlightPath = Path()
              ..moveTo(rect.left + 2, rect.bottom - 2)
              ..lineTo(rect.left + 2, rect.top + 2)
              ..lineTo(rect.right - 2, rect.top + 2);

            canvas.drawPath(highlightPath, highlightPaint);

            // 内側の境界線
            final borderPaint = Paint()
              ..color = Colors.black.withOpacity(0.2)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0;

            canvas.drawRRect(roundedRect, borderPaint);
          }
        }
      }
    }

    // 落下予測位置の表示
    int shadowRow = currentPieceRow;
    while (!checkCollision(currentPiece, shadowRow + 1, currentPieceCol)) {
      shadowRow++;
    }

    if (shadowRow != currentPieceRow) {
      for (int r = 0; r < currentPiece.length; r++) {
        for (int c = 0; c < currentPiece[r].length; c++) {
          if (currentPiece[r][c] != 0) {
            int boardRow = shadowRow + r;
            int boardCol = currentPieceCol + c;

            if (boardRow >= 0) {
              final rect = Rect.fromLTWH(
                boardCol * cellWidth + 1,
                boardRow * cellHeight + 1,
                cellWidth - 2,
                cellHeight - 2,
              );

              final RRect roundedRect =
                  RRect.fromRectAndRadius(rect, const Radius.circular(4.0));

              // 薄い色で予測位置を表示
              final shadowPaint = Paint()
                ..color = currentColor.withOpacity(0.2)
                ..style = PaintingStyle.fill;

              canvas.drawRRect(roundedRect, shadowPaint);

              // 点線の境界線
              final dashPaint = Paint()
                ..color = currentColor.withOpacity(0.5)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.0;

              canvas.drawRRect(roundedRect, dashPaint);
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(TetrisPainter oldDelegate) {
    return true;
  }
}

class NextPiecePainter extends CustomPainter {
  final List<List<int>> piece;
  final Color color;

  NextPiecePainter({
    required this.piece,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = size.width / 4;

    for (int r = 0; r < piece.length; r++) {
      for (int c = 0; c < piece[r].length; c++) {
        if (piece[r][c] != 0) {
          final rect = Rect.fromLTWH(
            c * cellSize,
            r * cellSize,
            cellSize - 1,
            cellSize - 1,
          );

          final paint = Paint()
            ..color = color
            ..style = PaintingStyle.fill;

          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(2)),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(NextPiecePainter oldDelegate) {
    return piece != oldDelegate.piece || color != oldDelegate.color;
  }
}
