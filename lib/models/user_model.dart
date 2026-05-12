class UserModel {
  final String name;
  final int matchesPlayed;
  final int matchesWon;
  final String? profilePath;

  UserModel({
    required this.name,
    this.matchesPlayed = 0,
    this.matchesWon = 0,
    this.profilePath,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'matchesPlayed': matchesPlayed,
        'matchesWon': matchesWon,
        'profilePath': profilePath,
      };

  factory UserModel.fromJson(Map<dynamic, dynamic> json) => UserModel(
        name: json['name'] as String,
        matchesPlayed: json['matchesPlayed'] as int? ?? 0,
        matchesWon: json['matchesWon'] as int? ?? 0,
        profilePath: json['profilePath'] as String?,
      );

  double get winPercentage =>
      matchesPlayed == 0 ? 0 : (matchesWon / matchesPlayed) * 100;
}

class GameHistory {
  final String date;
  final String mode;
  final bool isWin;
  final String playerColor;

  GameHistory({
    required this.date,
    required this.mode,
    required this.isWin,
    required this.playerColor,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'mode': mode,
        'isWin': isWin,
        'playerColor': playerColor,
      };

  factory GameHistory.fromJson(Map<dynamic, dynamic> json) => GameHistory(
        date: json['date'] as String,
        mode: json['mode'] as String,
        isWin: json['isWin'] as bool,
        playerColor: json['playerColor'] as String,
      );
}
