import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_settings.dart';

class SettingsService {
  static const String _kSettingsKey = 'user_settings';
  static UserSettings? _cachedSettings;
  static bool _isInitialized = false;

  Future<UserSettings> getSettings() async {
    await _ensureInitialized();
    return _cachedSettings ?? UserSettings();
  }

  Future<void> saveSettings(UserSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode({
        'isDarkMode': settings.isDarkMode,
        'downloadedOnly': settings.downloadedOnly,
        'incognitoMode': settings.incognitoMode,
        'fontSize': settings.fontSize,
        'fontFamily': settings.fontFamily,
        'lineHeight': settings.lineHeight,
        'autoDownload': settings.autoDownload,
        'wifiOnlyDownload': settings.wifiOnlyDownload,
        'sortBy': settings.sortBy,
        'filterBy': settings.filterBy,
      });
      
      await prefs.setString(_kSettingsKey, settingsJson);
      _cachedSettings = settings;
      
      debugPrint('SettingsService: Settings saved successfully');
    } catch (error) {
      debugPrint('SettingsService: Error saving settings - $error');
      rethrow;
    }
  }

  Future<void> resetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kSettingsKey);
      _cachedSettings = UserSettings();
      _isInitialized = false;
      
      debugPrint('SettingsService: Settings reset to defaults');
    } catch (error) {
      debugPrint('SettingsService: Error resetting settings - $error');
      rethrow;
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final settingsJson = prefs.getString(_kSettingsKey);
        
        if (settingsJson != null) {
          final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
          _cachedSettings = UserSettings(
            isDarkMode: settingsMap['isDarkMode'] ?? false,
            downloadedOnly: settingsMap['downloadedOnly'] ?? false,
            incognitoMode: settingsMap['incognitoMode'] ?? false,
            fontSize: (settingsMap['fontSize'] ?? 16.0).toDouble(),
            fontFamily: settingsMap['fontFamily'] ?? 'SF Pro Display',
            lineHeight: (settingsMap['lineHeight'] ?? 1.5).toDouble(),
            autoDownload: settingsMap['autoDownload'] ?? false,
            wifiOnlyDownload: settingsMap['wifiOnlyDownload'] ?? true,
            sortBy: settingsMap['sortBy'] ?? 'Popular',
            filterBy: settingsMap['filterBy'] ?? 'All',
          );
          debugPrint('SettingsService: Loaded settings from storage');
        } else {
          _cachedSettings = UserSettings();
          debugPrint('SettingsService: No saved settings, using defaults');
        }
        
        _isInitialized = true;
      } catch (error) {
        debugPrint('SettingsService: Error loading settings - $error');
        _cachedSettings = UserSettings();
        _isInitialized = true;
      }
    }
  }
}

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});
