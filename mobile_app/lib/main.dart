import 'package:flutter/material.dart';
import 'package:mobile_app/config/theme.dart';
import 'package:mobile_app/config/constants.dart';
import 'package:mobile_app/core/storage/local_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'core/network/dio_client.dart';
import 'core/network/api_client.dart';
import 'core/storage/local_storage.dart';
import 'data/repositories/auth_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/club/bloc/club_bloc.dart';
import 'features/club/bloc/club_event.dart';
import 'screens/login_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage
  final storage = LocalStorage();
  await storage.init();

  // Initialize Dio client with proper configuration
  final dioClient = DioClient(storage);
  final dio = dioClient.dio;

  // Use the base URL from constants (which includes 10.0.2.2 for Android emulator)
  final apiClient = ApiClient(dio, baseUrl: '${AppConstants.apiBaseUrl}${AppConstants.apiPrefix}');

  final authRepository = AuthRepository(
    apiClient: apiClient,
    localStorage: storage,
  );

  runApp(OshiSutaApp(
    authRepository: authRepository,
    apiClient: apiClient,
    localStorage: storage,
  ));
}

class OshiSutaApp extends StatelessWidget {

  final AuthRepository authRepository;
  final ApiClient apiClient;
  final LocalStorage localStorage;

  const OshiSutaApp({
    Key? key,
    required this.authRepository,
    required this.apiClient,
    required this.localStorage,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(
          value: authRepository,
        ),
        RepositoryProvider<ApiClient>.value(
          value: apiClient,
        ),
        RepositoryProvider<LocalStorage>.value(
          value: localStorage,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(authRepository: authRepository)
              ..add(const AuthCheckRequested()), // Check initial auth status
          ),
          BlocProvider(
            create: (context) => ClubBloc(
              apiClient: apiClient,
              localStorage: localStorage,
            )..add(const LoadFavoriteClub()), // Load favorite club on startup
          ),
        ],
        child: MaterialApp(
          title: 'Oshi-Suta BATTLE',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: LoginScreen(),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _storage = LocalStorage();
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _clubId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoggedIn = _storage.isLoggedIn();
      _userEmail = _storage.getUserEmail();
      _clubId = _storage.getClubId();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oshi-Suta BATTLE'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Icon(
                Icons.directions_run,
                size: 100,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Oshi-Suta BATTLE',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'J-League Supporter Fitness App',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
              const SizedBox(height: 48),

              // Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Login Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Status:'),
                          Chip(
                            label: Text(_isLoggedIn ? 'Logged In' : 'Not Logged In'),
                            backgroundColor: _isLoggedIn
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                          
                        ],
                      ),
                      if (_isLoggedIn) ...[
                        const SizedBox(height: 12),
                        if (_userEmail != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Email:'),
                              Text(
                                _userEmail!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        if (_clubId != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Club:'),
                              Text(
                                _clubId!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Login/Logout Button
              if (!_isLoggedIn)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: ((context) => LoginScreen()),
                        ),
                      );
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Login'),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // Logout
                      await _storage.clearAuth();
                      setState(() {
                        _isLoggedIn = false;
                        _userEmail = null;
                        _clubId = null;
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Logged out successfully'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: BorderSide(color: AppTheme.errorColor),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
