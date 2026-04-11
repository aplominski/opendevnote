class RepoFilter {
  final String ownerPattern;
  final String namePattern;
  final String? language;
  final String? visibility; // 'public', 'private', null = all
  final String? status; // 'success', 'failure', 'in_progress', null = all

  const RepoFilter({
    this.ownerPattern = '',
    this.namePattern = '',
    this.language,
    this.visibility,
    this.status,
  });

  bool get isEmpty =>
      ownerPattern.isEmpty &&
      namePattern.isEmpty &&
      language == null &&
      visibility == null &&
      status == null;

  bool get hasActiveFilters => !isEmpty;

  RepoFilter copyWith({
    String? ownerPattern,
    String? namePattern,
    String? language,
    String? visibility,
    String? status,
    bool clearLanguage = false,
    bool clearVisibility = false,
    bool clearStatus = false,
  }) {
    return RepoFilter(
      ownerPattern: ownerPattern ?? this.ownerPattern,
      namePattern: namePattern ?? this.namePattern,
      language: clearLanguage ? null : (language ?? this.language),
      visibility: clearVisibility ? null : (visibility ?? this.visibility),
      status: clearStatus ? null : (status ?? this.status),
    );
  }

  int get activeCount {
    int count = 0;
    if (ownerPattern.isNotEmpty) count++;
    if (namePattern.isNotEmpty) count++;
    if (language != null) count++;
    if (visibility != null) count++;
    if (status != null) count++;
    return count;
  }
}
