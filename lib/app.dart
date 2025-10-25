import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    initialization();

  }
  void initialization() async {
    // Perform any initialization tasks here
    log("Splash Screen Initialization Start....");
    await Future.delayed(const Duration(seconds: 3));
    log("Splash Screen Initialization Complete....");
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }

  @override
  void dispose() {
    // Clean up here if needed
    super.dispose();
  }
}
