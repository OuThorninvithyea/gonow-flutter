import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/saved_vehicles_provider.dart';

void main() {
  runApp(const GoNowApp());
}

class GoNowApp extends StatelessWidget {
  const GoNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()..load()),
        ChangeNotifierProvider(create: (_) => SavedVehiclesProvider()),
      ],
      child: MaterialApp.router(
        title: 'GoNow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}
