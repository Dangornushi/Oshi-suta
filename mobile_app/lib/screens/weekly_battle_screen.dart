import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_progress.dart';
import '../widgets/custom_badge.dart';

class WeeklyBattleScreen extends StatefulWidget {
  const WeeklyBattleScreen({Key? key}) : super(key: key);

  @override
  State<WeeklyBattleScreen> createState() => _WeeklyBattleScreenState();
}

class _WeeklyBattleScreenState extends State<WeeklyBattleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
              'ウィークリーバトル',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '週末の熱狂を、応援力に。',
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
                  Tab(text: '今週のバトル'),
                  Tab(text: '過去の戦績'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCurrentBattle(),
                  _buildHistory(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBattle() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Battle Status
            CustomCard(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: const Color(0xFFFFCDD2), width: 2),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.local_fire_department,
                          color: Color(0xFFD32F2F), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'バトル進行中',
                        style: TextStyle(
                          color: Color(0xFFD32F2F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.local_fire_department,
                          color: Color(0xFFD32F2F), size: 20),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTeam('🔴', '浦和レッズ', '12,847'),
                      Column(
                        children: [
                          const Text(
                            'VS',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomBadge(
                            variant: BadgeVariant.outline,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.timer, size: 12),
                                SizedBox(width: 4),
                                Text('2日14時間', style: TextStyle(fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      _buildTeam('🦌', '鹿島アントラーズ', '11,923'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '実際の試合: 2025/10/25 (土) 14:00',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // My Contribution
            CustomCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'あなたの貢献度',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFBBDEFB),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '1,847pt',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        '順位',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFBBDEFB),
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: '127位',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: '/8,456人',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFBBDEFB),
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

            // Missions
            const Text(
              '選手シンクロミッション',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildMission(
              icon: Icons.directions_walk,
              iconColor: const Color(0xFF2196F3),
              iconBgColor: const Color(0xFFE3F2FD),
              title: '走行距離チャレンジ',
              player: '興梠慎三',
              playerNumber: 9,
              description: 'チームの"汗かき役"のように、週末までの総走行距離を競う',
              current: 18.5,
              target: 30,
              unit: 'km',
              points: 500,
              difficulty: '中',
            ),
            const SizedBox(height: 12),
            _buildMission(
              icon: Icons.flash_on,
              iconColor: const Color(0xFFFBC02D),
              iconBgColor: const Color(0xFFFFF9C4),
              title: 'ペースコントロール',
              player: 'ホセ・カンテ',
              playerNumber: 10,
              description: '1kmを5分ペースで走るミッションの成功回数',
              current: 3,
              target: 7,
              unit: '回',
              points: 700,
              difficulty: '高',
            ),
            const SizedBox(height: 12),
            _buildMission(
              icon: Icons.shield,
              iconColor: const Color(0xFF4CAF50),
              iconBgColor: const Color(0xFFE8F5E9),
              title: '継続率チャレンジ',
              player: '西川周作',
              playerNumber: 1,
              description: '鉄壁の守護神のように、日々の運動の継続率で競う',
              current: 5,
              target: 7,
              unit: '日',
              points: 600,
              difficulty: '中',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '過去のバトル戦績',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildHistoryCard(
              round: 'J1 第29節',
              opponent: '横浜F・マリノス',
              opponentLogo: '⚓',
              result: '勝利',
              score: '14523 - 13891',
              realResult: '実戦: 2-1 (勝)',
              isWin: true,
            ),
            const SizedBox(height: 12),
            _buildHistoryCard(
              round: 'J1 第28節',
              opponent: '川崎フロンターレ',
              opponentLogo: '🌊',
              result: '敗北',
              score: '11234 - 15678',
              realResult: '実戦: 1-3 (敗)',
              isWin: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeam(String logo, String name, String score) {
    return Column(
      children: [
        Text(logo, style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          score,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMission({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String player,
    required int playerNumber,
    required String description,
    required double current,
    required double target,
    required String unit,
    required int points,
    required String difficulty,
  }) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        CustomBadge(
                          text: difficulty,
                          variant: BadgeVariant.outline,
                          borderColor: difficulty == '高'
                              ? Colors.red.shade300
                              : Colors.blue.shade300,
                          textColor: difficulty == '高'
                              ? Colors.red.shade600
                              : Colors.blue.shade600,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#$playerNumber $player',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$current / $target $unit',
                style: const TextStyle(fontSize: 13),
              ),
              Text(
                '+${points}pt',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomProgress(
            value: (current / target) * 100,
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required String round,
    required String opponent,
    required String opponentLogo,
    required String result,
    required String score,
    required String realResult,
    required bool isWin,
  }) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                round,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              CustomBadge(
                text: result,
                backgroundColor: isWin ? const Color(0xFF4CAF50) : Colors.red,
                fontSize: 11,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🔴', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 8),
                  Text('浦和レッズ'),
                ],
              ),
              const Text('VS', style: TextStyle(color: Colors.grey)),
              Row(
                children: [
                  Text(opponent),
                  const SizedBox(width: 8),
                  Text(opponentLogo, style: const TextStyle(fontSize: 24)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '応援力: $score',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              realResult,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
