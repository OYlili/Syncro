import 'package:flutter/material.dart';

class AppRoutes {
  static const String home = '/';
  static const String room = '/room';
  static const String roomDetail = '/room/:id';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String videoPlayer = '/player';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('页面未找到')),
            body: const Center(
              child: Text('404 - 页面未找到'),
            ),
          ),
        );
    }
  }

  static Map<String, WidgetBuilder> get routes => {
    AppRoutes.home: (_) => const Placeholder(),
  };
}
