// プロフィール情報のデータモデル
// Firestoreとのやり取り（Map⇄オブジェクト変換）をここにまとめる

class UserProfile {
  final String gender; // "male" / "female"
  final String birthDate; // "2000-1-1"
  final double? height; // cm
  final double? weight; // kg
  final String goal; // "ダイエット" など
  final double? goalWeight; // kg

  const UserProfile({
    required this.gender,
    required this.birthDate,
    required this.height,
    required this.weight,
    required this.goal,
    required this.goalWeight,
  });

  // Firestoreに書き込む用（オブジェクト → Map）
  Map<String, dynamic> toMap() {
    return {
      "gender": gender,
      "birthDate": birthDate,
      "height": height,
      "weight": weight,
      "goal": goal,
      "goalWeight": goalWeight,
    };
  }

  // Firestoreから読み込む用（Map → オブジェクト）
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      gender: map["gender"] as String? ?? "male",
      birthDate: map["birthDate"] as String? ?? "2000-1-1",
      height: (map["height"] as num?)?.toDouble(),
      weight: (map["weight"] as num?)?.toDouble(),
      goal: map["goal"] as String? ?? "ダイエット",
      goalWeight: (map["goalWeight"] as num?)?.toDouble(),
    );
  }
}
