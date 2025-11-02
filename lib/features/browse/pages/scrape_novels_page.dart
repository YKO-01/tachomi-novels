import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/novel.dart';
import '../../../core/services/novel_service.dart';
import '../../../shared/constants/app_constants.dart';

class ScrapeNovelsPage extends ConsumerStatefulWidget {
  const ScrapeNovelsPage({super.key});

  @override
  ConsumerState<ScrapeNovelsPage> createState() => _ScrapeNovelsPageState();
}

class _ScrapeNovelsPageState extends ConsumerState<ScrapeNovelsPage> {
  final TextEditingController _urlController = TextEditingController();
  bool _isScraping = false;
  List<Novel> _scrapedNovels = [];
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _scrapeNovels() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _error = 'Please enter a URL';
      });
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAbsolutePath) {
      setState(() {
        _error = 'Please enter a valid URL';
      });
      return;
    }

    setState(() {
      _isScraping = true;
      _error = null;
      _scrapedNovels = [];
    });

    try {
      final novelService = ref.read(novelServiceProvider);
      final novels = await novelService.scrapeNovelsFromUrl(url);
      
      setState(() {
        _scrapedNovels = novels;
        _isScraping = false;
      });

      if (novels.isEmpty) {
        setState(() {
          _error = 'No novels found. Please check the URL or try a different source.';
        });
      }
    } catch (e) {
      setState(() {
        _isScraping = false;
        _error = 'Error scraping novels: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrape Novels'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        children: [
          // URL Input Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter URL',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      hintText: 'https://www.royalroad.com/fiction/...',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _urlController.clear();
                          setState(() {
                            _scrapedNovels = [];
                            _error = null;
                          });
                        },
                      ),
                    ),
                    enabled: !_isScraping,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    'Supported sites: Royal Road, WebNovel, NovelFull, and generic novel sites',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isScraping ? null : _scrapeNovels,
                      icon: _isScraping
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      label: Text(_isScraping ? 'Scraping...' : 'Scrape Novels'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spacingM),

          // Error Message
          if (_error != null)
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
                    const SizedBox(width: AppConstants.spacingS),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: AppConstants.spacingM),

          // Scraped Novels List
          if (_scrapedNovels.isNotEmpty) ...[
            Text(
              'Found ${_scrapedNovels.length} novel(s)',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.spacingS),
            ..._scrapedNovels.map((novel) => _buildNovelCard(context, novel)),
          ],

          // Empty State
          if (!_isScraping && _scrapedNovels.isEmpty && _error == null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.scatter_plot,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    'Enter a URL to scrape novels',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNovelCard(BuildContext context, Novel novel) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: InkWell(
        onTap: () {
          // Navigate to novel details or add to library
          Navigator.pop(context, novel);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                child: CachedNetworkImage(
                  imageUrl: novel.coverUrl,
                  width: 80,
                  height: 120,
                  fit: BoxFit.cover,
                  httpHeaders: const {
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                  },
                  maxWidthDiskCache: 500,
                  maxHeightDiskCache: 700,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 120,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 120,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.broken_image,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              // Novel Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      novel.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.spacingXS),
                    Text(
                      'by ${novel.author}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXS),
                    Text(
                      novel.description,
                      style: theme.textTheme.bodySmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.spacingXS),
                    Wrap(
                      spacing: AppConstants.spacingXS,
                      children: [
                        Chip(
                          label: Text(novel.status),
                          labelStyle: const TextStyle(fontSize: 10),
                          padding: EdgeInsets.zero,
                        ),
                        if (novel.totalChapters > 0)
                          Chip(
                            label: Text('${novel.totalChapters} chapters'),
                            labelStyle: const TextStyle(fontSize: 10),
                            padding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

