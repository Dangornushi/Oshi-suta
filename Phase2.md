## 📋 Phase 2: フロントエンド（Flutterアプリ）基盤構築
Oshi-Suta BATTLE - Phase 2 実装
Phase 1のバックエンドが完成したので、次はFlutterアプリを構築します。
Phase 2 の目標
Flutterアプリの基盤とヘルスデータ連携機能を実装してください。
技術スタック

フロントエンド: Flutter 3.16+, Dart 3.2+
状態管理: flutter_bloc 8.1+
HTTP通信: dio 5.0+
ヘルスデータ: health 10.1.0
ローカルDB: hive 2.2+

実装タスク
1. Flutterプロジェクト作成
以下のコマンドを実行してプロジェクトを作成：
```bash
cd oshi-suta-battle
flutter create --org com.oshistabattle mobile_app
cd mobile_app
```

2. pubspec.yaml
依存関係を追加：
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 状態管理
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # HTTP通信
  dio: ^5.3.3
  retrofit: ^4.0.3
  json_annotation: ^4.8.1
  
  # ヘルスデータ
  health: ^10.1.0
  permission_handler: ^11.0.1
  
  # 位置情報
  geolocator: ^10.1.0
  
  # バックグラウンド処理
  workmanager: ^0.5.1
  
  # ローカルDB
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  firebase_analytics: ^10.7.4
  
  # UI
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.6
  retrofit_generator: ^8.0.0
  json_serializable: ^6.7.1
  hive_generator: ^2.0.1
  flutter_lints: ^3.0.1
  mockito: ^5.4.4
```

3. ディレクトリ構造
以下の構造を作成：

```
mobile_app/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── config/
│   │   ├── theme.dart
│   │   └── constants.dart
│   ├── core/
│   │   ├── network/
│   │   │   ├── api_client.dart
│   │   │   └── dio_client.dart
│   │   ├── storage/
│   │   │   └── local_storage.dart
│   │   └── utils/
│   │       ├── logger.dart
│   │       └── validators.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── club_model.dart
│   │   │   └── step_log_model.dart
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart
│   │   │   ├── step_repository.dart
│   │   │   └── club_repository.dart
│   │   └── datasources/
│   │       ├── remote_datasource.dart
│   │       └── local_datasource.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── user.dart
│   │   │   └── club.dart
│   │   └── usecases/
│   │       ├── sync_steps_usecase.dart
│   │       └── get_club_stats_usecase.dart
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── splash/
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── register_screen.dart
│   │   │   ├── home/
│   │   │   │   ├── home_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── club_gauge_widget.dart
│   │   │   └── profile/
│   │   │       └── profile_screen.dart
│   │   ├── bloc/
│   │   │   ├── auth/
│   │   │   │   ├── auth_bloc.dart
│   │   │   │   ├── auth_event.dart
│   │   │   │   └── auth_state.dart
│   │   │   ├── steps/
│   │   │   │   ├── steps_bloc.dart
│   │   │   │   ├── steps_event.dart
│   │   │   │   └── steps_state.dart
│   │   │   └── club_gauge/
│   │   │       ├── club_gauge_bloc.dart
│   │   │       ├── club_gauge_event.dart
│   │   │       └── club_gauge_state.dart
│   │   └── widgets/
│   │       ├── custom_button.dart
│   │       └── loading_indicator.dart
│   └── services/
│       ├── health_service.dart
│       ├── location_service.dart
│       └── background_service.dart
├── test/
│   ├── unit/
│   └── widget/
└── integration_test/
```

4. config/constants.dart
定数を定義：

```dart
class AppConstants {
  // API
  static const String apiBaseUrl = 'http://localhost:8000';
  static const String apiVersion = 'v1';
  
  // ヘルスデータ
  static const int stepsToPointsRatio = 1000; // 1000歩 = 1ポイント
  static const int maxDailySteps = 100000;
  
  // バックグラウンド同期
  static const Duration syncInterval = Duration(hours: 1);
  
  // キャッシュ
  static const Duration cacheExpiration = Duration(minutes: 5);
}

class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String clubId = 'club_id';
}```

5. core/network/api_client.dart
Retrofit APIクライアントを定義：
```dart
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;
  
  // 認証
  @POST('/api/v1/auth/register')
  Future<UserResponse> register(@Body() UserRegisterRequest request);
  
  @POST('/api/v1/auth/login')
  Future<AuthResponse> login(@Body() LoginRequest request);
  
  @GET('/api/v1/auth/profile')
  Future<UserResponse> getProfile();
  
  // 歩数
  @POST('/api/v1/steps/sync')
  Future<StepSyncResponse> syncSteps(@Body() StepSyncRequest request);
  
  @GET('/api/v1/steps/history')
  Future<StepHistoryResponse> getStepHistory(
    @Query('start_date') String startDate,
    @Query('end_date') String endDate,
  );
  
  @GET('/api/v1/steps/stats')
  Future<StepStatsResponse> getStepStats();
  
  // クラブ
  @GET('/api/v1/clubs')
  Future<List<ClubResponse>> getClubs();
  
  @GET('/api/v1/clubs/{id}')
  Future<ClubResponse> getClub(@Path('id') String clubId);
  
  @GET('/api/v1/clubs/{id}/stats')
  Future<ClubStatsResponse> getClubStats(@Path('id') String clubId);
}
```

6. services/health_service.dart
ヘルスデータ管理サービス：

```dart
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthService {
  final Health _health = Health();
  
  static const _types = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
  ];
  
  /// 権限リクエスト
  Future<bool> requestPermissions() async {
    // Android: アクティビティ認識権限
    if (Platform.isAndroid) {
      final status = await Permission.activityRecognition.request();
      if (!status.isGranted) return false;
    }
    
    // Health権限
    final permissions = _types.map((_) => HealthDataAccess.READ).toList();
    return await _health.requestAuthorization(_types, permissions: permissions) ?? false;
  }
  
  /// 指定日の歩数取得
  Future<int> getStepsForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    
    try {
      final data = await _health.getHealthDataFromTypes(start, end, [HealthDataType.STEPS]);
      
      if (data.isEmpty) return 0;
      
      // 重複除去して合算
      final uniqueSteps = <String, int>{};
      for (var point in data) {
        final key = '${point.sourceName}_${point.dateFrom}';
        uniqueSteps[key] = (point.value as NumericHealthValue).numericValue.toInt();
      }
      
      return uniqueSteps.values.fold(0, (sum, steps) => sum + steps);
    } catch (e) {
      print('Error getting steps: $e');
      return 0;
    }
  }
  
  /// 今日の歩数取得
  Future<int> getTodaySteps() async {
    return await getStepsForDate(DateTime.now());
  }
}
```

7. services/background_service.dart
バックグラウンド同期サービス：

```dart
import 'package:workmanager/workmanager.dart';

const syncStepsTask = 'syncStepsTask';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case syncStepsTask:
        await _syncStepsInBackground();
        break;
    }
    return Future.value(true);
  });
}

Future<void> _syncStepsInBackground() async {
  // Hiveを初期化
  await Hive.initFlutter();
  
  // サービス取得
  final healthService = HealthService();
  final stepRepository = StepRepository();
  
  // 今日と昨日の歩数を同期
  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  
  for (final date in [today, yesterday]) {
    final steps = await healthService.getStepsForDate(date);
    if (steps > 0) {
      await stepRepository.syncSteps(steps, date);
    }
  }
}

class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }
  
  static Future<void> registerPeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      'sync-steps',
      syncStepsTask,
      frequency: const Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }
  
  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
}
8. presentation/bloc/steps/steps_bloc.dart
歩数管理BLoC：
dartimport 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class StepsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SyncSteps extends StepsEvent {}

class LoadStepHistory extends StepsEvent {
  final int days;
  LoadStepHistory({this.days = 30});
  @override
  List<Object?> get props => [days];
}

// States
abstract class StepsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StepsInitial extends StepsState {}

class StepsLoading extends StepsState {}

class StepsSynced extends StepsState {
  final int pointsEarned;
  final int totalPoints;
  
  StepsSynced({required this.pointsEarned, required this.totalPoints});
  
  @override
  List<Object?> get props => [pointsEarned, totalPoints];
}

class StepsHistoryLoaded extends StepsState {
  final List<StepLog> logs;
  
  StepsHistoryLoaded({required this.logs});
  
  @override
  List<Object?> get props => [logs];
}

class StepsError extends StepsState {
  final String message;
  
  StepsError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class StepsBloc extends Bloc<StepsEvent, StepsState> {
  final HealthService healthService;
  final StepRepository stepRepository;
  
  StepsBloc({
    required this.healthService,
    required this.stepRepository,
  }) : super(StepsInitial()) {
    on<SyncSteps>(_onSyncSteps);
    on<LoadStepHistory>(_onLoadStepHistory);
  }
  
  Future<void> _onSyncSteps(SyncSteps event, Emitter<StepsState> emit) async {
    emit(StepsLoading());
    
    try {
      // 今日の歩数取得
      final steps = await healthService.getTodaySteps();
      
      // サーバーに同期
      final response = await stepRepository.syncSteps(steps, DateTime.now());
      
      emit(StepsSynced(
        pointsEarned: response.pointsEarned,
        totalPoints: response.totalPoints,
      ));
    } catch (e) {
      emit(StepsError(message: e.toString()));
    }
  }
  
  Future<void> _onLoadStepHistory(LoadStepHistory event, Emitter<StepsState> emit) async {
    emit(StepsLoading());
    
    try {
      final logs = await stepRepository.getStepHistory(days: event.days);
      emit(StepsHistoryLoaded(logs: logs));
    } catch (e) {
      emit(StepsError(message: e.toString()));
    }
  }
}
```

9. presentation/screens/home/home_screen.dart
ホーム画面：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oshi-Suta BATTLE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<StepsBloc>().add(SyncSteps());
          context.read<ClubGaugeBloc>().add(LoadClubGauge());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // クラブゲージ
              const ClubGaugeWidget(),
              
              // 今日の歩数
              const TodayStepsCard(),
              
              // デイリーミッション
              const DailyMissionsCard(),
              
              // ウィークリーバトル
              const WeeklyBattleCard(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<StepsBloc>().add(SyncSteps());
        },
        child: const Icon(Icons.sync),
        tooltip: '歩数を同期',
      ),
    );
  }
}
```

10. presentation/screens/home/widgets/club_gauge_widget.dart
クラブゲージウィジェット：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClubGaugeWidget extends StatelessWidget {
  const ClubGaugeWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClubGaugeBloc, ClubGaugeState>(
      builder: (context, state) {
        if (state is ClubGaugeLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is ClubGaugeLoaded) {
          return Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // クラブ名
                  Text(
                    state.clubName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  
                  // ゲージ
                  LinearProgressIndicator(
                    value: state.gaugePercentage / 100,
                    minHeight: 20,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getClubColor(state.clubId),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // ポイント表示
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '総ポイント: ${_formatNumber(state.totalPoints)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'あなたの貢献: ${state.contribution}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  
                  // アクティブユーザー数
                  const SizedBox(height: 8),
                  Text(
                    'アクティブサポーター: ${state.activeMembers}人',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }
  
  Color _getClubColor(String clubId) {
    // クラブIDに応じたカラーを返す
    const clubColors = {
      'frontale': Color(0xFF0033A0),
      'marinos': Color(0xFF004098),
      // 他のクラブも追加
    };
    return clubColors[clubId] ?? Colors.blue;
  }
  
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
```

11. main.dart
アプリのエントリーポイント：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase初期化
  await Firebase.initializeApp();
  
  // Hive初期化
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('cache');
  
  // バックグラウンドサービス初期化
  await BackgroundService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: AuthRepository(),
          ),
        ),
        BlocProvider(
          create: (context) => StepsBloc(
            healthService: HealthService(),
            stepRepository: StepRepository(),
          ),
        ),
        BlocProvider(
          create: (context) => ClubGaugeBloc(
            clubRepository: ClubRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Oshi-Suta BATTLE',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
```

12. iOS/Android 設定
iOS (ios/Runner/Info.plist):

```xml
<key>NSHealthShareUsageDescription</key>
<string>歩数データを取得してクラブの応援ポイントに変換します</string>
<key>NSHealthUpdateUsageDescription</key>
<string>健康データの同期に使用します</string>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>processing</string>
</array>
Android (android/app/src/main/AndroidManifest.xml):
xml<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

13. テストファイル
test/services/health_service_test.dartを作成：

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('HealthService Tests', () {
    late HealthService healthService;
    
    setUp(() {
      healthService = HealthService();
    });
    
    test('getTodaySteps returns valid steps', () async {
      // テスト実装
    });
    
    test('getStepsForDate handles invalid date', () async {
      // テスト実装
    });
  });
}
```

完了基準

 すべてのファイルが作成されている
 flutter runでアプリが起動する
 ヘルスデータ権限が正しくリクエストされる
 歩数が取得できる
 APIとの通信が正常に動作する
 flutter testですべてのテストが通過

実装を開始してください。Phase 1のバックエンドと連携することを意識してください。実装の途中で実行確認を行い、段階的に開発を進めてください。
