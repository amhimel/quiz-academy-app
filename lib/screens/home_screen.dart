import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_academy/screens/upload_image_screen.dart';
import 'package:quiz_academy/widgets/shared_quiz_card.dart';

import '../core/constants/my_app_icons.dart';
import '../core/enums/all_enum.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SharedQuizCard(),

        ],
      )
    );
  }
}
