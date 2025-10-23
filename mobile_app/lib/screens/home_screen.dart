import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_progress.dart';
import '../widgets/custom_badge.dart';
import '../widgets/custom_button.dart';
import '../features/club/bloc/club_bloc.dart';
import '../features/club/bloc/club_state.dart';
import '../config/club_theme.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double clubGauge = 67;
  int dailySteps = 8456;
  bool quizCompleted = false;
  bool showQuiz = false;

  void _handleQuizAnswer(int answer) {
    if (answer == 2) {
      setState(() {
        quizCompleted = true;
        clubGauge = (clubGauge + 1).clamp(0, 100);
      });
    }
    Navigator.of(context).pop();
  }

  void _showQuizDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '本日の選手クイズ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '浦和レッズで最も多くの公式戦に出場している選手は？',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              _buildQuizOption('A. 興梠慎三', () => _handleQuizAnswer(1)),
              const SizedBox(height: 12),
              _buildQuizOption('B. 西川周作', () => _handleQuizAnswer(2)),
              const SizedBox(height: 12),
              _buildQuizOption('C. 岩波拓也', () => _handleQuizAnswer(3)),
              const SizedBox(height: 24),
              CustomButton(
                text: 'キャンセル',
                variant: ButtonVariant.ghost,
                width: double.infinity,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizOption(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ClubBloc, ClubState>(
        builder: (context, clubState) {
          // Get club theme from state
          ClubTheme theme = ClubTheme.getTheme('urawa-reds');
          String clubName = '浦和レッズ';

          if (clubState is ClubLoaded) {
            theme = clubState.theme;
            clubName = clubState.clubName;
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Header with settings icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Oshi-Suta BATTLE',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '365日の応援を、クラブの力に。',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.settings,
                          size: 28,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Club Gauge
                  CustomCard(
                    gradient: theme.gradient,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  clubName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'クラブゲージ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.lightColor,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${clubGauge.toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.trending_up,
                                      size: 16,
                                      color: theme.lightColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '今週 +12%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.lightColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomProgress(
                          value: clubGauge,
                          height: 12,
                          backgroundColor: theme.secondaryColor.withOpacity(0.3),
                          foregroundColor: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '全サポーターの応援が集結中！🔥',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.lightColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Today's Actions
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '今日の応援アクション',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    icon: Icons.directions_walk,
                    iconColor: const Color(0xFF4CAF50),
                    iconBgColor: const Color(0xFFE8F5E9),
                    title: '歩数連携',
                    description: '今日の歩数',
                    value: '$dailySteps歩',
                    points: '+24pt',
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    icon: Icons.location_on,
                    iconColor: const Color(0xFF9C27B0),
                    iconBgColor: const Color(0xFFF3E5F5),
                    title: 'チェックイン',
                    description: 'スタジアム・提携店舗',
                    value: 'タップして記録',
                    points: '+50pt',
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    icon: Icons.psychology,
                    iconColor: const Color(0xFF2196F3),
                    iconBgColor: const Color(0xFFE3F2FD),
                    title: '選手データクイズ',
                    description: quizCompleted ? '本日完了' : '今日の問題',
                    value: quizCompleted ? '正解！' : '挑戦する',
                    points: quizCompleted ? '✓ +10pt' : '+10pt',
                    onTap: () {
                      if (!quizCompleted) {
                        _showQuizDialog();
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Cooperative Mission
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.track_changes,
                              color: Color(0xFFFF6F00),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'サポーター全員で地球一周に挑戦！',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE65100),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '2,847人が参加中',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '32,847 / 40,075 km',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange.shade800,
                              ),
                            ),
                            Text(
                              '残り 3日23時間',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        CustomProgress(
                          value: (32847 / 40075) * 100,
                          height: 8,
                          backgroundColor: const Color(0xFFFFCC80),
                          foregroundColor: const Color(0xFFFF6F00),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
    required String value,
    required String points,
    VoidCallback? onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      points,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: quizCompleted && title == '選手データクイズ'
                        ? const Color(0xFF4CAF50)
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }
}
