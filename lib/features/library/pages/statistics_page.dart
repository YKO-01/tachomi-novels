import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/library_management_service.dart';
import '../../../shared/constants/app_constants.dart';
import '../providers/library_management_provider.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsState = ref.watch(statisticsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Statistics'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(statisticsProvider.notifier).refreshStatistics(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showResetDialog(context, ref),
          ),
        ],
      ),
      body: statisticsState.when(
        data: (statistics) => _buildStatisticsContent(statistics, theme),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error, theme, ref),
      ),
    );
  }

  Widget _buildStatisticsContent(ReadingStatistics statistics, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Cards
          _buildOverviewCards(statistics, theme),
          
          const SizedBox(height: AppConstants.spacingL),
          
          // Reading Time Chart
          _buildReadingTimeCard(statistics, theme),
          
          const SizedBox(height: AppConstants.spacingL),
          
          // Genre Statistics
          _buildGenreStatistics(statistics, theme),
          
          const SizedBox(height: AppConstants.spacingL),
          
          // Monthly Statistics
          _buildMonthlyStatistics(statistics, theme),
          
          const SizedBox(height: AppConstants.spacingL),
          
          // Achievement Badges
          _buildAchievementBadges(statistics, theme),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(ReadingStatistics statistics, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppConstants.spacingM,
          mainAxisSpacing: AppConstants.spacingM,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Novels Read',
              statistics.totalNovelsRead.toString(),
              Icons.library_books,
              Colors.blue,
              theme,
            ),
            _buildStatCard(
              'Chapters Read',
              statistics.totalChaptersRead.toString(),
              Icons.menu_book,
              Colors.green,
              theme,
            ),
            _buildStatCard(
              'Reading Time',
              statistics.formattedReadingTime,
              Icons.access_time,
              Colors.orange,
              theme,
            ),
            _buildStatCard(
              'Words Read',
              statistics.formattedWordsRead,
              Icons.text_fields,
              Colors.purple,
              theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, ThemeData theme) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingS,
                    vertical: AppConstants.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
                  ),
                  child: Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingTimeCard(ReadingStatistics statistics, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Time Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            Row(
              children: [
                Expanded(
                  child: _buildTimeBreakdown(
                    'Hours',
                    statistics.totalReadingTimeMinutes ~/ 60,
                    Colors.blue,
                    theme,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: _buildTimeBreakdown(
                    'Minutes',
                    statistics.totalReadingTimeMinutes % 60,
                    Colors.green,
                    theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBreakdown(String label, int value, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreStatistics(ReadingStatistics statistics, ThemeData theme) {
    if (statistics.genreStats.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: AppConstants.spacingM),
              Text(
                'No Genre Data Yet',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppConstants.spacingS),
              Text(
                'Start reading to see your genre preferences',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Genre Preferences',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            ...statistics.genreStats.entries.map((entry) {
              final total = statistics.genreStats.values.reduce((a, b) => a + b);
              final percentage = (entry.value / total * 100).round();
              
              return Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        entry.key,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: entry.value / total,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getGenreColor(entry.key),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingS),
                    Text(
                      '$percentage%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyStatistics(ReadingStatistics statistics, ThemeData theme) {
    if (statistics.monthlyStats.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: AppConstants.spacingM),
              Text(
                'No Monthly Data Yet',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppConstants.spacingS),
              Text(
                'Your monthly reading activity will appear here',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Reading Activity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            ...statistics.monthlyStats.entries.map((entry) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  child: const Icon(Icons.calendar_month, color: Colors.blue),
                ),
                title: Text(entry.key),
                trailing: Text(
                  '${entry.value} chapters',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadges(ReadingStatistics statistics, ThemeData theme) {
    final achievements = _getAchievements(statistics);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievements',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            if (achievements.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: AppConstants.spacingM),
                    Text(
                      'No Achievements Yet',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppConstants.spacingS),
                    Text(
                      'Keep reading to unlock achievements!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: AppConstants.spacingS,
                runSpacing: AppConstants.spacingS,
                children: achievements.map((achievement) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingM,
                      vertical: AppConstants.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: achievement['color'].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
                      border: Border.all(
                        color: achievement['color'].withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          achievement['icon'],
                          color: achievement['color'],
                          size: 16,
                        ),
                        const SizedBox(width: AppConstants.spacingXS),
                        Text(
                          achievement['title'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: achievement['color'],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(dynamic error, ThemeData theme, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            'Failed to Load Statistics',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            error.toString(),
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingM),
          ElevatedButton(
            onPressed: () => ref.read(statisticsProvider.notifier).refreshStatistics(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Color _getGenreColor(String genre) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.cyan,
      Colors.amber,
      Colors.brown,
    ];
    
    final index = genre.hashCode % colors.length;
    return colors[index];
  }

  List<Map<String, dynamic>> _getAchievements(ReadingStatistics statistics) {
    final achievements = <Map<String, dynamic>>[];
    
    if (statistics.totalNovelsRead >= 1) {
      achievements.add({
        'title': 'First Novel',
        'icon': Icons.library_books,
        'color': Colors.blue,
      });
    }
    
    if (statistics.totalNovelsRead >= 10) {
      achievements.add({
        'title': 'Novel Collector',
        'icon': Icons.collections_bookmark,
        'color': Colors.green,
      });
    }
    
    if (statistics.totalChaptersRead >= 100) {
      achievements.add({
        'title': 'Chapter Master',
        'icon': Icons.menu_book,
        'color': Colors.orange,
      });
    }
    
    if (statistics.totalReadingTimeMinutes >= 60) {
      achievements.add({
        'title': 'Hour Reader',
        'icon': Icons.access_time,
        'color': Colors.purple,
      });
    }
    
    if (statistics.totalWordsRead >= 100000) {
      achievements.add({
        'title': 'Word Warrior',
        'icon': Icons.text_fields,
        'color': Colors.red,
      });
    }
    
    return achievements;
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Statistics'),
        content: const Text('Are you sure you want to reset all reading statistics? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(statisticsProvider.notifier).resetStatistics();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Statistics reset')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
