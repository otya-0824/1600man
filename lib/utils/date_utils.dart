// ============================================================
// calculateAgeFromBirthDate
// ============================================================
// "yyyy-M-d" 形式の生年月日文字列(例："2006-3-6")から、
// 現在の満年齢を計算する。
//
// 月・日を考慮し、まだ誕生日を迎えていない場合は1歳引く
// (例：1月生まれでなければ、単純な年数の引き算だと
//  誕生日前でも1歳多く数えてしまうため)。
//
// 想定フォーマットは "yyyy-M-d" のみ(登録係のフロントと合意済み)。
// 想定外の形式が渡された場合は FormatException を投げる。
// ============================================================
int calculateAgeFromBirthDate(String birthDate, {DateTime? now}) {
  final parts = birthDate.split('-');

  if (parts.length != 3) {
    throw FormatException(
      '生年月日の形式が不正です(期待:"yyyy-M-d"): $birthDate',
    );
  }

  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);

  if (year == null || month == null || day == null) {
    throw FormatException(
      '生年月日の形式が不正です(期待:"yyyy-M-d"): $birthDate',
    );
  }

  final birth = DateTime(year, month, day);
  final today = now ?? DateTime.now();

  var age = today.year - birth.year;

  final birthdayHasNotOccurredYet = today.month < birth.month ||
      (today.month == birth.month && today.day < birth.day);

  if (birthdayHasNotOccurredYet) {
    age -= 1;
  }

  return age;
}
