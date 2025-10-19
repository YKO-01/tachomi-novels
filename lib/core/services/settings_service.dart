import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_settings.dart';

class SettingsService {
  // In a real app, this would use SharedPreferences or Hive
  // For now, we'll use in-memory storage
  static UserSettings _currentSettings = UserSettings();

  Future<UserSettings> getSettings() async {
    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 100));
    return _currentSettings;
  }

  Future<void> saveSettings(UserSettings settings) async {
    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 100));
    _currentSettings = settings;
  }

  Future<void> resetSettings() async {
    _currentSettings = UserSettings();
  }
}

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});
