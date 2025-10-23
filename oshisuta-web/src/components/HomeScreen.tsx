import { useState, useEffect } from 'react';
import { Footprints, MapPin, Brain, Target, ChevronRight, TrendingUp } from 'lucide-react';
import { Progress } from './ui/progress';
import { Card } from './ui/card';
import { Button } from './ui/button';

export default function HomeScreen() {
  const [clubGauge, setClubGauge] = useState(67);
  const [dailySteps, setDailySteps] = useState(8456);
  const [quizCompleted, setQuizCompleted] = useState(false);
  const [showQuiz, setShowQuiz] = useState(false);

  const todayActions = [
    {
      id: 'steps',
      icon: Footprints,
      title: '歩数連携',
      description: '今日の歩数',
      value: `${dailySteps.toLocaleString()}歩`,
      points: '+24pt',
      color: 'text-green-600',
      bgColor: 'bg-green-50',
    },
    {
      id: 'checkin',
      icon: MapPin,
      title: 'チェックイン',
      description: 'スタジアム・提携店舗',
      value: 'タップして記録',
      points: '+50pt',
      color: 'text-purple-600',
      bgColor: 'bg-purple-50',
    },
    {
      id: 'quiz',
      icon: Brain,
      title: '選手データクイズ',
      description: quizCompleted ? '本日完了' : '今日の問題',
      value: quizCompleted ? '正解！' : '挑戦する',
      points: quizCompleted ? '✓ +10pt' : '+10pt',
      color: 'text-blue-600',
      bgColor: 'bg-blue-50',
    },
  ];

  const cooperativeMission = {
    title: 'サポーター全員で地球一周に挑戦！',
    current: 32847,
    target: 40075,
    unit: 'km',
    participants: 2847,
    timeLeft: '3日23時間',
  };

  useEffect(() => {
    // Simulate step counting
    const interval = setInterval(() => {
      setDailySteps(prev => prev + Math.floor(Math.random() * 10));
    }, 3000);
    return () => clearInterval(interval);
  }, []);

  const handleQuizAnswer = (answer: number) => {
    if (answer === 2) {
      setQuizCompleted(true);
      setClubGauge(prev => Math.min(100, prev + 1));
    }
    setShowQuiz(false);
  };

  return (
    <div className="p-4 pb-6 space-y-6">
      {/* Header */}
      <div className="text-center pt-4">
        <h1 className="text-blue-600">Oshi-Suta BATTLE</h1>
        <p className="text-gray-600 mt-1">365日の応援を、クラブの力に。</p>
      </div>

      {/* Club Gauge */}
      <Card className="p-6 bg-gradient-to-br from-blue-600 to-blue-800 text-white">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2 className="text-white">浦和レッズ</h2>
            <p className="text-blue-100 text-sm mt-1">クラブゲージ</p>
          </div>
          <div className="text-right">
            <div className="text-3xl">{clubGauge}%</div>
            <div className="text-blue-100 text-sm flex items-center gap-1">
              <TrendingUp className="w-4 h-4" />
              今週 +12%
            </div>
          </div>
        </div>
        <Progress value={clubGauge} className="h-3 bg-blue-400/30" />
        <p className="text-blue-100 text-sm mt-3">
          全サポーターの応援が集結中！🔥
        </p>
      </Card>

      {/* Daily Actions */}
      <div>
        <h3 className="mb-3">今日の応援アクション</h3>
        <div className="space-y-3">
          {todayActions.map((action) => (
            <Card
              key={action.id}
              className="p-4 cursor-pointer hover:shadow-md transition-shadow"
              onClick={() => {
                if (action.id === 'quiz' && !quizCompleted) {
                  setShowQuiz(true);
                }
              }}
            >
              <div className="flex items-center gap-4">
                <div className={`p-3 rounded-lg ${action.bgColor}`}>
                  <action.icon className={`w-6 h-6 ${action.color}`} />
                </div>
                <div className="flex-1">
                  <div className="flex items-center justify-between">
                    <h4>{action.title}</h4>
                    <span className="text-green-600 text-sm">{action.points}</span>
                  </div>
                  <p className="text-gray-600 text-sm">{action.description}</p>
                  <p className={`text-sm mt-1 ${quizCompleted && action.id === 'quiz' ? 'text-green-600' : 'text-gray-800'}`}>
                    {action.value}
                  </p>
                </div>
                <ChevronRight className="w-5 h-5 text-gray-400" />
              </div>
            </Card>
          ))}
        </div>
      </div>

      {/* Cooperative Mission */}
      <Card className="p-5 border-2 border-orange-200 bg-gradient-to-br from-orange-50 to-yellow-50">
        <div className="flex items-start gap-3 mb-4">
          <Target className="w-6 h-6 text-orange-600 mt-1" />
          <div className="flex-1">
            <h3 className="text-orange-900">{cooperativeMission.title}</h3>
            <p className="text-orange-700 text-sm mt-1">
              {cooperativeMission.participants.toLocaleString()}人が参加中
            </p>
          </div>
        </div>
        <div className="space-y-2">
          <div className="flex justify-between text-sm">
            <span className="text-orange-800">
              {cooperativeMission.current.toLocaleString()} / {cooperativeMission.target.toLocaleString()} {cooperativeMission.unit}
            </span>
            <span className="text-orange-600">残り {cooperativeMission.timeLeft}</span>
          </div>
          <Progress 
            value={(cooperativeMission.current / cooperativeMission.target) * 100} 
            className="h-2 bg-orange-200"
          />
        </div>
      </Card>

      {/* Quiz Dialog */}
      {showQuiz && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <Card className="p-6 max-w-md w-full">
            <h3 className="mb-4">本日の選手クイズ</h3>
            <p className="mb-6">
              浦和レッズで最も多くの公式戦に出場している選手は？
            </p>
            <div className="space-y-2">
              <Button
                variant="outline"
                className="w-full justify-start"
                onClick={() => handleQuizAnswer(1)}
              >
                A. 興梠慎三
              </Button>
              <Button
                variant="outline"
                className="w-full justify-start"
                onClick={() => handleQuizAnswer(2)}
              >
                B. 西川周作
              </Button>
              <Button
                variant="outline"
                className="w-full justify-start"
                onClick={() => handleQuizAnswer(3)}
              >
                C. 岩波拓也
              </Button>
            </div>
            <Button
              variant="ghost"
              className="w-full mt-4"
              onClick={() => setShowQuiz(false)}
            >
              キャンセル
            </Button>
          </Card>
        </div>
      )}
    </div>
  );
}
