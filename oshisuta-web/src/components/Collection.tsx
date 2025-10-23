import { useState } from 'react';
import { Star, Lock, Sparkles, Award } from 'lucide-react';
import { Card } from './ui/card';
import { Badge } from './ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';

export default function Collection() {
  const [selectedCard, setSelectedCard] = useState<any>(null);

  const playerCards = [
    { id: 1, name: '西川周作', number: 1, position: 'GK', rarity: 'SR', week: 25, image: '🧤', owned: true },
    { id: 2, name: 'ホセ・カンテ', number: 10, position: 'MF', rarity: 'SSR', week: 24, image: '⚡', owned: true },
    { id: 3, name: '興梠慎三', number: 9, position: 'FW', rarity: 'SR', week: 24, image: '⚽', owned: true },
    { id: 4, name: '岩波拓也', number: 5, position: 'DF', rarity: 'R', week: 23, image: '🛡️', owned: true },
    { id: 5, name: 'マリウス', number: 15, position: 'FW', rarity: 'SR', week: 23, image: '🔥', owned: true },
    { id: 6, name: '小泉佳穂', number: 26, position: 'MF', rarity: 'R', week: 22, image: '💫', owned: true },
    { id: 7, name: '明本考浩', number: 7, position: 'MF', rarity: 'SR', week: 25, image: '🌟', owned: false },
    { id: 8, name: '酒井宏樹', number: 2, position: 'DF', rarity: 'SSR', week: 25, image: '🏃', owned: false },
  ];

  const badges = [
    { id: 1, name: '初参加', description: '最初のバトルに参加', icon: '🎖️', owned: true },
    { id: 2, name: '連勝記録', description: '5連勝を達成', icon: '🔥', owned: true },
    { id: 3, name: '歩数王', description: '週間歩数1位', icon: '👑', owned: true },
    { id: 4, name: '鉄人', description: '30日連続ログイン', icon: '💪', owned: true },
    { id: 5, name: 'クイズマスター', description: 'クイズ100問正解', icon: '🧠', owned: false },
    { id: 6, name: 'サポーター王', description: '年間ランキング1位', icon: '👑', owned: false },
  ];

  const collectionStats = {
    totalCards: playerCards.length,
    ownedCards: playerCards.filter(c => c.owned).length,
    totalBadges: badges.length,
    ownedBadges: badges.filter(b => b.owned).length,
    points: 3847,
  };

  const getRarityColor = (rarity: string) => {
    switch (rarity) {
      case 'SSR':
        return 'from-purple-500 to-pink-500';
      case 'SR':
        return 'from-blue-500 to-cyan-500';
      case 'R':
        return 'from-gray-400 to-gray-600';
      default:
        return 'from-gray-300 to-gray-500';
    }
  };

  const getRarityBadgeColor = (rarity: string) => {
    switch (rarity) {
      case 'SSR':
        return 'bg-purple-600';
      case 'SR':
        return 'bg-blue-600';
      case 'R':
        return 'bg-gray-600';
      default:
        return 'bg-gray-500';
    }
  };

  return (
    <div className="p-4 pb-6 space-y-6">
      {/* Header */}
      <div className="text-center pt-4">
        <h2>コレクション</h2>
        <p className="text-gray-600 mt-1">応援の証を集めよう</p>
      </div>

      {/* Collection Stats */}
      <Card className="p-5 bg-gradient-to-br from-purple-600 to-pink-600 text-white">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Sparkles className="w-6 h-6" />
            <h3 className="text-white">コレクション進捗</h3>
          </div>
          <div className="text-right">
            <p className="text-purple-100 text-sm">保有ポイント</p>
            <div className="text-xl">{collectionStats.points}pt</div>
          </div>
        </div>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <p className="text-purple-100 text-sm">選手カード</p>
            <div className="mt-1">
              {collectionStats.ownedCards} / {collectionStats.totalCards}
            </div>
          </div>
          <div>
            <p className="text-purple-100 text-sm">バッジ</p>
            <div className="mt-1">
              {collectionStats.ownedBadges} / {collectionStats.totalBadges}
            </div>
          </div>
        </div>
      </Card>

      <Tabs defaultValue="cards" className="w-full">
        <TabsList className="grid w-full grid-cols-2">
          <TabsTrigger value="cards">選手カード</TabsTrigger>
          <TabsTrigger value="badges">バッジ</TabsTrigger>
        </TabsList>

        <TabsContent value="cards" className="mt-6">
          <div className="grid grid-cols-2 gap-3">
            {playerCards.map((card) => (
              <div
                key={card.id}
                className={`relative cursor-pointer ${!card.owned && 'opacity-50'}`}
                onClick={() => card.owned && setSelectedCard(card)}
              >
                <Card className={`p-4 overflow-hidden ${card.owned ? 'border-2' : ''}`}>
                  {!card.owned && (
                    <div className="absolute inset-0 bg-black/60 flex items-center justify-center z-10">
                      <Lock className="w-8 h-8 text-white" />
                    </div>
                  )}
                  <div className={`bg-gradient-to-br ${getRarityColor(card.rarity)} p-4 rounded-lg mb-3`}>
                    <div className="text-4xl text-center text-white mb-2">{card.image}</div>
                    <div className="text-center">
                      <Badge className={`${getRarityBadgeColor(card.rarity)} text-xs mb-2`}>
                        {card.rarity}
                      </Badge>
                      <div className="text-white text-xs">第{card.week}節</div>
                    </div>
                  </div>
                  <div className="text-center">
                    <div className="flex items-center justify-center gap-2 mb-1">
                      <span className="text-sm text-gray-600">#{card.number}</span>
                      <h4 className="text-sm">{card.name}</h4>
                    </div>
                    <Badge variant="outline" className="text-xs">
                      {card.position}
                    </Badge>
                  </div>
                </Card>
              </div>
            ))}
          </div>
        </TabsContent>

        <TabsContent value="badges" className="mt-6">
          <div className="grid grid-cols-2 gap-3">
            {badges.map((badge) => (
              <Card 
                key={badge.id} 
                className={`p-5 ${badge.owned ? 'border-2 border-yellow-400' : 'opacity-50'}`}
              >
                {!badge.owned && (
                  <div className="absolute top-2 right-2">
                    <Lock className="w-4 h-4 text-gray-400" />
                  </div>
                )}
                <div className="text-center">
                  <div className="text-4xl mb-3">{badge.icon}</div>
                  <h4 className="mb-2">{badge.name}</h4>
                  <p className="text-gray-600 text-xs">{badge.description}</p>
                  {badge.owned && (
                    <div className="mt-3">
                      <Badge className="bg-yellow-500">
                        <Award className="w-3 h-3 mr-1" />
                        獲得済み
                      </Badge>
                    </div>
                  )}
                </div>
              </Card>
            ))}
          </div>
        </TabsContent>
      </Tabs>

      {/* Card Detail Modal */}
      {selectedCard && (
        <div 
          className="fixed inset-0 bg-black/70 flex items-center justify-center p-4 z-50"
          onClick={() => setSelectedCard(null)}
        >
          <Card className="p-6 max-w-sm w-full" onClick={(e) => e.stopPropagation()}>
            <div className={`bg-gradient-to-br ${getRarityColor(selectedCard.rarity)} p-8 rounded-lg mb-4`}>
              <div className="text-6xl text-center text-white mb-4">{selectedCard.image}</div>
              <div className="text-center">
                <Badge className={`${getRarityBadgeColor(selectedCard.rarity)} mb-2`}>
                  {selectedCard.rarity}
                </Badge>
                <div className="text-white">2025シーズン 第{selectedCard.week}節</div>
              </div>
            </div>
            <div className="text-center mb-4">
              <div className="flex items-center justify-center gap-2 mb-2">
                <span className="text-gray-600">#{selectedCard.number}</span>
                <h2>{selectedCard.name}</h2>
              </div>
              <Badge variant="outline">{selectedCard.position}</Badge>
            </div>
            <div className="flex items-center gap-2 text-sm text-gray-600 mb-4">
              <Star className="w-4 h-4 text-yellow-500" />
              <span>プロフィールに装備して「推し」をアピール！</span>
            </div>
          </Card>
        </div>
      )}
    </div>
  );
}
