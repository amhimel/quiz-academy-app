import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstant {
  static String baseUrl = dotenv.get('SUPABASE_Url');
  static String anonKey = dotenv.get('SUPABASE_AnonKey');
}
