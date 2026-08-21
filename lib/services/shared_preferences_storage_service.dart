import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage_service.dart';

class SharedPreferencesStorageService implements LocalStorageService {
  @override
  Future<String?> readString(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(key);
  }

  @override
  Future<void> writeString(String key, String value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, value);
  }
}
