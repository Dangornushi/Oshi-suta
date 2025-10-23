import { Trophy, TrendingUp, TrendingDown, Minus, Medal } from 'lucide-react';
import { Card } from './ui/card';
import { Badge } from './ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';

export default function LeagueStandings() {
  const j1Standings = [
    { rank: 1, team: '川崎フロンターレ', logo: '🌊', points: 847, wins: 18, draws: 5, losses: 2, trend: 'up' },
    { rank: 2, team: '横浜F・マリノス', logo: '⚓', points: 823, wins: 17, draws: 6, losses: 2, trend: 'same' },
    { rank: 3, team: '浦和レッズ', logo: '🔴', points: 809, wins: 17, draws: 4, losses: 4, trend: 'up', isMyTeam: true },
    { rank: 4, team: 'セレッソ大阪', logo: '🌸', points: 786, wins: 16, draws: 6, losses: 3, trend: 'down' },
    { rank: 5, team: 'ヴィッセル神戸', logo: '⚔️', points: 772, wins: 16, draws: 4, losses: 5, trend: 'up' },
    { rank: 6, team: '鹿島アントラーズ', logo: '🦌', points: 758, wins: 15, draws: 7, losses: 3, trend: 'same' },
    { rank: 7, team: 'FC東京', logo: '🗼', points: 734, wins: 15, draws: 4, losses: 6, trend: 'down' },
    { rank: 8, team: 'サガン鳥栖', logo: '🦅', points: 701, wins: 14, draws: 5, losses: 6, trend: 'up' },
  ];

  const seasonStats = {
    totalBattles: 25,
    wins: 17,
    draws: 4,
    losses: 4,
    totalPoints: 809,
    activeSupporters: 8456,
    totalSteps: '2.3億',
    topContributor: 'レッズ魂123',
  };

  const getTrendIcon = (trend: string) => {
    switch (trend) {
      case 'up':
        return <TrendingUp className="w-4 h-4 text-green-600" />;
      case 'down':
        return <TrendingDown className="w-4 h-4 text-red-600" />;
      default:
        return <Minus className="w-4 h-4 text-gray-400" />;
    }
  };

  const getRankBadge = (rank: number) => {
    if (rank === 1) return <Medal className="w-5 h-5 text-yellow-500" />;
    if (rank === 2) return <Medal className="w-5 h-5 text-gray-400" />;
    if (rank === 3) return <Medal className="w-5 h-5 text-orange-600" />;
    return null;
  };

  return (
    <div className="p-4 pb-6 space-y-6">
      {/* Header */}
      <div className="text-center pt-4">
        <h2>サポーターズ・リーグ</h2>
        <p className="text-gray-600 mt-1">年間の栄光をかけた戦い</p>
      </div>

      <Tabs defaultValue="j1" className="w-full">
        <TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="j1">J1</TabsTrigger>
          <TabsTrigger value="j2">J2</TabsTrigger>
          <TabsTrigger value="j3">J3</TabsTrigger>
        </TabsList>

        <TabsContent value="j1" className="space-y-6 mt-6">
          {/* Season Overview */}
          <Card className="p-6 bg-gradient-to-br from-blue-600 to-blue-800 text-white">
            <div className="flex items-center gap-2 mb-4">
              <Trophy className="w-6 h-6" />
              <h3 className="text-white">2025シーズン戦績</h3>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-blue-100 text-sm">総バトル数</p>
                <div className="text-2xl mt-1">{seasonStats.totalBattles}試合</div>
              </div>
              <div>
                <p className="text-blue-100 text-sm">獲得ポイント</p>
                <div className="text-2xl mt-1">{seasonStats.totalPoints}pt</div>
              </div>
              <div>
                <p className="text-blue-100 text-sm">戦績</p>
                <div className="mt-1">
                  {seasonStats.wins}勝 {seasonStats.draws}分 {seasonStats.losses}敗
                </div>
              </div>
              <div>
                <p className="text-blue-100 text-sm">参加サポーター</p>
                <div className="mt-1">{seasonStats.activeSupporters.toLocaleString()}人</div>
              </div>
            </div>
          </Card>

          {/* Standings Table */}
          <div>
            <div className="flex items-center justify-between mb-3">
              <h3>順位表</h3>
              <Badge variant="outline">第25節終了時点</Badge>
            </div>
            <Card className="overflow-hidden">
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead className="bg-gray-50 border-b">
                    <tr>
                      <th className="px-4 py-3 text-left text-sm text-gray-600">順位</th>
                      <th className="px-4 py-3 text-left text-sm text-gray-600">クラブ</th>
                      <th className="px-4 py-3 text-center text-sm text-gray-600">勝点</th>
                      <th className="px-4 py-3 text-center text-sm text-gray-600">勝</th>
                      <th className="px-4 py-3 text-center text-sm text-gray-600">分</th>
                      <th className="px-4 py-3 text-center text-sm text-gray-600">敗</th>
                      <th className="px-4 py-3 text-center text-sm text-gray-600"></th>
                    </tr>
                  </thead>
                  <tbody className="divide-y">
                    {j1Standings.map((team) => (
                      <tr 
                        key={team.rank} 
                        className={team.isMyTeam ? 'bg-blue-50' : 'hover:bg-gray-50'}
                      >
                        <td className="px-4 py-4">
                          <div className="flex items-center gap-2">
                            <span className={team.isMyTeam ? 'text-blue-600' : ''}>
                              {team.rank}
                            </span>
                            {getRankBadge(team.rank)}
                          </div>
                        </td>
                        <td className="px-4 py-4">
                          <div className="flex items-center gap-2">
                            <span className="text-xl">{team.logo}</span>
                            <span className={team.isMyTeam ? 'text-blue-600' : ''}>
                              {team.team}
                            </span>
                          </div>
                        </td>
                        <td className="px-4 py-4 text-center">
                          {team.points}
                        </td>
                        <td className="px-4 py-4 text-center text-gray-600">
                          {team.wins}
                        </td>
                        <td className="px-4 py-4 text-center text-gray-600">
                          {team.draws}
                        </td>
                        <td className="px-4 py-4 text-center text-gray-600">
                          {team.losses}
                        </td>
                        <td className="px-4 py-4 text-center">
                          {getTrendIcon(team.trend)}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </Card>
          </div>

          {/* Season Highlights */}
          <Card className="p-5 border-2 border-yellow-200 bg-gradient-to-br from-yellow-50 to-orange-50">
            <h3 className="mb-4 text-orange-900">シーズンハイライト</h3>
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-gray-700">総歩数</span>
                <span className="text-orange-900">{seasonStats.totalSteps}歩</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-gray-700">トップコントリビューター</span>
                <span className="text-orange-900">{seasonStats.topContributor}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-gray-700">現在の順位</span>
                <Badge className="bg-orange-600">3位 / 18チーム</Badge>
              </div>
            </div>
          </Card>
        </TabsContent>

        <TabsContent value="j2" className="mt-6">
          <Card className="p-8 text-center">
            <Trophy className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-gray-600 mb-2">J2リーグ</h3>
            <p className="text-gray-500">J2クラブの順位表がここに表示されます</p>
          </Card>
        </TabsContent>

        <TabsContent value="j3" className="mt-6">
          <Card className="p-8 text-center">
            <Trophy className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-gray-600 mb-2">J3リーグ</h3>
            <p className="text-gray-500">J3クラブの順位表がここに表示されます</p>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
