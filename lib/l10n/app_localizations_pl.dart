// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'OpenDevNote';

  @override
  String get navigationToday => 'Dzisiaj';

  @override
  String get navigationInbox => 'Niezaplanowane';

  @override
  String get navigationCalendar => 'Kalendarz';

  @override
  String get navigationCalculator => 'Kalkulator';

  @override
  String get navigationWorkTime => 'Czas pracy';

  @override
  String get navigationNews => 'Wiadomości';

  @override
  String get navigationRepos => 'Repozytoria';

  @override
  String get navigationProjects => 'Projekty';

  @override
  String get navigationDeployments => 'Wdrożenia';

  @override
  String get buttonAdd => 'Dodaj';

  @override
  String get buttonCancel => 'Anuluj';

  @override
  String get buttonSave => 'Zapisz';

  @override
  String get buttonCreate => 'Utwórz';

  @override
  String get buttonClose => 'Zamknij';

  @override
  String get buttonEdit => 'Edytuj';

  @override
  String get buttonDelete => 'Usuń';

  @override
  String get buttonRefresh => 'Odśwież';

  @override
  String get buttonChange => 'Zmień';

  @override
  String get buttonBack => 'Wróć';

  @override
  String get buttonClear => 'Wyczyść';

  @override
  String get buttonHideFunctions => 'Ukryj funkcje';

  @override
  String get buttonShowFunctions => 'Funkcje zaawansowane';

  @override
  String get buttonSetDeadline => 'Ustaw termin';

  @override
  String get buttonClearHistory => 'Wyczyść historię';

  @override
  String get labelTitle => 'Tytuł';

  @override
  String get labelDescription => 'Opis';

  @override
  String get labelDescriptionOptional => 'Opis (opcjonalnie)';

  @override
  String get labelCategory => 'Kategoria';

  @override
  String get labelCategoryOptional => 'Kategoria (opcjonalnie)';

  @override
  String get labelProjectName => 'Nazwa projektu';

  @override
  String get labelDeadline => 'Termin';

  @override
  String get labelLanguage => 'Język';

  @override
  String get labelColor => 'Kolor';

  @override
  String get labelIcon => 'Ikona';

  @override
  String get labelTags => 'Tagi';

  @override
  String get labelAccountName => 'Nazwa konta';

  @override
  String get labelFrom => 'Z';

  @override
  String get labelTo => 'Do';

  @override
  String get labelTask => 'Zadanie';

  @override
  String get labelCreated => 'Utworzono';

  @override
  String get labelJobs => 'Joby';

  @override
  String get labelCommits => 'Commity';

  @override
  String get labelBranches => 'Gałęzie';

  @override
  String get labelCharts => 'Wykresy';

  @override
  String get labelFilters => 'Filtry';

  @override
  String get labelVisibility => 'Widoczność';

  @override
  String get labelStatus => 'Status';

  @override
  String get labelHistory => 'Historia';

  @override
  String get labelPopular => 'Popularne';

  @override
  String get labelNumeric => 'Liczbowe';

  @override
  String get labelTaskName => 'Zadanie';

  @override
  String get labelActiveTimer => 'Aktywny timer';

  @override
  String get labelLastWeek => 'Ostatni tydzień';

  @override
  String get labelTodaySessions => 'Dzisiejsze sesje';

  @override
  String get labelTasks => 'Zadania';

  @override
  String get labelNotes => 'Notatki';

  @override
  String get labelCodeSnippets => 'Fragmenty kodu';

  @override
  String labelCompleted(Object count) {
    return 'Ukończone ($count)';
  }

  @override
  String get labelYourAccounts => 'Twoje konta';

  @override
  String get labelAddAccount => 'Dodaj konto';

  @override
  String get labelEditor => 'Edytor';

  @override
  String get labelPreview => 'Podgląd';

  @override
  String get placeholderSearch => 'Szukaj...';

  @override
  String get placeholderSearchProjects => 'Szukaj projektów...';

  @override
  String get placeholderSearchNotesTasks => 'Wyszukaj notatki i zadania...';

  @override
  String get placeholderEnterTitle => 'Wprowadź tytuł...';

  @override
  String get placeholderEnterTaskTitle => 'Wprowadź tytuł zadania...';

  @override
  String get placeholderEnterNoteTitle => 'Wprowadź tytuł notatki...';

  @override
  String get placeholderEnterEventTitle => 'Wprowadź tytuł wydarzenia...';

  @override
  String get placeholderEnterDescription => 'Wprowadź opis...';

  @override
  String get placeholderEnterNoteContent => 'Wprowadź treść notatki...';

  @override
  String get placeholderEnterContent => 'Wprowadź treść w formacie Markdown...';

  @override
  String get placeholderAdditionalDescription => 'Dodatkowy opis...';

  @override
  String get placeholderEnterProjectName => 'Wprowadź nazwę...';

  @override
  String get placeholderNewTag => 'Nowy tag...';

  @override
  String get placeholderFeedUrl => 'URL feedu';

  @override
  String get placeholderCategoryExample => 'Tech, Sport, Nauka...';

  @override
  String get placeholderCategoryTech => 'Tech, Sport...';

  @override
  String get placeholderAccountExample => 'np. Praca, Osobiste';

  @override
  String placeholderExampleMode(Object example) {
    return 'np. $example';
  }

  @override
  String get dialogNewProject => 'Nowy projekt';

  @override
  String get dialogEditProject => 'Edytuj projekt';

  @override
  String get dialogProjectTags => 'Tagi projektu';

  @override
  String get dialogNewTask => 'Nowe zadanie';

  @override
  String get dialogEditTask => 'Edytuj zadanie';

  @override
  String get dialogNewNote => 'Nowa notatka';

  @override
  String get dialogEditNote => 'Edytuj notatkę';

  @override
  String get dialogDeleteNote => 'Usuń notatkę';

  @override
  String dialogDeleteNoteConfirm(Object title) {
    return 'Czy na pewno chcesz usunąć \"$title\"?';
  }

  @override
  String get dialogNewEvent => 'Nowe wydarzenie';

  @override
  String get dialogNewCodeSnippet => 'Nowy fragment kodu';

  @override
  String get dialogEditSnippet => 'Edytuj snippet';

  @override
  String get dialogAddRssFeed => 'Dodaj feed RSS';

  @override
  String get dialogRssSettings => 'Ustawienia RSS';

  @override
  String get dialogCommitDetails => 'Szczegóły commita';

  @override
  String get dialogWorkflowDetails => 'Szczegóły workflow';

  @override
  String get dialogGitHubAccounts => 'Konta GitHub';

  @override
  String get dialogKeyboardShortcuts => 'Skróty klawiszowe';

  @override
  String get dialogCategory => 'Kategoria';

  @override
  String get dialogCategoryName => 'Nazwa kategorii';

  @override
  String get emptyStateNoProjects => 'Brak projektów';

  @override
  String get emptyStateCreateFirstProject => 'Utwórz swój pierwszy projekt';

  @override
  String get emptyStateNoTasksToday => 'Brak zadań na dziś';

  @override
  String get emptyStatePlanYourDay => 'Zaplanuj swój dzień';

  @override
  String get emptyStateUnplannedEmpty => 'Katalog niezaplanowane jest pusty';

  @override
  String get emptyStateUnplannedHint => 'Zadania bez terminu pojawią się tutaj';

  @override
  String get emptyStateNoTasks => 'Brak zadań';

  @override
  String get emptyStateNoNotes => 'Brak notatek';

  @override
  String get emptyStateNoCodeSnippets => 'Brak fragmentów kodu';

  @override
  String get emptyStateNoHistory => 'Brak historii';

  @override
  String get emptyStateNoBranches => 'Brak gałęzi';

  @override
  String get emptyStateNoFeeds => 'Brak feedów';

  @override
  String get emptyStateNoArticles => 'Brak artykułów';

  @override
  String get emptyStateNoArticlesInFeed => 'Brak artykułów w tym feedzie';

  @override
  String get emptyStateNoWorkflowRuns => 'Brak workflow runs';

  @override
  String get emptyStateNoDeployments => 'Nie znaleziono żadnych wdrożeń';

  @override
  String get emptyStateNoGitHubAccounts => 'Brak kont GitHub';

  @override
  String get emptyStateAddGitHubAccount => 'Dodaj konto GitHub w ustawieniach';

  @override
  String get emptyStateNoResults => 'Brak wyników';

  @override
  String get emptyStateNoResultsForFilters => 'Brak wyników dla filtrów';

  @override
  String get emptyStateNoReposWithWorkflows => 'Brak repozytoriów z workflows';

  @override
  String get emptyStateChangeFilters =>
      'Zmień filtry, aby zobaczyć repozytoria';

  @override
  String get emptyStateNoReposFound =>
      'Nie znaleziono żadnych repozytoriów z GitHub Actions';

  @override
  String get emptyStateNoJobs => 'Brak jobów';

  @override
  String get emptyStateNoTags => 'Brak tagów';

  @override
  String get emptyStateGitHubDeletesJobs =>
      'GitHub usunął dane jobów po 90 dniach przechowywania.';

  @override
  String get emptyStateNoStepData =>
      'Brak danych o etapach (GitHub usuwa je po 90 dniach)';

  @override
  String get errorSyntaxError => 'Błąd składni';

  @override
  String get errorSyntaxErrorLeft => 'Błąd składni (lewa strona):';

  @override
  String get errorSyntaxErrorRight => 'Błąd składni (prawa strona):';

  @override
  String get errorPrefix => 'Błąd:';

  @override
  String get errorMathError => 'Błąd';

  @override
  String get errorInvalidNumbers => 'Błąd: nieprawidłowe liczby';

  @override
  String get errorIntervalBounds => 'Błąd: a > b';

  @override
  String get errorNoInequalityOperator =>
      'Błąd: brak operatora nierówności (>, <, >=, <=)';

  @override
  String get errorNoSolutions => 'Brak rozwiązań';

  @override
  String get errorUndefined => 'Nieokreślone';

  @override
  String get errorDoesNotExist => 'Nie istnieje';

  @override
  String errorFeedFetchFailed(Object error) {
    return 'Nie udało się pobrać feedu: $error';
  }

  @override
  String get errorNoGitHubAccount => 'Brak konta GitHub';

  @override
  String get errorInvalidGitHubToken => 'Nieprawidłowy token GitHub';

  @override
  String get errorNoRepoPermissions => 'Brak uprawnień do repozytorium';

  @override
  String get errorRepoNotFound => 'Repozytorium nie znalezione';

  @override
  String get errorGitHubApi => 'Błąd API GitHub:';

  @override
  String get errorLoadingJobs => 'Błąd ładowania jobów:';

  @override
  String get errorLoadingRepos => 'Błąd ładowania repo:';

  @override
  String get errorLoadingCommits => 'Błąd ładowania commitów:';

  @override
  String get errorLoadingCommit => 'Błąd ładowania commita:';

  @override
  String get errorLoadingBranches => 'Błąd ładowania gałęzi:';

  @override
  String get errorLoadingStats => 'Błąd ładowania statystyk:';

  @override
  String get errorInvalidRepoName => 'Nieprawidłowa nazwa repo';

  @override
  String get errorUnknownTask => 'Nieznane zadanie';

  @override
  String get errorFormatExpr => 'Format: expr | x→wartość';

  @override
  String get errorFormatInterval => 'Format: [a, b] lub (a, b)';

  @override
  String get statusLoading => 'Ładowanie...';

  @override
  String get statusSaving => 'Zapisywanie...';

  @override
  String get statusAllCommitsLoaded => 'Wszystkie commity załadowane';

  @override
  String get statusNoDeployments => 'Brak wdrożeń';

  @override
  String get statusClickToLoad => 'Kliknij aby załadować';

  @override
  String get statusInProgress => 'W trakcie';

  @override
  String get statusSuccess => 'Sukces';

  @override
  String get statusFailure => 'Niepowodzenie';

  @override
  String get statusCancelled => 'Anulowany';

  @override
  String get statusTimeout => 'Timeout';

  @override
  String get statusPublic => 'Publiczne';

  @override
  String get statusPrivate => 'Prywatne';

  @override
  String get statusAll => 'Wszystkie';

  @override
  String get statusNone => 'Brak';

  @override
  String get fileStatusAdded => 'Dodany';

  @override
  String get fileStatusDeleted => 'Usunięty';

  @override
  String get fileStatusModified => 'Zmodyfikowany';

  @override
  String get fileStatusRenamed => 'Zmieniona nazwa';

  @override
  String get fileModifiedFiles => 'Zmodyfikowane pliki';

  @override
  String fileCount(Object count) {
    return '$count plik(ów)';
  }

  @override
  String get timeYesterday => 'wczoraj';

  @override
  String get timeYesterdayCapitalized => 'Wczoraj';

  @override
  String get timeDayBeforeYesterday => 'Przedwczoraj';

  @override
  String get timeToday => 'Dzisiaj';

  @override
  String get timeTomorrow => 'Jutro';

  @override
  String timeDays(Object count) {
    return '$count dni';
  }

  @override
  String timeSecondsAgo(Object count) {
    return '${count}s temu';
  }

  @override
  String timeMinutesAgo(Object count) {
    return '${count}m temu';
  }

  @override
  String timeHoursAgo(Object count) {
    return '${count}h temu';
  }

  @override
  String timeDaysAgo(Object count) {
    return '${count}d temu';
  }

  @override
  String timeVsYesterday(Object diff) {
    return '${diff}min vs wczoraj';
  }

  @override
  String timeYesterdayTotal(Object duration) {
    return 'Wczoraj: $duration';
  }

  @override
  String timeFrom(Object time) {
    return 'od $time';
  }

  @override
  String timeTodayTime(Object time) {
    return 'Dzisiaj $time';
  }

  @override
  String timeTomorrowTime(Object time) {
    return 'Jutro $time';
  }

  @override
  String get weekdayMonday => 'Poniedziałek';

  @override
  String get weekdayTuesday => 'Wtorek';

  @override
  String get weekdayWednesday => 'Środa';

  @override
  String get weekdayThursday => 'Czwartek';

  @override
  String get weekdayFriday => 'Piątek';

  @override
  String get weekdaySaturday => 'Sobota';

  @override
  String get weekdaySunday => 'Niedziela';

  @override
  String get weekdayShortMon => 'Pn';

  @override
  String get weekdayShortTue => 'Wt';

  @override
  String get weekdayShortWed => 'Śr';

  @override
  String get weekdayShortThu => 'Czw';

  @override
  String get weekdayShortFri => 'Pt';

  @override
  String get weekdayShortSat => 'Sb';

  @override
  String get weekdayShortSun => 'Nd';

  @override
  String get weekdayShortAltMon => 'Pn';

  @override
  String get weekdayShortAltTue => 'Wt';

  @override
  String get weekdayShortAltWed => 'Śr';

  @override
  String get weekdayShortAltThu => 'Cz';

  @override
  String get weekdayShortAltFri => 'Pt';

  @override
  String get weekdayShortAltSat => 'So';

  @override
  String get weekdayShortAltSun => 'Nd';

  @override
  String get monthJanuary => 'Styczeń';

  @override
  String get monthFebruary => 'Luty';

  @override
  String get monthMarch => 'Marzec';

  @override
  String get monthApril => 'Kwiecień';

  @override
  String get monthMay => 'Maj';

  @override
  String get monthJune => 'Czerwiec';

  @override
  String get monthJuly => 'Lipiec';

  @override
  String get monthAugust => 'Sierpień';

  @override
  String get monthSeptember => 'Wrzesień';

  @override
  String get monthOctober => 'Październik';

  @override
  String get monthNovember => 'Listopad';

  @override
  String get monthDecember => 'Grudzień';

  @override
  String get monthGenJanuary => 'stycznia';

  @override
  String get monthGenFebruary => 'lutego';

  @override
  String get monthGenMarch => 'marca';

  @override
  String get monthGenApril => 'kwietnia';

  @override
  String get monthGenMay => 'maja';

  @override
  String get monthGenJune => 'czerwca';

  @override
  String get monthGenJuly => 'lipca';

  @override
  String get monthGenAugust => 'sierpnia';

  @override
  String get monthGenSeptember => 'września';

  @override
  String get monthGenOctober => 'października';

  @override
  String get monthGenNovember => 'listopada';

  @override
  String get monthGenDecember => 'grudnia';

  @override
  String get converterLength => 'Długość';

  @override
  String get converterMass => 'Masa';

  @override
  String get converterTemperature => 'Temperatura';

  @override
  String get converterTime => 'Czas';

  @override
  String get converterSpeed => 'Prędkość';

  @override
  String get converterVolume => 'Objętość';

  @override
  String get converterData => 'Dane';

  @override
  String get converterAngle => 'Kąt';

  @override
  String get converterTabLabel => 'Konwerter';

  @override
  String get converterAddFunction => 'Dodaj funkcję';

  @override
  String get tabCalculator => 'Kalkulator';

  @override
  String get tabConverter => 'Konwerter';

  @override
  String get tabGraph => 'Wykres';

  @override
  String get tooltipRefresh => 'Odśwież';

  @override
  String get tooltipSettings => 'Ustawienia';

  @override
  String get tooltipSave => 'Zapisz';

  @override
  String get tooltipSaveCtrlS => 'Zapisz (Ctrl+S)';

  @override
  String get tooltipBack => 'Wróć';

  @override
  String get tooltipAddFeed => 'Dodaj feed';

  @override
  String get tooltipRefreshAll => 'Odśwież wszystko';

  @override
  String get tooltipNewNote => 'Nowa notatka';

  @override
  String get tooltipNewTask => 'Nowe zadanie';

  @override
  String get tooltipNewCodeSnippet => 'Nowy fragment kodu';

  @override
  String get tooltipNewProject => 'Nowy projekt';

  @override
  String get tooltipNewEvent => 'Dodaj wydarzenie (Ctrl+E)';

  @override
  String get tooltipRemoveFromFavorites => 'Usuń z ulubionych';

  @override
  String get tooltipAddToFavorites => 'Dodaj do ulubionych';

  @override
  String get tooltipDeleteAccount => 'Usuń';

  @override
  String get tooltipDeleteNote => 'Usuń notatkę';

  @override
  String get tooltipHidePreview => 'Ukryj podgląd';

  @override
  String get tooltipShowPreview => 'Pokaż podgląd';

  @override
  String get tooltipDayView => 'Widok dnia';

  @override
  String get tooltipWeekView => 'Widok tygodnia';

  @override
  String get tooltipMonthView => 'Widok miesiąca';

  @override
  String get tooltipTags => 'Tagi';

  @override
  String get menuEdit => 'Edytuj';

  @override
  String get menuDelete => 'Usuń';

  @override
  String get menuRefresh => 'Odśwież';

  @override
  String get menuMarkAllRead => 'Oznacz wszystkie jako przeczytane';

  @override
  String get menuChangeCategory => 'Zmień kategorię';

  @override
  String get menuDeleteFeed => 'Usuń feed';

  @override
  String get menuMarkAsUnread => 'Oznacz jako nieprzeczytane';

  @override
  String get menuMarkAsRead => 'Oznacz jako przeczytane';

  @override
  String get settingsAutoRefresh => 'Automatyczne odświeżanie';

  @override
  String settingsAutoRefreshDesc(Object minutes) {
    return 'Odświeża feedy co $minutes min';
  }

  @override
  String get settingsInterval => 'Interwał:';

  @override
  String get settingsAutoCleanup => 'Automatyczne czyszczenie';

  @override
  String settingsAutoCleanupDesc(Object days) {
    return 'Usuwa artykuły starsze niż $days dni';
  }

  @override
  String get settingsDaysThreshold => 'Po ilu dniach:';

  @override
  String get settingsSplitView => 'Widok podzielony';

  @override
  String get settingsSplitViewFeedList => 'Lista feedów + artykuły';

  @override
  String get settingsSplitViewArticlesOnly => 'Tylko lista artykułów';

  @override
  String get shortcutNewNoteProject => 'Nowa notatka w aktualnym projekcie';

  @override
  String get shortcutNewTaskProject => 'Nowe zadanie w aktualnym projekcie';

  @override
  String get shortcutToggleHelp => 'Pokaż/ukryj pomoc skrótów';

  @override
  String get shortcutSearchNotes => 'Wyszukaj notatki (command bar)';

  @override
  String get shortcutNewEvent => 'Nowe wydarzenie w kalendarzu';

  @override
  String get shortcutZoomCalendar => 'Przybliż/oddal widok kalendarza';

  @override
  String get shortcutNavMonthWeek => 'Nawigacja miesiąc / tydzień';

  @override
  String get shortcutNavDay => 'Nawigacja dzień';

  @override
  String get chartCommitActivity => 'Aktywność commitów (ostatni rok)';

  @override
  String get chartCodeFrequency => 'Częstotliwość kodu (ostatnie 6 mies.)';

  @override
  String get chartLegendAdditions => 'Dodania';

  @override
  String get chartLegendDeletions => 'Usunięcia';

  @override
  String get chartActivityDayHour => 'Aktywność (dzień × godzina)';

  @override
  String get chartShareLast52 => 'Udział (ostatnie 52 tygodnie)';

  @override
  String get chartLegendAllCommits => 'Wszystkie commity';

  @override
  String get notificationChannelDeadlines => 'Terminy zadań';

  @override
  String get notificationChannelDeadlinesDesc =>
      'Powiadomienia o terminach zadań';

  @override
  String get notificationTestTitle => 'Test powiadomienia';

  @override
  String get notificationTestBody => 'Jeśli widzisz to, działa!';

  @override
  String get notificationTaskDeadline => 'Termin zadania';

  @override
  String get badgeNote => 'Notatka';

  @override
  String get badgeTask => 'Zadanie';

  @override
  String get actionLinkTask => 'Powiąż z zadaniem';

  @override
  String get actionLinkedTask => 'Powiązane zadanie';

  @override
  String get actionOptionalTo => 'Do (opcjonalnie)';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get settingsLanguageDesc => 'Wybierz język interfejsu';

  @override
  String get settingsLanguagePolish => 'Polski';

  @override
  String get settingsLanguageEnglish => 'Angielski';

  @override
  String get settingsLanguageSystem => 'Systemowy';

  @override
  String get settingsDataManagement => 'Zarządzanie danymi';

  @override
  String get settingsExportData => 'Eksportuj dane';

  @override
  String get settingsExportDataDesc => 'Zapisz wszystkie dane do pliku JSON';

  @override
  String get settingsImportData => 'Importuj dane';

  @override
  String get settingsImportDataDesc => 'Wczytaj dane z pliku JSON';

  @override
  String get settingsExportSuccess => 'Dane zostały wyeksportowane';

  @override
  String get settingsImportSuccess => 'Dane zostały zaimportowane';

  @override
  String get settingsImportConfirm =>
      'Czy na pewno chcesz zaimportować dane? Obecne dane zostaną zastąpione.';

  @override
  String get buttonImport => 'Importuj';

  @override
  String get calcModeEval => 'Oblicz';

  @override
  String get calcModeDerive => 'Pochodna';

  @override
  String get calcModeIntegrate => 'Całka';

  @override
  String get calcModeSolve => 'Równanie';

  @override
  String get calcModeLimit => 'Granica';

  @override
  String get calcModeSimplify => 'Uprość';

  @override
  String get calcModeInequality => 'Nierówność';

  @override
  String get calcModeInterval => 'Przedział';

  @override
  String get navigationIssues => 'Issues';

  @override
  String get navigationPullRequests => 'Pull Requests';

  @override
  String get labelIssues => 'Issues';

  @override
  String get labelComments => 'Komentarze';

  @override
  String get labelLabels => 'Etykiety';

  @override
  String get labelAssignees => 'Przypisani';

  @override
  String get labelMilestone => 'Kamień milowy';

  @override
  String get labelReactions => 'Reakcje';

  @override
  String get labelBody => 'Treść';

  @override
  String get labelAuthor => 'Autor';

  @override
  String get emptyStateNoIssues => 'Brak issues';

  @override
  String get dialogNewIssue => 'Nowy issue';

  @override
  String get dialogEditIssue => 'Edytuj issue';

  @override
  String get placeholderIssueTitle => 'Tytuł issue...';

  @override
  String get placeholderIssueBody => 'Opisz issue...';

  @override
  String get placeholderEnterComment => 'Napisz komentarz...';

  @override
  String get placeholderLabels => 'Etykiety (oddzielone przecinkiem)...';

  @override
  String get buttonReopen => 'Otwórz ponownie';

  @override
  String get buttonCloseIssue => 'Zamknij issue';

  @override
  String get buttonComment => 'Skomentuj';

  @override
  String get buttonOpenOnGitHub => 'Otwórz na GitHub';

  @override
  String get tooltipNewIssue => 'Nowy issue';

  @override
  String get statusOpen => 'Otwarty';

  @override
  String get statusClosed => 'Zamknięty';
}
