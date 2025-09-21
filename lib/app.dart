import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_academy/providers/theme_provider.dart';
import 'core/constants/theme_data.dart';
import 'core/enums/all_enum.dart';
import 'core/router/app_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context , WidgetRef ref) {
    final themeState =  ref.watch(themeProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: /*themeState == ThemeEnum.dark ? MyAppTheme.darkTheme : */ MyAppTheme.lightTheme,
    );
  }
}
