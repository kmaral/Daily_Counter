import 'package:shared_preferences/shared_preferences.dart';

class CounterSharedPref {
  static void setTheme(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("themeInfo");
    prefs.setString("themeInfo", value);
  }

  static Future<String> getTheme(String key) async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getString(key));
    return prefs.getString(key);
  }
}
