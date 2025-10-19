enum FilterType {
  popular,
  latest,
  genre,
  status,
  sort,
}

enum Genre {
  all,
  romance,
  bl,
  sliceOfLife,
  fantasy,
  mystery,
  comedy,
  drama,
  action,
  sciFi,
}

enum NovelStatus {
  all,
  ongoing,
  completed,
  hiatus,
}

enum SortOption {
  title,
  dateAdded,
  rating,
  views,
  author,
}

class FilterState {
  final FilterType activeFilter;
  final Genre selectedGenre;
  final NovelStatus selectedStatus;
  final SortOption sortOption;
  final bool isGenreDropdownOpen;
  final bool isSortModalOpen;

  const FilterState({
    this.activeFilter = FilterType.popular,
    this.selectedGenre = Genre.all,
    this.selectedStatus = NovelStatus.all,
    this.sortOption = SortOption.rating,
    this.isGenreDropdownOpen = false,
    this.isSortModalOpen = false,
  });

  FilterState copyWith({
    FilterType? activeFilter,
    Genre? selectedGenre,
    NovelStatus? selectedStatus,
    SortOption? sortOption,
    bool? isGenreDropdownOpen,
    bool? isSortModalOpen,
  }) {
    return FilterState(
      activeFilter: activeFilter ?? this.activeFilter,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      sortOption: sortOption ?? this.sortOption,
      isGenreDropdownOpen: isGenreDropdownOpen ?? this.isGenreDropdownOpen,
      isSortModalOpen: isSortModalOpen ?? this.isSortModalOpen,
    );
  }

  bool get hasActiveFilters {
    return selectedGenre != Genre.all || 
           selectedStatus != NovelStatus.all ||
           activeFilter != FilterType.popular;
  }

  String get activeFilterLabel {
    switch (activeFilter) {
      case FilterType.popular:
        return 'Popular';
      case FilterType.latest:
        return 'Latest';
      case FilterType.genre:
        return selectedGenre == Genre.all ? 'Genre' : selectedGenre.name.toUpperCase();
      case FilterType.status:
        return selectedStatus == NovelStatus.all ? 'Status' : selectedStatus.name.toUpperCase();
      case FilterType.sort:
        return 'Sort';
    }
  }
}

extension GenreExtension on Genre {
  String get displayName {
    switch (this) {
      case Genre.all:
        return 'All';
      case Genre.romance:
        return 'Romance';
      case Genre.bl:
        return 'BL';
      case Genre.sliceOfLife:
        return 'Slice of Life';
      case Genre.fantasy:
        return 'Fantasy';
      case Genre.mystery:
        return 'Mystery';
      case Genre.comedy:
        return 'Comedy';
      case Genre.drama:
        return 'Drama';
      case Genre.action:
        return 'Action';
      case Genre.sciFi:
        return 'Sci-Fi';
    }
  }

  String get icon {
    switch (this) {
      case Genre.all:
        return '📚';
      case Genre.romance:
        return '💕';
      case Genre.bl:
        return '💙';
      case Genre.sliceOfLife:
        return '☕';
      case Genre.fantasy:
        return '✨';
      case Genre.mystery:
        return '🔍';
      case Genre.comedy:
        return '😄';
      case Genre.drama:
        return '🎭';
      case Genre.action:
        return '⚔️';
      case Genre.sciFi:
        return '🚀';
    }
  }
}

extension NovelStatusExtension on NovelStatus {
  String get displayName {
    switch (this) {
      case NovelStatus.all:
        return 'All';
      case NovelStatus.ongoing:
        return 'Ongoing';
      case NovelStatus.completed:
        return 'Completed';
      case NovelStatus.hiatus:
        return 'Hiatus';
    }
  }

  String get icon {
    switch (this) {
      case NovelStatus.all:
        return '📖';
      case NovelStatus.ongoing:
        return '🔄';
      case NovelStatus.completed:
        return '✅';
      case NovelStatus.hiatus:
        return '⏸️';
    }
  }
}

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.title:
        return 'Title';
      case SortOption.dateAdded:
        return 'Date Added';
      case SortOption.rating:
        return 'Rating';
      case SortOption.views:
        return 'Views';
      case SortOption.author:
        return 'Author';
    }
  }

  String get icon {
    switch (this) {
      case SortOption.title:
        return '📝';
      case SortOption.dateAdded:
        return '📅';
      case SortOption.rating:
        return '⭐';
      case SortOption.views:
        return '👀';
      case SortOption.author:
        return '✍️';
    }
  }
}
