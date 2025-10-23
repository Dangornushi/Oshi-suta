import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_badge.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({Key? key}) : super(key: key);

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> playerCards = [
    {
      'id': 1,
      'name': '西川周作',
      'number': 1,
      'position': 'GK',
      'rarity': 'SR',
      'week': 25,
      'image': '🧤',
      'owned': true
    },
    {
      'id': 2,
      'name': 'ホセ・カンテ',
      'number': 10,
      'position': 'MF',
      'rarity': 'SSR',
      'week': 24,
      'image': '⚡',
      'owned': true
    },
    {
      'id': 3,
      'name': '興梠慎三',
      'number': 9,
      'position': 'FW',
      'rarity': 'SR',
      'week': 24,
      'image': '⚽',
      'owned': true
    },
    {
      'id': 4,
      'name': '岩波拓也',
      'number': 5,
      'position': 'DF',
      'rarity': 'R',
      'week': 23,
      'image': '🛡️',
      'owned': true
    },
    {
      'id': 5,
      'name': 'マリウス',
      'number': 15,
      'position': 'FW',
      'rarity': 'SR',
      'week': 23,
      'image': '🔥',
      'owned': true
    },
    {
      'id': 6,
      'name': '小泉佳穂',
      'number': 26,
      'position': 'MF',
      'rarity': 'R',
      'week': 22,
      'image': '💫',
      'owned': true
    },
    {
      'id': 7,
      'name': '明本考浩',
      'number': 7,
      'position': 'MF',
      'rarity': 'SR',
      'week': 25,
      'image': '🌟',
      'owned': false
    },
    {
      'id': 8,
      'name': '酒井宏樹',
      'number': 2,
      'position': 'DF',
      'rarity': 'SSR',
      'week': 25,
      'image': '🏃',
      'owned': false
    },
  ];

  final List<Map<String, dynamic>> badges = [
    {
      'id': 1,
      'name': '初参加',
      'description': '最初のバトルに参加',
      'icon': '🎖️',
      'owned': true
    },
    {
      'id': 2,
      'name': '連勝記録',
      'description': '5連勝を達成',
      'icon': '🔥',
      'owned': true
    },
    {
      'id': 3,
      'name': '歩数王',
      'description': '週間歩数1位',
      'icon': '👑',
      'owned': true
    },
    {
      'id': 4,
      'name': '鉄人',
      'description': '30日連続ログイン',
      'icon': '💪',
      'owned': true
    },
    {
      'id': 5,
      'name': 'クイズマスター',
      'description': 'クイズ100問正解',
      'icon': '🧠',
      'owned': false
    },
    {
      'id': 6,
      'name': 'サポーター王',
      'description': '年間ランキング1位',
      'icon': '👑',
      'owned': false
    },
  ];

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
    final ownedCards = playerCards.where((c) => c['owned'] == true).length;
    final ownedBadges = badges.where((b) => b['owned'] == true).length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header
            const Text(
              'コレクション',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '応援の証を集めよう',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // Collection Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomCard(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome,
                                color: Colors.white, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'コレクション進捗',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '保有ポイント',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFF8BBD0),
                              ),
                            ),
                            Text(
                              '3,847pt',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '選手カード',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFF8BBD0),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$ownedCards / ${playerCards.length}',
                                style: const TextStyle(
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
                            children: [
                              const Text(
                                'バッジ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFF8BBD0),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$ownedBadges / ${badges.length}',
                                style: const TextStyle(
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
                  Tab(text: '選手カード'),
                  Tab(text: 'バッジ'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCardsTab(),
                  _buildBadgesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: playerCards.length,
      itemBuilder: (context, index) {
        final card = playerCards[index];
        return _buildPlayerCard(card);
      },
    );
  }

  Widget _buildBadgesTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return _buildBadge(badge);
      },
    );
  }

  Widget _buildPlayerCard(Map<String, dynamic> card) {
    final owned = card['owned'] as bool;
    final rarity = card['rarity'] as String;

    return GestureDetector(
      onTap: owned ? () => _showCardDetail(card) : null,
      child: CustomCard(
        padding: const EdgeInsets.all(12),
        border: owned ? Border.all(color: _getRarityColor(rarity), width: 2) : null,
        child: Stack(
          children: [
            Column(
              children: [
                // Card Image Container
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getRarityGradient(rarity),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            card['image'],
                            style: const TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 8),
                          CustomBadge(
                            text: rarity,
                            backgroundColor: _getRarityBadgeColor(rarity),
                            fontSize: 10,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '第${card['week']}節',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Card Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '#${card['number']}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        card['name'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                CustomBadge(
                  text: card['position'],
                  variant: BadgeVariant.outline,
                  fontSize: 10,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                ),
              ],
            ),
            if (!owned)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(Map<String, dynamic> badge) {
    final owned = badge['owned'] as bool;

    return CustomCard(
      padding: const EdgeInsets.all(16),
      border: owned
          ? Border.all(color: const Color(0xFFFFC107), width: 2)
          : null,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                badge['icon'],
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 12),
              Text(
                badge['name'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                badge['description'],
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (owned) ...[
                const SizedBox(height: 8),
                const CustomBadge(
                  text: '獲得済み',
                  backgroundColor: Color(0xFFFFC107),
                  fontSize: 10,
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                ),
              ],
            ],
          ),
          if (!owned)
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.lock,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ),
        ],
      ),
    );
  }

  void _showCardDetail(Map<String, dynamic> card) {
    final rarity = card['rarity'] as String;

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
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getRarityGradient(rarity),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      card['image'],
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 16),
                    CustomBadge(
                      text: rarity,
                      backgroundColor: _getRarityBadgeColor(rarity),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '2025シーズン 第${card['week']}節',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '#${card['number']}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    card['name'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CustomBadge(
                text: card['position'],
                variant: BadgeVariant.outline,
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'プロフィールに装備して「推し」をアピール！',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'SSR':
        return const Color(0xFF9C27B0);
      case 'SR':
        return const Color(0xFF2196F3);
      case 'R':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  List<Color> _getRarityGradient(String rarity) {
    switch (rarity) {
      case 'SSR':
        return const [Color(0xFF9C27B0), Color(0xFFE91E63)];
      case 'SR':
        return const [Color(0xFF2196F3), Color(0xFF00BCD4)];
      case 'R':
        return const [Color(0xFF9E9E9E), Color(0xFF757575)];
      default:
        return const [Color(0xFFBDBDBD), Color(0xFF9E9E9E)];
    }
  }

  Color _getRarityBadgeColor(String rarity) {
    switch (rarity) {
      case 'SSR':
        return const Color(0xFF9C27B0);
      case 'SR':
        return const Color(0xFF2196F3);
      case 'R':
        return Colors.grey.shade600;
      default:
        return Colors.grey;
    }
  }
}
