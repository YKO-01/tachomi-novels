import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_settings.dart';
import '../../../core/services/settings_service.dart';

class SettingsNotifier extends StateNotifier<UserSettings> {
  final SettingsService _settingsService;

  SettingsNotifier(this._settingsService) : super(UserSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsService.getSettings();
      state = settings;
    } catch (e) {
      // Use default settings if loading fails
      state = UserSettings();
    }
  }

  Future<void> updateDarkMode(bool value) async {
    state = state.copyWith(isDarkMode: value);
    await _settingsService.saveSettings(state);
  }

  Future<void> updateIncognitoMode(bool value) async {
    state = state.copyWith(incognitoMode: value);
    await _settingsService.saveSettings(state);
  }

  Future<void> updateFontSize(double value) async {
    state = state.copyWith(fontSize: value);
    await _settingsService.saveSettings(state);
  }

  Future<void> updateFontFamily(String value) async {
    state = state.copyWith(fontFamily: value);
    await _settingsService.saveSettings(state);
  }

  Future<void> updateLineHeight(double value) async {
    state = state.copyWith(lineHeight: value);
    await _settingsService.saveSettings(state);
  }

  Future<void> updateSortBy(String value) async {
    state = state.copyWith(sortBy: value);
    await _settingsService.saveSettings(state);
  }

  Future<void> updateFilterBy(String value) async {
    state = state.copyWith(filterBy: value);
    await _settingsService.saveSettings(state);
  }

  Future<void> resetSettings() async {
    try {
      await _settingsService.resetSettings();
      await _loadSettings(); // Reload to get default settings
    } catch (e) {
      // If reset fails, set to defaults locally
      state = UserSettings();
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return SettingsNotifier(settingsService);
});
