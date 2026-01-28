import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/game_provider.dart';
import 'utils/app_colors.dart';
import 'screens/settings_screen.dart';
import 'screens/game_screen.dart';
import 'widgets/splash_screen_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const BlitzTapApp());
}

class BlitzTapApp extends StatelessWidget {
  const BlitzTapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: MaterialApp(
        title: 'BlitzTap',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.publicSansTextTheme(),
          colorScheme: ColorScheme.dark(
            primary: AppColors.active,
            surface: AppColors.surface,
            onPrimary: AppColors.textPrimary,
            onSurface: AppColors.textPrimary,
          ),
          scaffoldBackgroundColor: AppColors.background,
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreenWrapper(),
          '/settings': (context) => const SettingsScreen(),
          '/game': (context) => const GameScreen(),
        },
      ),
    );
  }
}
