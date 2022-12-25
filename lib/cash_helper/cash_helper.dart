import 'package:shared_preferences/shared_preferences.dart';

class CashHelper {
  static SharedPreferences? sharedPreferences;

  static Future<SharedPreferences> init() async {
    return sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> setData({required String key,required dynamic value}) {
    if (value is int) {
      return sharedPreferences!.setInt(key, value);
    } else if (value is bool) {
      return sharedPreferences!.setBool(key, value);
    } else if (value is double) {
      return sharedPreferences!.setDouble(key, value);
    } else {
      return sharedPreferences!.setString(key, value);
    }
  }

  static getData({required String key}) {
    return sharedPreferences!.get(key);
  }
}
