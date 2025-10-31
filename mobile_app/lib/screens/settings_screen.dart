import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/club/bloc/club_bloc.dart';
import '../features/club/bloc/club_state.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_event.dart';
import '../features/auth/bloc/auth_state.dart';
import '../widgets/custom_card.dart';
import 'club_selection_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // ログアウト成功時にログイン画面に遷移
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('設定'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Account section
            const _SectionTitle(title: 'アカウント'),
            const SizedBox(height: 12),
            _buildSettingCard(
              context: context,
              icon: Icons.person,
              iconColor: const Color(0xFF2196F3),
              iconBgColor: const Color(0xFFE3F2FD),
              title: 'ユーザー情報',
              subtitle: 'プロフィール、メールアドレスなど',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            BlocBuilder<ClubBloc, ClubState>(
              builder: (context, state) {
                String currentClub = '未設定';
                if (state is ClubLoaded) {
                  currentClub = state.clubName;
                }

                return _buildSettingCard(
                  context: context,
                  icon: Icons.favorite,
                  iconColor: const Color(0xFFE60012),
                  iconBgColor: const Color(0xFFFFCDD2),
                  title: '推しクラブ',
                  subtitle: currentClub,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ClubSelectionScreen(),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              context: context,
              icon: Icons.logout,
              iconColor: const Color(0xFFE53935),
              iconBgColor: const Color(0xFFFFCDD2),
              title: 'ログアウト',
              subtitle: 'アカウントからログアウト',
              onTap: () => _showLogoutDialog(context),
            ),
            const SizedBox(height: 24),

            // Notifications section
            const _SectionTitle(title: '通知'),
            const SizedBox(height: 12),
            _buildSettingCard(
              context: context,
              icon: Icons.notifications,
              iconColor: const Color(0xFFFF9800),
              iconBgColor: const Color(0xFFFFE0B2),
              title: '通知設定',
              subtitle: 'プッシュ通知の管理',
              onTap: () {
                // TODO: Navigate to notification settings screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('通知設定画面（未実装）')),
                );
              },
            ),
            const SizedBox(height: 24),

            // Integrations section
            const _SectionTitle(title: '連携'),
            const SizedBox(height: 12),
            _buildSettingCard(
              context: context,
              icon: Icons.directions_walk,
              iconColor: const Color(0xFF4CAF50),
              iconBgColor: const Color(0xFFE8F5E9),
              title: '歩数計連携',
              subtitle: 'ヘルスケア、Google Fit',
              onTap: () {
                // TODO: Navigate to health integration screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('歩数計連携画面（未実装）')),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              context: context,
              icon: Icons.share,
              iconColor: const Color(0xFF9C27B0),
              iconBgColor: const Color(0xFFF3E5F5),
              title: 'SNS連携',
              subtitle: 'Twitter、Facebookなど',
              onTap: () {
                // TODO: Navigate to SNS integration screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('SNS連携画面（未実装）')),
                );
              },
            ),
            const SizedBox(height: 24),

            // App info section
            const _SectionTitle(title: 'アプリ情報'),
            const SizedBox(height: 12),
            _buildSettingCard(
              context: context,
              icon: Icons.info,
              iconColor: const Color(0xFF607D8B),
              iconBgColor: const Color(0xFFECEFF1),
              title: 'アプリバージョン',
              subtitle: 'v1.0.0',
              onTap: () {},
              showChevron: false,
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              context: context,
              icon: Icons.description,
              iconColor: const Color(0xFF607D8B),
              iconBgColor: const Color(0xFFECEFF1),
              title: '利用規約',
              subtitle: '',
              onTap: () {
                // TODO: Navigate to terms of service screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('利用規約画面（未実装）')),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              context: context,
              icon: Icons.privacy_tip,
              iconColor: const Color(0xFF607D8B),
              iconBgColor: const Color(0xFFECEFF1),
              title: 'プライバシーポリシー',
              subtitle: '',
              onTap: () {
                // TODO: Navigate to privacy policy screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('プライバシーポリシー画面（未実装）')),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              context: context,
              icon: Icons.help,
              iconColor: const Color(0xFF607D8B),
              iconBgColor: const Color(0xFFECEFF1),
              title: 'お問い合わせ',
              subtitle: '',
              onTap: () {
                // TODO: Navigate to contact screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('お問い合わせ画面（未実装）')),
                );
              },
            ),
            const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// ログアウト確認ダイアログを表示
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('本当にログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // AuthBlocにログアウトイベントを送信
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE53935),
            ),
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showChevron = true,
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showChevron)
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }
}
