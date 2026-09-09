// ============================================================
// 数値を安全に double に変換するユーティリティ
// ============================================================
// JSONの食品データには「未測定」「Tr(微量)」「(11.3)」のような
// 数値以外の表記が混ざっているため、それらを安全に0.0へ丸める。
// ============================================================
double toDouble(dynamic value) {
  if (value == null) {
    return 0.0;
  }

  // もともと数値の場合
  if (value is num) {
    return value.toDouble();
  }

  // 文字列の場合
  if (value is String) {
    String text = value.trim();

    // "(11.3)" のような表記に対応
    if (text.startsWith('(') && text.endsWith(')')) {
      text = text.substring(1, text.length - 1).trim();
    }

    // 未測定・空欄など
    if (text.isEmpty || text == '-' || text == 'Tr') {
      return 0.0;
    }

    return double.tryParse(text) ?? 0.0;
  }

  return 0.0;
}
