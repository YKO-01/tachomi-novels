import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_constants.dart';
import '../providers/settings_provider.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        children: [
          // Settings Section
          _buildSection(
            context,
            'Settings',
            [
              _buildSwitchTile(
                context,
                'Downloaded Only',
                'Show only downloaded novels',
                Icons.download,
                settings.downloadedOnly,
                (value) {
                  ref.read(settingsProvider.notifier).updateDownloadedOnly(value);
                },
              ),
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
              _buildSwitchTile(
                context,
                'Auto Download',
                'Automatically download new chapters',
                Icons.cloud_download,
                settings.autoDownload,
                (value) {
                  ref.read(settingsProvider.notifier).updateAutoDownload(value);
                },
              ),
              _buildSwitchTile(
                context,
                'WiFi Only Download',
                'Download only when connected to WiFi',
                Icons.wifi,
                settings.wifiOnlyDownload,
                (value) {
                  ref.read(settingsProvider.notifier).updateWifiOnlyDownload(value);
                },
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacingL),
          
          // Library Management Section
          _buildSection(
            context,
            'Library Management',
            [
              _buildListTile(
                context,
                'Download Queue',
                'Manage your downloads',
                Icons.download,
                () {
                  context.push('/download-queue');
                },
              ),
              _buildListTile(
                context,
                'Categories',
                'Organize your library',
                Icons.category,
                () {
                  _showCategories(context);
                },
              ),
              _buildListTile(
                context,
                'Statistics',
                'View your reading stats',
                Icons.analytics,
                () {
                  _showStatistics(context);
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

  void _showDownloadQueue(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Queue'),
        content: const Text('No downloads in queue'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCategories(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Categories'),
        content: const Text('Category management coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStatistics(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reading Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text('Total Novels'),
              trailing: Text('0'),
            ),
            const ListTile(
              title: Text('Chapters Read'),
              trailing: Text('0'),
            ),
            const ListTile(
              title: Text('Reading Time'),
              trailing: Text('0 hours'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached images and data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear'),
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
