import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:provider/provider.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/app_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/user_provider.dart';
import 'providers/room_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/danmaku_settings_provider.dart';
import 'providers/subtitle_style_provider.dart';
import 'providers/player_provider.dart';
import 'providers/sync_provider.dart';
import 'providers/subtitle_provider.dart';
import 'providers/audio_track_provider.dart';
import 'themes/app_theme.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  FlutterError.onError = (details) {
    debugPrint('FlutterError: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  };
  
  try {
    MediaKit.ensureInitialized();
  } catch (e) {
    debugPrint('MediaKit initialization error: $e');
  }
  
  try {
    await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('SharedPreferences initialization error: $e');
  }
  
  runApp(const SyncroApp());
}

class SyncroApp extends StatelessWidget {
  const SyncroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
        ChangeNotifierProvider(create: (_) => DanmakuSettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => SubtitleStyleProvider()..load()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => SubtitleProvider()),
        ChangeNotifierProvider(create: (_) => AudioTrackProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              return MaterialApp(
                title: 'Syncro',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme(appProvider.dynamicColor ? lightDynamic : null),
                darkTheme: AppTheme.darkTheme(appProvider.dynamicColor ? darkDynamic : null),
                themeMode: appProvider.themeMode,
                home: const HomePage(),
              );
            },
          );
        },
      ),
    );
  }
}
