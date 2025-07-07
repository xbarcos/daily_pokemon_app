import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static Future<void> saveGameState(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getGameState(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> clearGameState(String todayKey) async {
    final prefs = await SharedPreferences.getInstance();
    final coins = prefs.getInt('coins') ?? 0;
    await prefs.clear();
    await prefs.setInt('coins', coins);
  }

  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('coins') ?? 0;
  }

  static Future<void> addCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('coins') ?? 0;
    await prefs.setInt('coins', current + amount);
  }
}
