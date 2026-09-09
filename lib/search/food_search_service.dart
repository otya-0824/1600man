import '../models/food_item.dart';
import 'search_synonyms.dart';

// ============================================================
// FoodSearchService
// ============================================================
// 「かな正規化」「複数キーワードAND検索」「一般的な食材名への
// 同義語対応」を組み合わせた、ブラウザ検索のようなキーワード検索を
// 提供するサービスクラス。
// ============================================================
class FoodSearchService {
  // ------------------------------------------------------------
  // カタカナ→ひらがな正規化
  // ------------------------------------------------------------
  // ひらがなで入力してもカタカナ名にヒットし、カタカナで入力しても
  // ひらがな名にヒットするようにするための正規化。
  // 全角カタカナ(U+30A1-U+30F6)をひらがな(U+3041-U+3096)に変換し、
  // さらに小文字化・トリムして比較する。
  // ------------------------------------------------------------
  String normalizeForSearch(String input) {
    // 文字列を1文字ずつ組み立てていくための入れ物を用意する。
    // (文字列の "+=" を繰り返すより効率的なDartの標準的な書き方)
    final buffer = StringBuffer();

    // input.runes で、文字列を「1文字ずつ」(絵文字なども考慮した
    // 単位で)取り出してループする。
    for (final rune in input.runes) {
      // rune は1文字分の文字コード(数値)。
      // 0x30A1〜0x30F6 は、全角カタカナの範囲の文字コード。
      // この範囲に入っている文字だけ、ひらがなに変換する。
      if (rune >= 0x30A1 && rune <= 0x30F6) {
        // カタカナとひらがなは、文字コード上でちょうど0x60(96)
        // だけズレているため、0x60を引くとひらがなに変換できる。
        buffer.writeCharCode(rune - 0x60);
      } else {
        // カタカナ以外の文字は、そのまま追加する。
        buffer.writeCharCode(rune);
      }
    }

    // 組み立てた文字列を、すべて小文字にして(英数字混在対策)、
    // 前後の余分な空白を削ってから返す。
    return buffer.toString().toLowerCase().trim();
  }


  // ------------------------------------------------------------
  // 1つのキーワードが、正規化済みの食品名(または読み)に
  // 一致するかどうかを判定する。
  //
  // 判定は次の順番で試し、いずれか1つでも一致すればtrueを返す。
  //   1. そのまま部分一致するか
  //   2. 単独の動物名(漢字)をデータベース表記(ひらがな)に変換
  //   3. 一般的な食材名の同義語(generalSynonyms)
  //   4. 部位・加工名の同義語(partSynonyms)
  //   5. 「動物名+部位」の複合語を分解して判定
  //      (例：「鶏むね」→「にわとり」かつ「むね」)
  // ------------------------------------------------------------
  bool keywordMatches(String rawKeyword, String normalizedTarget) {
    // 検索キーワード(ひらがな/カタカナ混じり)を正規化しておく。
    // (normalizedTarget側は、呼び出し元で既に正規化済みの前提)
    final normalizedKeyword = normalizeForSearch(rawKeyword);

    // ---------- 1) そのまま部分一致 ----------
    // 例："牛乳"というキーワードが、食品名の中にそのまま
    // 含まれているかを確認する。含まれていれば即座にtrueで終了。
    if (normalizedTarget.contains(normalizedKeyword)) {
      return true;
    }

    // ---------- 2) 単独の動物名(例："鶏""牛""豚") ----------
    // animalKanjiToReadingという対応表(search_synonyms.dartで定義)
    // から、rawKeyword(元の入力、例："鶏")にあたる読み(例："にわとり")
    // を探す。無ければnullが返る。
    final directAnimalReading = animalKanjiToReading[rawKeyword];

    // directAnimalReadingがnullでない(＝対応表に載っていた)、
    // かつ、その読み(ひらがな)が食品名に含まれていればtrue。
    if (directAnimalReading != null &&
        normalizedTarget.contains(normalizeForSearch(directAnimalReading))) {
      return true;
    }

    // ---------- 3) 一般的な食材名の同義語 ----------
    // generalSynonyms(例："たまご"→["卵"])から、rawKeywordに
    // あたる候補のリストを取得する。無ければnull。
    final generalAlts = generalSynonyms[rawKeyword];

    // 候補リストが存在する場合、その中のどれか1つでも
    // 食品名に含まれていればtrue(OR条件)。
    if (generalAlts != null) {
      for (final alt in generalAlts) {
        if (normalizedTarget.contains(normalizeForSearch(alt))) {
          return true;
        }
      }
    }

    // ---------- 4) 部位・加工名の同義語 ----------
    // partSynonyms(例："手羽先"→["手羽","さき"])から、
    // rawKeywordにあたる候補のリストを取得する。
    final partAlts = partSynonyms[rawKeyword];

    // ここは3)と違い、候補リストの「すべて」が食品名に
    // 含まれていて初めてtrueにする(AND条件)。
    // .every(条件) は「リストの全要素が条件を満たすか」を調べる
    // Dartのメソッド。1つでも満たさなければfalseになる。
    if (partAlts != null &&
        partAlts.every(
          (alt) => normalizedTarget.contains(normalizeForSearch(alt)),
        )) {
      return true;
    }

    // ---------- 5) 「動物名+部位」の複合語を分解して判定 ----------
    // 例：「鶏むね」というキーワードを、
    //     動物名部分「鶏」と、残りの部分「むね」に分けて、
    //     それぞれが食品名に含まれているかを別々に確認する。
    //
    // animalKanjiToReading.entries で、対応表の
    // (キー: 動物名の表記, 値: ひらがなの読み) のペアを
    // 1つずつ順番に取り出してループする。
    for (final entry in animalKanjiToReading.entries) {
      // entry.key は動物名の表記(例："鶏"、"とり"など)。
      final animalKanji = entry.key;
      // entry.value はその読み(ひらがな、例："にわとり")。
      final animalReading = entry.value;

      // rawKeyword(例："鶏むね")が、animalKanji(例："鶏")で
      // 始まっているか、かつ、animalKanjiだけより長いか
      // (＝animalKanjiの後ろに何か文字が続いているか)を確認する。
      final isCompound = rawKeyword.startsWith(animalKanji) &&
          rawKeyword.length > animalKanji.length;

      // 複合語のパターンに当てはまらなければ、
      // このanimalKanjiでの分解は諦めて、次の候補に進む
      // (continueは「今回のループの残りを飛ばして次へ」の意味)。
      if (!isCompound) {
        continue;
      }

      // rawKeywordの先頭からanimalKanjiの文字数分を取り除いた、
      // 残りの部分を取り出す。
      // 例："鶏むね".substring(1) → "むね"
      //     ("鶏"は1文字なので、1文字目より後ろを取り出している)
      final remainder = rawKeyword.substring(animalKanji.length);

      // 「牛乳」「鶏卵」など、動物名+部位に分解してはいけない
      // 例外語をチェックする。
      // animalPrefixExceptionsからanimalKanjiに対応する例外リストを
      // 取得する(無ければ空リスト const [] を使う)。
      final exceptions = animalPrefixExceptions[animalKanji] ?? const [];

      // 残りの部分(remainder)が、例外リストのいずれかで
      // 始まっているかどうかを確認する。
      // .any(条件) は「リストの中に1つでも条件を満たす要素があるか」
      // を調べるメソッド。
      final isException =
          exceptions.any((ex) => remainder.startsWith(ex));

      // 例外に該当する場合(例："牛"+"乳"="牛乳")は、
      // このanimalKanjiでの分解を諦めて、次の候補に進む。
      if (isException) {
        continue;
      }

      // 動物名の読み(ひらがな)が、実際に食品名の中に
      // 含まれているかどうかを確認する。
      final animalMatched =
          normalizedTarget.contains(normalizeForSearch(animalReading));

      // 動物名が見つからなかった場合は、この時点でこの動物名候補は
      // 不一致確定なので、次の候補に進む。
      if (!animalMatched) {
        continue;
      }

      // 残りの部分(例："むね")について、部位の同義語辞書
      // (partSynonyms)に載っていればその変換候補を使い、
      // 載っていなければ、そのままの文字列を候補として使う。
      // ( ?? は「左側がnullだったら右側を使う」という意味)
      final remainderAlts = partSynonyms[remainder] ?? [remainder];

      // 候補のうち、どれか1つでも食品名に含まれていればtrueとする。
      final remainderMatched = remainderAlts.any(
        (alt) => normalizedTarget.contains(normalizeForSearch(alt)),
      );

      // 動物名も、残りの部分も両方見つかった場合だけ、
      // ここで一致確定としてtrueを返す。
      if (remainderMatched) {
        return true;
      }
      // 見つからなかった場合は、forループの次の動物名候補へ進む
      // (continueを書いていないが、if文を抜けると自動的に
      //  ループの次の周回に進む)。
    }

    // 1)〜5)のどの方法でも一致しなかった場合、最終的に
    // 「一致しない」ことを表すfalseを返す。
    return false;
  }


  // ------------------------------------------------------------
  // 食品検索(ブラウザ検索風：複数キーワードAND・かな正規化・
  // 一般的なキーワードへの同義語対応)
  // ------------------------------------------------------------
  List<FoodItem> search(List<FoodItem> foods, String query) {
    // 入力欄の前後の空白を取り除く。
    final trimmed = query.trim();

    // 何も入力されていなければ、検索結果なし(空リスト)を返す。
    if (trimmed.isEmpty) {
      return [];
    }

    // 半角スペース・全角スペースのどちらでも区切れるように、
    // 正規表現 [\s　]+ (1文字以上の空白の連続)で分割する。
    // 例："ご飯 卵" → ["ご飯", "卵"]
    final rawKeywords = trimmed
        .split(RegExp(r'[\s　]+'))
        .where((k) => k.isNotEmpty) // 空文字列は除外しておく
        .toList();

    // foods(全食品のリスト)から、条件に合うものだけを
    // 絞り込んで返す。.where(条件) は「条件を満たす要素だけを
    // 残す」というリスト操作。
    return foods.where((food) {
      // 比較のため、食品名をあらかじめ正規化しておく。
      final normalizedName = normalizeForSearch(food.name);
      // 読み仮名フィールドがあれば、それも正規化しておく
      // (現在のデータには無いが、将来追加された場合に備えている)。
      final normalizedReading = normalizeForSearch(food.reading);

      // rawKeywords(複数のキーワード)の「すべて」が、
      // 食品名または読みのどちらかに一致していればtrue
      // (これが複数キーワードのAND検索の実現方法)。
      // .every(条件) は「全部の要素が条件を満たすか」を調べる。
      return rawKeywords.every((k) {
        return keywordMatches(k, normalizedName) ||
            (normalizedReading.isNotEmpty &&
                keywordMatches(k, normalizedReading));
      });
    }).toList();
  }
}
