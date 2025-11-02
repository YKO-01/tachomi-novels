import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/constants/app_constants.dart';
import '../providers/settings_provider.dart';
import '../../../core/services/history_service.dart';
import '../../../core/services/favorites_service.dart';
import '../../../core/services/library_service.dart';
import '../../../core/services/library_management_service.dart';
import '../../history/providers/history_provider.dart';
import '../../favorites/providers/favorites_provider.dart';

class MorePage extends ConsumerStatefulWidget {
  const MorePage({super.key});

  @override
  ConsumerState<MorePage> createState() => _MorePageState();
}

class _MorePageState extends ConsumerState<MorePage> {
  final List<String> _fontFamilies = [
    'Default',
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Poppins',
    'Inter',
    'Roboto Mono',
    'Source Sans Pro',
    'Noto Sans',
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
          
          // Data Management Section
          _buildSection(
            context,
            'Data Management',
            [
              // _buildListTile(
              //   context,
              //   'Backup & Restore',
              //   'Backup your library and settings',
              //   Icons.backup,
              //   () {
              //     _showBackupRestore(context);
              //   },
              // ),
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
              // _buildListTile(
              //   context,
              //   'Help & Support',
              //   'Get help and report issues',
              //   Icons.help,
              //   () {
              //     _showHelp(context);
              //   },
              // ),
              // _buildListTile(
              //   context,
              //   'Privacy Policy',
              //   'How we handle your data',
              //   Icons.privacy_tip,
              //   () {
              //     _showPrivacyPolicy(context);
              //   },
              // ),
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
              
              // Get the font style for preview
              TextStyle? previewStyle;
              switch (fontFamily) {
                case 'Roboto':
                  previewStyle = GoogleFonts.roboto(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal);
                  break;
                case 'Open Sans':
                  previewStyle = GoogleFonts.openSans(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal);
                  break;
                case 'Lato':
                  previewStyle = GoogleFonts.lato(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal);
                  break;
                case 'Montserrat':
                  previewStyle = GoogleFonts.montserrat(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal);
                  break;
                case 'Poppins':
                  previewStyle = GoogleFonts.poppins(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal);
                  break;
                case 'Inter':
                  previewStyle = GoogleFonts.inter(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal);
                  break;
                case 'Roboto Mono':
                  previewStyle = GoogleFonts.robotoMono(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal);
                  break;
                case 'Source Sans Pro':
                  previewStyle = GoogleFonts.sourceSans3(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal);
                  break;
                case 'Noto Sans':
                  previewStyle = GoogleFonts.notoSans(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal);
                  break;
                default: // 'Default'
                  previewStyle = TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal);
              }
              
              return ListTile(
                title: Text(
                  fontFamily,
                  style: previewStyle,
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
        title: const Text('Clear All Data & Reset Settings'),
        content: const Text(
          'This will permanently delete:\n'
          '• All reading history\n'
          '• All favorites\n'
          '• All library data\n'
          '• All settings (will reset to defaults)\n'
          '• All cached images\n\n'
          'This action cannot be undone. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                // Clear history
                await HistoryService.clearAllHistory();
                ref.invalidate(historyProvider);
                
                // Clear favorites
                await FavoritesService.clearFavorites();
                ref.invalidate(favoritesProvider);
                
                // Clear library (both services)
                await LibraryService.clearLibrary();
                await LibraryManagementService.clearAllLibraryData();
                
                // Reset settings to defaults
                await ref.read(settingsProvider.notifier).resetSettings();
                
                // Clear cache (you can add more cache clearing logic here)
                // For example: image cache, downloaded chapters, etc.
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data cleared and settings reset to defaults'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              } catch (error) {
                debugPrint('Error clearing data: $error');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error clearing data: $error'),
                      duration: const Duration(seconds: 3),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
      applicationName: "Tachiyomi",
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const Icon(Icons.library_books, size: 48),
      children: [
        const Text('A beautiful novel reader app.'),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• Clean, modern UI'),
        // const Text('• Offline reading'),
        const Text('• Customizable themes'),
        const Text('• Smart reading experience'),
      ],
    );
  }

  // void _showHelp(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Help & Support'),
  //       content: const Text('Need help? Contact us at ahmedyakoubi.1337@gmail.com'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Close'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _showPrivacyPolicy(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Privacy Policy'),
  //       content: const Text('Your privacy is important to us. We do not collect personal data without your consent.'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Close'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
