import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:captain_app_flutter/core/theme/app_theme.dart';
import 'package:captain_app_flutter/providers/auth_provider.dart';
import 'package:captain_app_flutter/screens/auth/login_screen.dart';
import 'package:captain_app_flutter/screens/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: CaptainApp(),
    ),
  );
}

class CaptainApp extends ConsumerStatefulWidget {
  const CaptainApp({super.key});

  @override
  ConsumerState<CaptainApp> createState() => _CaptainAppState();
}

class _CaptainAppState extends ConsumerState<CaptainApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // If it's the initial check and loading, show a nice splash screen
    if (authState.isLoading && authState.token == null && authState.user == null) {
      return MaterialApp(
        title: 'RideMate ( Captain )',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF00C853),
            ),
          ),
        ),
      );
    }

    final hasToken = authState.token != null;

    return MaterialApp(
      title: 'RideMate ( Captain )',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: hasToken ? const HomeScreen() : const LoginScreen(),
    );
  }
}

