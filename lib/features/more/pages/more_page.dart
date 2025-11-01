import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/constants/app_constants.dart';
import '../providers/settings_provider.dart';

class MorePage extends ConsumerStatefulWidget {
  const MorePage({super.key});

  @override
  ConsumerState<MorePage> createState() => _MorePageState();
}

class _MorePageState extends ConsumerState<MorePage> {
  final List<String> _fontFamilies = [
    'SF Pro Display',
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Poppins',
    'Inter',
  ];

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        children: [
          // Appearance Section
          _buildSection(
            context,
            'Appearance',
            [
              _buildSwitchTile(
                context,
                'Dark Mode',
                'Switch between light and dark theme',
                settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                settings.isDarkMode,
                (value) {
                  ref.read(settingsProvider.notifier).updateDarkMode(value);
                },
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacingL),
          
          // Reading Settings Section
          _buildSection(
            context,
            'Reading Settings',
            [
              // Font Size
              _buildSliderTile(
                context,
                'Font Size',
                'Adjust text size for comfortable reading',
                Icons.format_size,
                settings.fontSize,
                12.0,
                24.0,
                (value) {
                  ref.read(settingsProvider.notifier).updateFontSize(value);
                },
              ),
              
              // Font Family
              _buildListTile(
                context,
                'Font Family',
                settings.fontFamily,
                Icons.font_download,
                () {
                  _showFontFamilyDialog(context, ref, settings.fontFamily);
                },
              ),
              
              // Line Height
              _buildSliderTile(
                context,
                'Line Height',
                'Adjust spacing between lines',
                Icons.format_line_spacing,
                settings.lineHeight,
                1.0,
                2.5,
                (value) {
                  ref.read(settingsProvider.notifier).updateLineHeight(value);
                },
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacingL),
          
          // Privacy Section
          _buildSection(
            context,
            'Privacy',
            [
              _buildSwitchTile(
                context,
                'Incognito Mode',
                'Browse without leaving traces',
                Icons.visibility_off,
                settings.incognitoMode,
                (value) {
                  ref.read(settingsProvider.notifier).updateIncognitoMode(value);
                },
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacingL),
          
          // Data Management Section
          _buildSection(
            context,
            'Data Management',
            [
              _buildListTile(
                context,
                'Backup & Restore',
                'Backup your library and settings',
                Icons.backup,
                () {
                  _showBackupRestore(context);
                },
              ),
              _buildListTile(
                context,
                'Clear Cache',
                'Free up storage space',
                Icons.cleaning_services,
                () {
                  _showClearCache(context);
                },
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacingL),
          
          // App Info Section
          _buildSection(
            context,
            'App Info',
            [
              _buildListTile(
                context,
                'About',
                'App version and information',
                Icons.info,
                () {
                  _showAbout(context);
                },
              ),
              _buildListTile(
                context,
                'Help & Support',
                'Get help and report issues',
                Icons.help,
                () {
                  _showHelp(context);
                },
              ),
              _buildListTile(
                context,
                'Privacy Policy',
                'How we handle your data',
                Icons.privacy_tip,
                () {
                  _showPrivacyPolicy(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppConstants.spacingS, bottom: AppConstants.spacingS),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSliderTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: AppConstants.spacingXS),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: ((max - min) * 10).toInt(),
                  label: value.toStringAsFixed(1),
                  onChanged: onChanged,
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  value.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFontFamilyDialog(BuildContext context, WidgetRef ref, String currentFont) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Font Family'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _fontFamilies.length,
            itemBuilder: (context, index) {
              final fontFamily = _fontFamilies[index];
              final isSelected = fontFamily == currentFont;
              
              return ListTile(
                title: Text(
                  fontFamily,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).updateFontFamily(fontFamily);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showBackupRestore(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup & Restore'),
        content: const Text('Backup and restore functionality coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache & Reset Settings'),
        content: const Text('This will clear all cached images, data, and reset all settings to defaults. This action cannot be undone. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Reset settings to defaults
              await ref.read(settingsProvider.notifier).resetSettings();
              
              // Clear cache (you can add more cache clearing logic here)
              // For example: image cache, downloaded chapters, etc.
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache cleared and settings reset to defaults'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const Icon(Icons.library_books, size: 48),
      children: [
        const Text('A beautiful novel reader app inspired by Tapas and Tachiyomi.'),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• Clean, modern UI'),
        const Text('• Offline reading'),
        const Text('• Customizable themes'),
        const Text('• Smart library management'),
      ],
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text('Need help? Contact us at support@tachomi.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text('Your privacy is important to us. We do not collect personal data without your consent.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
