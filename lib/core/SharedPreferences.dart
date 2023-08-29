import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefController {
  static late SharedPreferences sharedPreferences;
  static SharedPrefController? _instance;

  SharedPrefController._();

  init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  factory SharedPrefController() {
    return _instance ??= SharedPrefController._();
  }

  Future<bool> removeData({
    required String key,
  }) async {
    return await sharedPreferences.remove(key);
  }

  setData(String key, var value) async {
    if (value is bool) return await sharedPreferences.setBool(key, value);
    if (value is String) return await sharedPreferences.setString(key, value);
  }

  getString({
    required String key,
  }) {
    return sharedPreferences.getString(key)?? [];
  }

  dynamic getData({
    required String key,
    bool defaultValue = false,
  }) {
    dynamic value = sharedPreferences.getBool(key);
    if (value == null || value is! bool) {
      return defaultValue;
    }
    return value;
  }
}
