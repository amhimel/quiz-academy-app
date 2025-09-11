import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_academy/screens/upload_image_screen.dart';

import '../core/constants/my_app_icons.dart';
import '../core/enums/theme_enum.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Quiz Academy"),
      //   actions: [
      //     Consumer(
      //       builder: (context, ref, child) {
      //         final themeState = ref.watch(themeProvider);
      //         return IconButton(
      //           icon: Icon(
      //             themeState == ThemeEnum.dark
      //                 ? MyAppIcons.darkMode
      //                 : MyAppIcons.lightMode,
      //           ),
      //           onPressed: () async {
      //             await ref
      //                 .read(themeProvider.notifier)
      //                 .toggleTheme(); //themeState.toggleTheme();
      //           },
      //         );
      //       },
      //     ),
      //
      //   ],
      // ),
      body: Center(
        child: Text("Home Screen")

      ),
    );
  }
}
