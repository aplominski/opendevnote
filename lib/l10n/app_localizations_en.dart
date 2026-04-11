// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OpenDevNote';

  @override
  String get navigationToday => 'Today';

  @override
  String get navigationInbox => 'Unplanned';

  @override
  String get navigationCalendar => 'Calendar';

  @override
  String get navigationCalculator => 'Calculator';

  @override
  String get navigationWorkTime => 'Work Time';

  @override
  String get navigationNews => 'News';

  @override
  String get navigationRepos => 'Repositories';

  @override
  String get navigationProjects => 'Projects';

  @override
  String get navigationDeployments => 'Deployments';

  @override
  String get buttonAdd => 'Add';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonSave => 'Save';

  @override
  String get buttonCreate => 'Create';

  @override
  String get buttonClose => 'Close';

  @override
  String get buttonEdit => 'Edit';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonRefresh => 'Refresh';

  @override
  String get buttonChange => 'Change';

  @override
  String get buttonBack => 'Back';

  @override
  String get buttonClear => 'Clear';

  @override
  String get buttonHideFunctions => 'Hide functions';

  @override
  String get buttonShowFunctions => 'Advanced functions';

  @override
  String get buttonSetDeadline => 'Set deadline';

  @override
  String get buttonClearHistory => 'Clear history';

  @override
  String get labelTitle => 'Title';

  @override
  String get labelDescription => 'Description';

  @override
  String get labelDescriptionOptional => 'Description (optional)';

  @override
  String get labelCategory => 'Category';

  @override
  String get labelCategoryOptional => 'Category (optional)';

  @override
  String get labelProjectName => 'Project name';

  @override
  String get labelDeadline => 'Deadline';

  @override
  String get labelLanguage => 'Language';

  @override
  String get labelColor => 'Color';

  @override
  String get labelIcon => 'Icon';

  @override
  String get labelTags => 'Tags';

  @override
  String get labelAccountName => 'Account name';

  @override
  String get labelFrom => 'From';

  @override
  String get labelTo => 'To';

  @override
  String get labelTask => 'Task';

  @override
  String get labelCreated => 'Created';

  @override
  String get labelJobs => 'Jobs';

  @override
  String get labelCommits => 'Commits';

  @override
  String get labelBranches => 'Branches';

  @override
  String get labelCharts => 'Charts';

  @override
  String get labelFilters => 'Filters';

  @override
  String get labelVisibility => 'Visibility';

  @override
  String get labelStatus => 'Status';

  @override
  String get labelHistory => 'History';

  @override
  String get labelPopular => 'Popular';

  @override
  String get labelNumeric => 'Numeric';

  @override
  String get labelTaskName => 'Task';

  @override
  String get labelActiveTimer => 'Active timer';

  @override
  String get labelLastWeek => 'Last week';

  @override
  String get labelTodaySessions => 'Today\'s sessions';

  @override
  String get labelTasks => 'Tasks';

  @override
  String get labelNotes => 'Notes';

  @override
  String get labelCodeSnippets => 'Code snippets';

  @override
  String labelCompleted(Object count) {
    return 'Completed ($count)';
  }

  @override
  String get labelYourAccounts => 'Your accounts';

  @override
  String get labelAddAccount => 'Add account';

  @override
  String get labelEditor => 'Editor';

  @override
  String get labelPreview => 'Preview';

  @override
  String get placeholderSearch => 'Search...';

  @override
  String get placeholderSearchProjects => 'Search projects...';

  @override
  String get placeholderSearchNotesTasks => 'Search notes and tasks...';

  @override
  String get placeholderEnterTitle => 'Enter title...';

  @override
  String get placeholderEnterTaskTitle => 'Enter task title...';

  @override
  String get placeholderEnterNoteTitle => 'Enter note title...';

  @override
  String get placeholderEnterEventTitle => 'Enter event title...';

  @override
  String get placeholderEnterDescription => 'Enter description...';

  @override
  String get placeholderEnterNoteContent => 'Enter note content...';

  @override
  String get placeholderEnterContent => 'Enter content in Markdown...';

  @override
  String get placeholderAdditionalDescription => 'Additional description...';

  @override
  String get placeholderEnterProjectName => 'Enter name...';

  @override
  String get placeholderNewTag => 'New tag...';

  @override
  String get placeholderFeedUrl => 'Feed URL';

  @override
  String get placeholderCategoryExample => 'Tech, Sport, Science...';

  @override
  String get placeholderCategoryTech => 'Tech, Sport...';

  @override
  String get placeholderAccountExample => 'e.g. Work, Personal';

  @override
  String placeholderExampleMode(Object example) {
    return 'e.g. $example';
  }

  @override
  String get dialogNewProject => 'New project';

  @override
  String get dialogEditProject => 'Edit project';

  @override
  String get dialogProjectTags => 'Project tags';

  @override
  String get dialogNewTask => 'New task';

  @override
  String get dialogEditTask => 'Edit task';

  @override
  String get dialogNewNote => 'New note';

  @override
  String get dialogEditNote => 'Edit note';

  @override
  String get dialogDeleteNote => 'Delete note';

  @override
  String dialogDeleteNoteConfirm(Object title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get dialogNewEvent => 'New event';

  @override
  String get dialogNewCodeSnippet => 'New code snippet';

  @override
  String get dialogEditSnippet => 'Edit snippet';

  @override
  String get dialogAddRssFeed => 'Add RSS feed';

  @override
  String get dialogRssSettings => 'RSS settings';

  @override
  String get dialogCommitDetails => 'Commit details';

  @override
  String get dialogWorkflowDetails => 'Workflow details';

  @override
  String get dialogGitHubAccounts => 'GitHub accounts';

  @override
  String get dialogKeyboardShortcuts => 'Keyboard shortcuts';

  @override
  String get dialogCategory => 'Category';

  @override
  String get dialogCategoryName => 'Category name';

  @override
  String get emptyStateNoProjects => 'No projects';

  @override
  String get emptyStateCreateFirstProject => 'Create your first project';

  @override
  String get emptyStateNoTasksToday => 'No tasks for today';

  @override
  String get emptyStatePlanYourDay => 'Plan your day';

  @override
  String get emptyStateUnplannedEmpty => 'Unplanned is empty';

  @override
  String get emptyStateUnplannedHint =>
      'Tasks without deadline will appear here';

  @override
  String get emptyStateNoTasks => 'No tasks';

  @override
  String get emptyStateNoNotes => 'No notes';

  @override
  String get emptyStateNoCodeSnippets => 'No code snippets';

  @override
  String get emptyStateNoHistory => 'No history';

  @override
  String get emptyStateNoBranches => 'No branches';

  @override
  String get emptyStateNoFeeds => 'No feeds';

  @override
  String get emptyStateNoArticles => 'No articles';

  @override
  String get emptyStateNoArticlesInFeed => 'No articles in this feed';

  @override
  String get emptyStateNoWorkflowRuns => 'No workflow runs';

  @override
  String get emptyStateNoDeployments => 'No deployments found';

  @override
  String get emptyStateNoGitHubAccounts => 'No GitHub accounts';

  @override
  String get emptyStateAddGitHubAccount => 'Add GitHub account in settings';

  @override
  String get emptyStateNoResults => 'No results';

  @override
  String get emptyStateNoResultsForFilters => 'No results for filters';

  @override
  String get emptyStateNoReposWithWorkflows => 'No repositories with workflows';

  @override
  String get emptyStateChangeFilters => 'Change filters to see repositories';

  @override
  String get emptyStateNoReposFound =>
      'No repositories with GitHub Actions found';

  @override
  String get emptyStateNoJobs => 'No jobs';

  @override
  String get emptyStateNoTags => 'No tags';

  @override
  String get emptyStateGitHubDeletesJobs =>
      'GitHub deleted job data after 90 days retention.';

  @override
  String get emptyStateNoStepData =>
      'No step data (GitHub deletes after 90 days)';

  @override
  String get errorSyntaxError => 'Syntax error';

  @override
  String get errorSyntaxErrorLeft => 'Syntax error (left side):';

  @override
  String get errorSyntaxErrorRight => 'Syntax error (right side):';

  @override
  String get errorPrefix => 'Error:';

  @override
  String get errorMathError => 'Error';

  @override
  String get errorInvalidNumbers => 'Error: invalid numbers';

  @override
  String get errorIntervalBounds => 'Error: a > b';

  @override
  String get errorNoInequalityOperator =>
      'Error: missing inequality operator (>, <, >=, <=)';

  @override
  String get errorNoSolutions => 'No solutions';

  @override
  String get errorUndefined => 'Undefined';

  @override
  String get errorDoesNotExist => 'Does not exist';

  @override
  String errorFeedFetchFailed(Object error) {
    return 'Failed to fetch feed: $error';
  }

  @override
  String get errorNoGitHubAccount => 'No GitHub account';

  @override
  String get errorInvalidGitHubToken => 'Invalid GitHub token';

  @override
  String get errorNoRepoPermissions => 'No repository permissions';

  @override
  String get errorRepoNotFound => 'Repository not found';

  @override
  String get errorGitHubApi => 'GitHub API error:';

  @override
  String get errorLoadingJobs => 'Error loading jobs:';

  @override
  String get errorLoadingRepos => 'Error loading repos:';

  @override
  String get errorLoadingCommits => 'Error loading commits:';

  @override
  String get errorLoadingCommit => 'Error loading commit:';

  @override
  String get errorLoadingBranches => 'Error loading branches:';

  @override
  String get errorLoadingStats => 'Error loading statistics:';

  @override
  String get errorInvalidRepoName => 'Invalid repo name';

  @override
  String get errorUnknownTask => 'Unknown task';

  @override
  String get errorFormatExpr => 'Format: expr | x→value';

  @override
  String get errorFormatInterval => 'Format: [a, b] or (a, b)';

  @override
  String get statusLoading => 'Loading...';

  @override
  String get statusSaving => 'Saving...';

  @override
  String get statusAllCommitsLoaded => 'All commits loaded';

  @override
  String get statusNoDeployments => 'No deployments';

  @override
  String get statusClickToLoad => 'Click to load';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusSuccess => 'Success';

  @override
  String get statusFailure => 'Failure';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusTimeout => 'Timeout';

  @override
  String get statusPublic => 'Public';

  @override
  String get statusPrivate => 'Private';

  @override
  String get statusAll => 'All';

  @override
  String get statusNone => 'None';

  @override
  String get fileStatusAdded => 'Added';

  @override
  String get fileStatusDeleted => 'Deleted';

  @override
  String get fileStatusModified => 'Modified';

  @override
  String get fileStatusRenamed => 'Renamed';

  @override
  String get fileModifiedFiles => 'Modified files';

  @override
  String fileCount(Object count) {
    return '$count file(s)';
  }

  @override
  String get timeYesterday => 'yesterday';

  @override
  String get timeYesterdayCapitalized => 'Yesterday';

  @override
  String get timeDayBeforeYesterday => 'Day before yesterday';

  @override
  String get timeToday => 'Today';

  @override
  String get timeTomorrow => 'Tomorrow';

  @override
  String timeDays(Object count) {
    return '$count days';
  }

  @override
  String timeSecondsAgo(Object count) {
    return '${count}s ago';
  }

  @override
  String timeMinutesAgo(Object count) {
    return '${count}m ago';
  }

  @override
  String timeHoursAgo(Object count) {
    return '${count}h ago';
  }

  @override
  String timeDaysAgo(Object count) {
    return '${count}d ago';
  }

  @override
  String timeVsYesterday(Object diff) {
    return '${diff}min vs yesterday';
  }

  @override
  String timeYesterdayTotal(Object duration) {
    return 'Yesterday: $duration';
  }

  @override
  String timeFrom(Object time) {
    return 'from $time';
  }

  @override
  String timeTodayTime(Object time) {
    return 'Today $time';
  }

  @override
  String timeTomorrowTime(Object time) {
    return 'Tomorrow $time';
  }

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get weekdayShortMon => 'Mon';

  @override
  String get weekdayShortTue => 'Tue';

  @override
  String get weekdayShortWed => 'Wed';

  @override
  String get weekdayShortThu => 'Thu';

  @override
  String get weekdayShortFri => 'Fri';

  @override
  String get weekdayShortSat => 'Sat';

  @override
  String get weekdayShortSun => 'Sun';

  @override
  String get weekdayShortAltMon => 'Mon';

  @override
  String get weekdayShortAltTue => 'Tue';

  @override
  String get weekdayShortAltWed => 'Wed';

  @override
  String get weekdayShortAltThu => 'Thu';

  @override
  String get weekdayShortAltFri => 'Fri';

  @override
  String get weekdayShortAltSat => 'Sat';

  @override
  String get weekdayShortAltSun => 'Sun';

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get monthGenJanuary => 'January';

  @override
  String get monthGenFebruary => 'February';

  @override
  String get monthGenMarch => 'March';

  @override
  String get monthGenApril => 'April';

  @override
  String get monthGenMay => 'May';

  @override
  String get monthGenJune => 'June';

  @override
  String get monthGenJuly => 'July';

  @override
  String get monthGenAugust => 'August';

  @override
  String get monthGenSeptember => 'September';

  @override
  String get monthGenOctober => 'October';

  @override
  String get monthGenNovember => 'November';

  @override
  String get monthGenDecember => 'December';

  @override
  String get converterLength => 'Length';

  @override
  String get converterMass => 'Mass';

  @override
  String get converterTemperature => 'Temperature';

  @override
  String get converterTime => 'Time';

  @override
  String get converterSpeed => 'Speed';

  @override
  String get converterVolume => 'Volume';

  @override
  String get converterData => 'Data';

  @override
  String get converterAngle => 'Angle';

  @override
  String get converterTabLabel => 'Converter';

  @override
  String get converterAddFunction => 'Add function';

  @override
  String get tabCalculator => 'Calculator';

  @override
  String get tabConverter => 'Converter';

  @override
  String get tabGraph => 'Graph';

  @override
  String get tooltipRefresh => 'Refresh';

  @override
  String get tooltipSettings => 'Settings';

  @override
  String get tooltipSave => 'Save';

  @override
  String get tooltipSaveCtrlS => 'Save (Ctrl+S)';

  @override
  String get tooltipBack => 'Back';

  @override
  String get tooltipAddFeed => 'Add feed';

  @override
  String get tooltipRefreshAll => 'Refresh all';

  @override
  String get tooltipNewNote => 'New note';

  @override
  String get tooltipNewTask => 'New task';

  @override
  String get tooltipNewCodeSnippet => 'New code snippet';

  @override
  String get tooltipNewProject => 'New project';

  @override
  String get tooltipNewEvent => 'Add event (Ctrl+E)';

  @override
  String get tooltipRemoveFromFavorites => 'Remove from favorites';

  @override
  String get tooltipAddToFavorites => 'Add to favorites';

  @override
  String get tooltipDeleteAccount => 'Delete';

  @override
  String get tooltipDeleteNote => 'Delete note';

  @override
  String get tooltipHidePreview => 'Hide preview';

  @override
  String get tooltipShowPreview => 'Show preview';

  @override
  String get tooltipDayView => 'Day view';

  @override
  String get tooltipWeekView => 'Week view';

  @override
  String get tooltipMonthView => 'Month view';

  @override
  String get tooltipTags => 'Tags';

  @override
  String get menuEdit => 'Edit';

  @override
  String get menuDelete => 'Delete';

  @override
  String get menuRefresh => 'Refresh';

  @override
  String get menuMarkAllRead => 'Mark all as read';

  @override
  String get menuChangeCategory => 'Change category';

  @override
  String get menuDeleteFeed => 'Delete feed';

  @override
  String get menuMarkAsUnread => 'Mark as unread';

  @override
  String get menuMarkAsRead => 'Mark as read';

  @override
  String get settingsAutoRefresh => 'Auto refresh';

  @override
  String settingsAutoRefreshDesc(Object minutes) {
    return 'Refreshes feeds every $minutes min';
  }

  @override
  String get settingsInterval => 'Interval:';

  @override
  String get settingsAutoCleanup => 'Auto cleanup';

  @override
  String settingsAutoCleanupDesc(Object days) {
    return 'Deletes articles older than $days days';
  }

  @override
  String get settingsDaysThreshold => 'After how many days:';

  @override
  String get settingsSplitView => 'Split view';

  @override
  String get settingsSplitViewFeedList => 'Feed list + articles';

  @override
  String get settingsSplitViewArticlesOnly => 'Articles only';

  @override
  String get shortcutNewNoteProject => 'New note in current project';

  @override
  String get shortcutNewTaskProject => 'New task in current project';

  @override
  String get shortcutToggleHelp => 'Show/hide shortcuts help';

  @override
  String get shortcutSearchNotes => 'Search notes (command bar)';

  @override
  String get shortcutNewEvent => 'New event in calendar';

  @override
  String get shortcutZoomCalendar => 'Zoom in/out calendar view';

  @override
  String get shortcutNavMonthWeek => 'Navigate month / week';

  @override
  String get shortcutNavDay => 'Navigate day';

  @override
  String get chartCommitActivity => 'Commit activity (last year)';

  @override
  String get chartCodeFrequency => 'Code frequency (last 6 months)';

  @override
  String get chartLegendAdditions => 'Additions';

  @override
  String get chartLegendDeletions => 'Deletions';

  @override
  String get chartActivityDayHour => 'Activity (day × hour)';

  @override
  String get chartShareLast52 => 'Share (last 52 weeks)';

  @override
  String get chartLegendAllCommits => 'All commits';

  @override
  String get notificationChannelDeadlines => 'Task deadlines';

  @override
  String get notificationChannelDeadlinesDesc =>
      'Notifications about task deadlines';

  @override
  String get notificationTestTitle => 'Test notification';

  @override
  String get notificationTestBody => 'If you see this, it works!';

  @override
  String get notificationTaskDeadline => 'Task deadline';

  @override
  String get badgeNote => 'Note';

  @override
  String get badgeTask => 'Task';

  @override
  String get actionLinkTask => 'Link with task';

  @override
  String get actionLinkedTask => 'Linked task';

  @override
  String get actionOptionalTo => 'To (optional)';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageDesc => 'Choose interface language';

  @override
  String get settingsLanguagePolish => 'Polish';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsDataManagement => 'Data management';

  @override
  String get settingsExportData => 'Export data';

  @override
  String get settingsExportDataDesc => 'Save all data to JSON file';

  @override
  String get settingsImportData => 'Import data';

  @override
  String get settingsImportDataDesc => 'Load data from JSON file';

  @override
  String get settingsExportSuccess => 'Data exported successfully';

  @override
  String get settingsImportSuccess => 'Data imported successfully';

  @override
  String get settingsImportConfirm =>
      'Are you sure you want to import data? Current data will be replaced.';

  @override
  String get buttonImport => 'Import';

  @override
  String get calcModeEval => 'Eval';

  @override
  String get calcModeDerive => 'Derivative';

  @override
  String get calcModeIntegrate => 'Integral';

  @override
  String get calcModeSolve => 'Equation';

  @override
  String get calcModeLimit => 'Limit';

  @override
  String get calcModeSimplify => 'Simplify';

  @override
  String get calcModeInequality => 'Inequality';

  @override
  String get calcModeInterval => 'Interval';
}
