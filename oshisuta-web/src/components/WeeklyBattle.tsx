import { useState } from 'react';
import { Flame, Timer, Trophy, Target, Footprints, Zap, Shield } from 'lucide-react';
import { Card } from './ui/card';
import { Progress } from './ui/progress';
import { Badge } from './ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';

export default function WeeklyBattle() {
  const [activeTab, setActiveTab] = useState('current');

  const currentBattle = {
    home: {
      name: '浦和レッズ',
      score: 12847,
      logo: '🔴',
    },
    away: {
      name: '鹿島アントラーズ',
      score: 11923,
      logo: '🦌',
    },
    timeLeft: '2日14時間',
    matchDate: '2025/10/25 (土) 14:00',
  };

  const missions = [
    {
      id: 1,
      type: 'WORKHORSE',
      title: '走行距離チャレンジ',
      player: '興梠慎三',
      playerNumber: 9,
      description: 'チームの"汗かき役"のように、週末までの総走行距離を競う',
      current: 18.5,
      target: 30,
      unit: 'km',
      points: 500,
      icon: Footprints,
      color: 'text-blue-600',
      bgColor: 'bg-blue-50',
      difficulty: '中',
    },
    {
      id: 2,
      type: 'PACE',
      title: 'ペースコントロール',
      player: 'ホセ・カンテ',
      playerNumber: 10,
      description: '1kmを5分ペースで走るミッションの成功回数',
      current: 3,
      target: 7,
      unit: '回',
      points: 700,
      icon: Zap,
      color: 'text-yellow-600',
      bgColor: 'bg-yellow-50',
      difficulty: '高',
    },
    {
      id: 3,
      type: 'GUARDIAN',
      title: '継続率チャレンジ',
      player: '西川周作',
      playerNumber: 1,
      description: '鉄壁の守護神のように、日々の運動の継続率で競う',
      current: 5,
      target: 7,
      unit: '日',
      points: 600,
      icon: Shield,
      color: 'text-green-600',
      bgColor: 'bg-green-50',
      difficulty: '中',
    },
  ];

  const previousResults = [
    {
      round: 'J1 第29節',
      opponent: '横浜F・マリノス',
      opponentLogo: '⚓',
      result: '勝利',
      score: '14523 - 13891',
      realMatchResult: '実戦: 2-1 (勝)',
    },
    {
      round: 'J1 第28節',
      opponent: '川崎フロンターレ',
      opponentLogo: '🌊',
      result: '敗北',
      score: '11234 - 15678',
      realMatchResult: '実戦: 1-3 (敗)',
    },
  ];

  const myContribution = {
    totalPoints: 1847,
    rank: 127,
    totalSupporters: 8456,
  };

  return (
    <div className="p-4 pb-6 space-y-6">
      {/* Header */}
      <div className="text-center pt-4">
        <h2>ウィークリーバトル</h2>
        <p className="text-gray-600 mt-1">週末の熱狂を、応援力に。</p>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList className="grid w-full grid-cols-2">
          <TabsTrigger value="current">今週のバトル</TabsTrigger>
          <TabsTrigger value="history">過去の戦績</TabsTrigger>
        </TabsList>

        <TabsContent value="current" className="space-y-6 mt-6">
          {/* Battle Status */}
          <Card className="p-6 bg-gradient-to-br from-red-50 to-orange-50 border-2 border-red-200">
            <div className="flex items-center justify-center gap-2 mb-4">
              <Flame className="w-5 h-5 text-red-600" />
              <span className="text-red-600">バトル進行中</span>
              <Flame className="w-5 h-5 text-red-600" />
            </div>
            
            <div className="flex items-center justify-between mb-6">
              <div className="text-center flex-1">
                <div className="text-4xl mb-2">{currentBattle.home.logo}</div>
                <h3>{currentBattle.home.name}</h3>
                <div className="text-2xl mt-2">{currentBattle.home.score.toLocaleString()}</div>
              </div>
              
              <div className="text-center px-4">
                <div className="text-gray-600">VS</div>
                <Badge variant="outline" className="mt-2">
                  <Timer className="w-3 h-3 mr-1" />
                  {currentBattle.timeLeft}
                </Badge>
              </div>
              
              <div className="text-center flex-1">
                <div className="text-4xl mb-2">{currentBattle.away.logo}</div>
                <h3>{currentBattle.away.name}</h3>
                <div className="text-2xl mt-2">{currentBattle.away.score.toLocaleString()}</div>
              </div>
            </div>

            <div className="text-center text-gray-600 text-sm">
              実際の試合: {currentBattle.matchDate}
            </div>
          </Card>

          {/* My Contribution */}
          <Card className="p-5 bg-blue-600 text-white">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-blue-100 text-sm">あなたの貢献度</p>
                <div className="text-2xl mt-1">{myContribution.totalPoints.toLocaleString()}pt</div>
              </div>
              <div className="text-right">
                <p className="text-blue-100 text-sm">順位</p>
                <div className="text-2xl mt-1">
                  {myContribution.rank}位
                  <span className="text-sm text-blue-100">/{myContribution.totalSupporters.toLocaleString()}人</span>
                </div>
              </div>
            </div>
          </Card>

          {/* Missions */}
          <div>
            <h3 className="mb-3">選手シンクロミッション</h3>
            <div className="space-y-3">
              {missions.map((mission) => (
                <Card key={mission.id} className="p-5">
                  <div className="flex items-start gap-4 mb-4">
                    <div className={`p-3 rounded-lg ${mission.bgColor}`}>
                      <mission.icon className={`w-6 h-6 ${mission.color}`} />
                    </div>
                    <div className="flex-1">
                      <div className="flex items-start justify-between mb-2">
                        <div>
                          <h4>{mission.title}</h4>
                          <p className="text-gray-600 text-sm mt-1">
                            #{mission.playerNumber} {mission.player}
                          </p>
                        </div>
                        <Badge variant="outline" className={mission.difficulty === '高' ? 'border-red-300 text-red-600' : 'border-blue-300 text-blue-600'}>
                          {mission.difficulty}
                        </Badge>
                      </div>
                      <p className="text-gray-600 text-sm mb-3">{mission.description}</p>
                      
                      <div className="space-y-2">
                        <div className="flex justify-between text-sm">
                          <span>
                            {mission.current} / {mission.target} {mission.unit}
                          </span>
                          <span className="text-green-600">+{mission.points}pt</span>
                        </div>
                        <Progress 
                          value={(mission.current / mission.target) * 100} 
                          className="h-2"
                        />
                      </div>
                    </div>
                  </div>
                </Card>
              ))}
            </div>
          </div>
        </TabsContent>

        <TabsContent value="history" className="space-y-4 mt-6">
          <h3>過去のバトル戦績</h3>
          {previousResults.map((result, index) => (
            <Card key={index} className="p-5">
              <div className="flex items-center justify-between mb-3">
                <span className="text-gray-600 text-sm">{result.round}</span>
                <Badge 
                  variant={result.result === '勝利' ? 'default' : 'destructive'}
                  className={result.result === '勝利' ? 'bg-green-600' : ''}
                >
                  {result.result}
                </Badge>
              </div>
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <span className="text-2xl">{currentBattle.home.logo}</span>
                  <span>浦和レッズ</span>
                </div>
                <div className="flex items-center gap-2">
                  <span>VS</span>
                </div>
                <div className="flex items-center gap-2">
                  <span>{result.opponent}</span>
                  <span className="text-2xl">{result.opponentLogo}</span>
                </div>
              </div>
              <div className="text-center text-gray-600 text-sm mb-2">
                応援力: {result.score}
              </div>
              <div className="text-center text-gray-500 text-sm">
                {result.realMatchResult}
              </div>
            </Card>
          ))}
        </TabsContent>
      </Tabs>
    </div>
  );
}
