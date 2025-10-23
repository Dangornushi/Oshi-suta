import 'package:flutter/material.dart';

/// Club theme configuration with colors and gradients
class ClubTheme {
  final String clubId;
  final String clubName;
  final LinearGradient gradient;
  final Color primaryColor;
  final Color secondaryColor;
  final Color lightColor;

  const ClubTheme({
    required this.clubId,
    required this.clubName,
    required this.gradient,
    required this.primaryColor,
    required this.secondaryColor,
    required this.lightColor,
  });

  /// Get club theme by club ID
  static ClubTheme getTheme(String clubId) {
    return _clubThemes[clubId] ?? _defaultTheme;
  }

  /// Get club theme by club name
  static ClubTheme getThemeByName(String clubName) {
    final entry = _clubThemes.entries.firstWhere(
      (e) => e.value.clubName == clubName,
      orElse: () => MapEntry('', _defaultTheme),
    );
    return entry.value;
  }

  /// Default theme (浦和レッズ)
  static const ClubTheme _defaultTheme = ClubTheme(
    clubId: 'urawa-reds',
    clubName: '浦和レッズ',
    gradient: LinearGradient(
      colors: [Color(0xFFE60012), Color(0xFFB50010)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primaryColor: Color(0xFFE60012),
    secondaryColor: Color(0xFFB50010),
    lightColor: Color(0xFFFFCDD2),
  );

  /// All available club themes
  static final Map<String, ClubTheme> _clubThemes = {
    // J1リーグクラブ
    'urawa-reds': const ClubTheme(
      clubId: 'urawa-reds',
      clubName: '浦和レッズ',
      gradient: LinearGradient(
        colors: [Color(0xFFE60012), Color(0xFFB50010)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFFE60012),
      secondaryColor: Color(0xFFB50010),
      lightColor: Color(0xFFFFCDD2),
    ),
    'kashima-antlers': const ClubTheme(
      clubId: 'kashima-antlers',
      clubName: '鹿島アントラーズ',
      gradient: LinearGradient(
        colors: [Color(0xFF8B0000), Color(0xFF660000)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFF8B0000),
      secondaryColor: Color(0xFF660000),
      lightColor: Color(0xFFFFCDD2),
    ),
    'fc-tokyo': const ClubTheme(
      clubId: 'fc-tokyo',
      clubName: 'FC東京',
      gradient: LinearGradient(
        colors: [Color(0xFF0037A5), Color(0xFF002577)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFF0037A5),
      secondaryColor: Color(0xFFE60012),
      lightColor: Color(0xFFBBDEFB),
    ),
    'kawasaki-frontale': const ClubTheme(
      clubId: 'kawasaki-frontale',
      clubName: '川崎フロンターレ',
      gradient: LinearGradient(
        colors: [Color(0xFF0095D9), Color(0xFF006FB8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFF0095D9),
      secondaryColor: Color(0xFF000000),
      lightColor: Color(0xFFB3E5FC),
    ),
    'yokohama-f-marinos': const ClubTheme(
      clubId: 'yokohama-f-marinos',
      clubName: '横浜F・マリノス',
      gradient: LinearGradient(
        colors: [Color(0xFF0045AD), Color(0xFF003380)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFF0045AD),
      secondaryColor: Color(0xFFE60012),
      lightColor: Color(0xFFBBDEFB),
    ),
    'nagoya-grampus': const ClubTheme(
      clubId: 'nagoya-grampus',
      clubName: '名古屋グランパス',
      gradient: LinearGradient(
        colors: [Color(0xFFFF6600), Color(0xFFCC5200)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFFFF6600),
      secondaryColor: Color(0xFFCC5200),
      lightColor: Color(0xFFFFE0B2),
    ),
    'gamba-osaka': const ClubTheme(
      clubId: 'gamba-osaka',
      clubName: 'ガンバ大阪',
      gradient: LinearGradient(
        colors: [Color(0xFF0033A0), Color(0xFF002570)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFF0033A0),
      secondaryColor: Color(0xFF000000),
      lightColor: Color(0xFFBBDEFB),
    ),
    'cerezo-osaka': const ClubTheme(
      clubId: 'cerezo-osaka',
      clubName: 'セレッソ大阪',
      gradient: LinearGradient(
        colors: [Color(0xFFF50057), Color(0xFFC51162)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFFF50057),
      secondaryColor: Color(0xFFC51162),
      lightColor: Color(0xFFF8BBD0),
    ),
    'vissel-kobe': const ClubTheme(
      clubId: 'vissel-kobe',
      clubName: 'ヴィッセル神戸',
      gradient: LinearGradient(
        colors: [Color(0xFF8B0000), Color(0xFF660000)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFF8B0000),
      secondaryColor: Color(0xFFFFD700),
      lightColor: Color(0xFFFFCDD2),
    ),
    'sanfrecce-hiroshima': const ClubTheme(
      clubId: 'sanfrecce-hiroshima',
      clubName: 'サンフレッチェ広島',
      gradient: LinearGradient(
        colors: [Color(0xFF6A3D9A), Color(0xFF512D73)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFF6A3D9A),
      secondaryColor: Color(0xFF512D73),
      lightColor: Color(0xFFE1BEE7),
    ),
    'consadole-sapporo': const ClubTheme(
      clubId: 'consadole-sapporo',
      clubName: 'コンサドーレ札幌',
      gradient: LinearGradient(
        colors: [Color(0xFFE60012), Color(0xFFB50010)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFFE60012),
      secondaryColor: Color(0xFF000000),
      lightColor: Color(0xFFFFCDD2),
    ),
    'vegalta-sendai': const ClubTheme(
      clubId: 'vegalta-sendai',
      clubName: 'ベガルタ仙台',
      gradient: LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFC107)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFFFFD700),
      secondaryColor: Color(0xFF006400),
      lightColor: Color(0xFFFFF9C4),
    ),
    'kashiwa-reysol': const ClubTheme(
      clubId: 'kashiwa-reysol',
      clubName: '柏レイソル',
      gradient: LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFC107)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFFFFD700),
      secondaryColor: Color(0xFF000000),
      lightColor: Color(0xFFFFF9C4),
    ),
    'shimizu-s-pulse': const ClubTheme(
      clubId: 'shimizu-s-pulse',
      clubName: '清水エスパルス',
      gradient: LinearGradient(
        colors: [Color(0xFFFF6600), Color(0xFFCC5200)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFFFF6600),
      secondaryColor: Color(0xFF0033A0),
      lightColor: Color(0xFFFFE0B2),
    ),
    'jubilo-iwata': const ClubTheme(
      clubId: 'jubilo-iwata',
      clubName: 'ジュビロ磐田',
      gradient: LinearGradient(
        colors: [Color(0xFF0095D9), Color(0xFF006FB8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFF0095D9),
      secondaryColor: Color(0xFF0095D9),
      lightColor: Color(0xFFB3E5FC),
    ),
    'kyoto-sanga': const ClubTheme(
      clubId: 'kyoto-sanga',
      clubName: '京都サンガF.C.',
      gradient: LinearGradient(
        colors: [Color(0xFF6A3D9A), Color(0xFF512D73)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFF6A3D9A),
      secondaryColor: Color(0xFF6A3D9A),
      lightColor: Color(0xFFE1BEE7),
    ),
    'avispa-fukuoka': const ClubTheme(
      clubId: 'avispa-fukuoka',
      clubName: 'アビスパ福岡',
      gradient: LinearGradient(
        colors: [Color(0xFF0033A0), Color(0xFF002570)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFF0033A0),
      secondaryColor: Color(0xFFE60012),
      lightColor: Color(0xFFBBDEFB),
    ),
    'sagan-tosu': const ClubTheme(
      clubId: 'sagan-tosu',
      clubName: 'サガン鳥栖',
      gradient: LinearGradient(
        colors: [Color(0xFF0095D9), Color(0xFF006FB8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      primaryColor: Color(0xFF0095D9),
      secondaryColor: Color(0xFFF50057),
      lightColor: Color(0xFFB3E5FC),
    ),
  };

  /// Get all available clubs
  static List<ClubTheme> get allClubs => _clubThemes.values.toList();

  /// Get club names list
  static List<String> get clubNames =>
      _clubThemes.values.map((e) => e.clubName).toList();
}
