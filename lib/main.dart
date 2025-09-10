import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_academy/app.dart';
import 'package:quiz_academy/core/constants/api_constant.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) async {
    await dotenv.load(fileName: "assets/.env");
    await Supabase.initialize(url: ApiConstant.baseUrl, anonKey: ApiConstant.anonKey);
    runApp(const ProviderScope(child: App()));
  });
}
