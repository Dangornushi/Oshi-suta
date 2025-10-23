import { useState } from 'react';
import { Home, Trophy, Swords, Grid3x3 } from 'lucide-react';
import HomeScreen from './components/HomeScreen';
import WeeklyBattle from './components/WeeklyBattle';
import LeagueStandings from './components/LeagueStandings';
import Collection from './components/Collection';

export default function App() {
  const [activeTab, setActiveTab] = useState('home');

  const renderContent = () => {
    switch (activeTab) {
      case 'home':
        return <HomeScreen />;
      case 'battle':
        return <WeeklyBattle />;
      case 'league':
        return <LeagueStandings />;
      case 'collection':
        return <Collection />;
      default:
        return <HomeScreen />;
    }
  };

  return (
    <div className="size-full flex flex-col bg-gradient-to-b from-blue-50 to-white">
      {/* Main Content */}
      <div className="flex-1 overflow-auto">
        {renderContent()}
      </div>

      {/* Bottom Navigation */}
      <nav className="bg-white border-t border-gray-200 px-4 py-2 flex justify-around items-center shadow-lg">
        <button
          onClick={() => setActiveTab('home')}
          className={`flex flex-col items-center gap-1 px-4 py-2 rounded-lg transition-colors ${
            activeTab === 'home' ? 'text-blue-600 bg-blue-50' : 'text-gray-600'
          }`}
        >
          <Home className="w-6 h-6" />
          <span className="text-xs">ホーム</span>
        </button>
        <button
          onClick={() => setActiveTab('battle')}
          className={`flex flex-col items-center gap-1 px-4 py-2 rounded-lg transition-colors ${
            activeTab === 'battle' ? 'text-blue-600 bg-blue-50' : 'text-gray-600'
          }`}
        >
          <Swords className="w-6 h-6" />
          <span className="text-xs">バトル</span>
        </button>
        <button
          onClick={() => setActiveTab('league')}
          className={`flex flex-col items-center gap-1 px-4 py-2 rounded-lg transition-colors ${
            activeTab === 'league' ? 'text-blue-600 bg-blue-50' : 'text-gray-600'
          }`}
        >
          <Trophy className="w-6 h-6" />
          <span className="text-xs">リーグ</span>
        </button>
        <button
          onClick={() => setActiveTab('collection')}
          className={`flex flex-col items-center gap-1 px-4 py-2 rounded-lg transition-colors ${
            activeTab === 'collection' ? 'text-blue-600 bg-blue-50' : 'text-gray-600'
          }`}
        >
          <Grid3x3 className="w-6 h-6" />
          <span className="text-xs">コレクション</span>
        </button>
      </nav>
    </div>
  );
}
