import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_badge.dart';

class LeagueStandingsScreen extends StatefulWidget {
  const LeagueStandingsScreen({Key? key}) : super(key: key);

  @override
  State<LeagueStandingsScreen> createState() => _LeagueStandingsScreenState();
}

class _LeagueStandingsScreenState extends State<LeagueStandingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> j1Standings = [
    {
      'rank': 1,
      'team': '川崎フロンターレ',
      'logo': '🌊',
      'points': 847,
      'wins': 18,
      'draws': 5,
      'losses': 2,
      'trend': 'up'
    },
    {
      'rank': 2,
      'team': '横浜F・マリノス',
      'logo': '⚓',
      'points': 823,
      'wins': 17,
      'draws': 6,
      'losses': 2,
      'trend': 'same'
    },
    {
      'rank': 3,
      'team': '浦和レッズ',
      'logo': '🔴',
      'points': 809,
      'wins': 17,
      'draws': 4,
      'losses': 4,
      'trend': 'up',
      'isMyTeam': true
    },
    {
      'rank': 4,
      'team': 'セレッソ大阪',
      'logo': '🌸',
      'points': 786,
      'wins': 16,
      'draws': 6,
      'losses': 3,
      'trend': 'down'
    },
    {
      'rank': 5,
      'team': 'ヴィッセル神戸',
      'logo': '⚔️',
      'points': 772,
      'wins': 16,
      'draws': 4,
      'losses': 5,
      'trend': 'up'
    },
    {
      'rank': 6,
      'team': '鹿島アントラーズ',
      'logo': '🦌',
      'points': 758,
      'wins': 15,
      'draws': 7,
      'losses': 3,
      'trend': 'same'
    },
    {
      'rank': 7,
      'team': 'FC東京',
      'logo': '🗼',
      'points': 734,
      'wins': 15,
      'draws': 4,
      'losses': 6,
      'trend': 'down'
    },
    {
      'rank': 8,
      'team': 'サガン鳥栖',
      'logo': '🦅',
      'points': 701,
      'wins': 14,
      'draws': 5,
      'losses': 6,
      'trend': 'up'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header
            const Text(
              'サポーターズ・リーグ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '年間の栄光をかけた戦い',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'J1'),
                  Tab(text: 'J2'),
                  Tab(text: 'J3'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildJ1Tab(),
                  _buildEmptyTab('J2'),
                  _buildEmptyTab('J3'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJ1Tab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Season Overview
            CustomCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.emoji_events, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        '2025シーズン戦績',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '総バトル数',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFBBDEFB),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '25試合',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '獲得ポイント',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFBBDEFB),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '809pt',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '戦績',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFBBDEFB),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '17勝 4分 4敗',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '参加サポーター',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFBBDEFB),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '8,456人',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Standings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '順位表',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CustomBadge(
                  text: '第25節終了時点',
                  variant: BadgeVariant.outline,
                  fontSize: 11,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: const [
                        SizedBox(
                          width: 40,
                          child: Text(
                            '順位',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'クラブ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: Text(
                            '勝点',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 35,
                          child: Text(
                            '勝',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 35,
                          child: Text(
                            '分',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 35,
                          child: Text(
                            '敗',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(width: 30),
                      ],
                    ),
                  ),
                  // Table Body
                  ...j1Standings.map((team) => _buildStandingRow(team)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Season Highlights
            CustomCard(
              border: Border.all(color: const Color(0xFFFFE0B2), width: 2),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF3E0), Color(0xFFFFECB3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'シーズンハイライト',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildHighlightRow('総歩数', '2.3億歩'),
                  const SizedBox(height: 12),
                  _buildHighlightRow(
                      'トップコントリビューター', 'レッズ魂123'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '現在の順位',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const CustomBadge(
                        text: '3位 / 18チーム',
                        backgroundColor: Color(0xFFFF6F00),
                        fontSize: 11,
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandingRow(Map<String, dynamic> team) {
    final bool isMyTeam = team['isMyTeam'] ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isMyTeam ? const Color(0xFFE3F2FD) : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: Row(
              children: [
                Text(
                  '${team['rank']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isMyTeam ? const Color(0xFF2196F3) : Colors.black,
                    fontWeight:
                        isMyTeam ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (team['rank'] <= 3) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.emoji_events,
                    size: 16,
                    color: team['rank'] == 1
                        ? const Color(0xFFFFD700)
                        : team['rank'] == 2
                            ? const Color(0xFFC0C0C0)
                            : const Color(0xFFCD7F32),
                  ),
                ],
              ],
            ),
          ),
          // Team
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Text(team['logo'], style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    team['team'],
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isMyTeam ? const Color(0xFF2196F3) : Colors.black,
                      fontWeight:
                          isMyTeam ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Points
          SizedBox(
            width: 50,
            child: Text(
              '${team['points']}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          // Wins
          SizedBox(
            width: 35,
            child: Text(
              '${team['wins']}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          // Draws
          SizedBox(
            width: 35,
            child: Text(
              '${team['draws']}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          // Losses
          SizedBox(
            width: 35,
            child: Text(
              '${team['losses']}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          // Trend
          SizedBox(
            width: 30,
            child: Icon(
              team['trend'] == 'up'
                  ? Icons.trending_up
                  : team['trend'] == 'down'
                      ? Icons.trending_down
                      : Icons.remove,
              size: 16,
              color: team['trend'] == 'up'
                  ? const Color(0xFF4CAF50)
                  : team['trend'] == 'down'
                      ? const Color(0xFFF44336)
                      : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade900,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyTab(String league) {
    return Center(
      child: CustomCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '$leagueリーグ',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$leagueクラブの順位表がここに表示されます',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
