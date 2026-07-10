/// Supported board sizes. Each board is square (rows == cols).
enum BoardSize {
  size2x2(rows: 2, cols: 2),
  size4x4(rows: 4, cols: 4),
  size6x6(rows: 6, cols: 6),
  size8x8(rows: 8, cols: 8);

  const BoardSize({required this.rows, required this.cols});

  final int rows;
  final int cols;

  int get totalCards => rows * cols;
  int get pairCount => totalCards ~/ 2;

  String get label => '$rows x $cols';
}
