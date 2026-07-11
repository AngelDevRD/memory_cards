/// Supported board sizes. Each board is square (rows == cols) with an even
/// side length, so totalCards is always even and every card pairs up.
///
/// Progression grows gradually from a small, approachable board up to a very
/// large 64x64 board, with bigger jumps near the end since cell count grows
/// quadratically with side length.
enum BoardSize {
  size4x4(rows: 4, cols: 4),
  size6x6(rows: 6, cols: 6),
  size8x8(rows: 8, cols: 8),
  size10x10(rows: 10, cols: 10),
  size12x12(rows: 12, cols: 12),
  size14x14(rows: 14, cols: 14),
  size16x16(rows: 16, cols: 16),
  size20x20(rows: 20, cols: 20),
  size24x24(rows: 24, cols: 24),
  size28x28(rows: 28, cols: 28),
  size32x32(rows: 32, cols: 32),
  size40x40(rows: 40, cols: 40),
  size48x48(rows: 48, cols: 48),
  size56x56(rows: 56, cols: 56),
  size64x64(rows: 64, cols: 64);

  const BoardSize({required this.rows, required this.cols});

  final int rows;
  final int cols;

  int get totalCards => rows * cols;
  int get pairCount => totalCards ~/ 2;

  String get label => '$rows x $cols';
}
