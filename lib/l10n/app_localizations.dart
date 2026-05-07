import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pl, this message translates to:
  /// **'OpenDevNote'**
  String get appTitle;

  /// No description provided for @navigationToday.
  ///
  /// In pl, this message translates to:
  /// **'Dzisiaj'**
  String get navigationToday;

  /// No description provided for @navigationInbox.
  ///
  /// In pl, this message translates to:
  /// **'Niezaplanowane'**
  String get navigationInbox;

  /// No description provided for @navigationCalendar.
  ///
  /// In pl, this message translates to:
  /// **'Kalendarz'**
  String get navigationCalendar;

  /// No description provided for @navigationCalculator.
  ///
  /// In pl, this message translates to:
  /// **'Kalkulator'**
  String get navigationCalculator;

  /// No description provided for @navigationWorkTime.
  ///
  /// In pl, this message translates to:
  /// **'Czas pracy'**
  String get navigationWorkTime;

  /// No description provided for @navigationNews.
  ///
  /// In pl, this message translates to:
  /// **'Wiadomości'**
  String get navigationNews;

  /// No description provided for @navigationRepos.
  ///
  /// In pl, this message translates to:
  /// **'Repozytoria'**
  String get navigationRepos;

  /// No description provided for @navigationProjects.
  ///
  /// In pl, this message translates to:
  /// **'Projekty'**
  String get navigationProjects;

  /// No description provided for @navigationDeployments.
  ///
  /// In pl, this message translates to:
  /// **'Wdrożenia'**
  String get navigationDeployments;

  /// No description provided for @buttonAdd.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj'**
  String get buttonAdd;

  /// No description provided for @buttonCancel.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get buttonCancel;

  /// No description provided for @buttonSave.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz'**
  String get buttonSave;

  /// No description provided for @buttonCreate.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz'**
  String get buttonCreate;

  /// No description provided for @buttonClose.
  ///
  /// In pl, this message translates to:
  /// **'Zamknij'**
  String get buttonClose;

  /// No description provided for @buttonEdit.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj'**
  String get buttonEdit;

  /// No description provided for @buttonDelete.
  ///
  /// In pl, this message translates to:
  /// **'Usuń'**
  String get buttonDelete;

  /// No description provided for @buttonRefresh.
  ///
  /// In pl, this message translates to:
  /// **'Odśwież'**
  String get buttonRefresh;

  /// No description provided for @buttonChange.
  ///
  /// In pl, this message translates to:
  /// **'Zmień'**
  String get buttonChange;

  /// No description provided for @buttonBack.
  ///
  /// In pl, this message translates to:
  /// **'Wróć'**
  String get buttonBack;

  /// No description provided for @buttonClear.
  ///
  /// In pl, this message translates to:
  /// **'Wyczyść'**
  String get buttonClear;

  /// No description provided for @buttonHideFunctions.
  ///
  /// In pl, this message translates to:
  /// **'Ukryj funkcje'**
  String get buttonHideFunctions;

  /// No description provided for @buttonShowFunctions.
  ///
  /// In pl, this message translates to:
  /// **'Funkcje zaawansowane'**
  String get buttonShowFunctions;

  /// No description provided for @buttonSetDeadline.
  ///
  /// In pl, this message translates to:
  /// **'Ustaw termin'**
  String get buttonSetDeadline;

  /// No description provided for @buttonClearHistory.
  ///
  /// In pl, this message translates to:
  /// **'Wyczyść historię'**
  String get buttonClearHistory;

  /// No description provided for @labelTitle.
  ///
  /// In pl, this message translates to:
  /// **'Tytuł'**
  String get labelTitle;

  /// No description provided for @labelDescription.
  ///
  /// In pl, this message translates to:
  /// **'Opis'**
  String get labelDescription;

  /// No description provided for @labelDescriptionOptional.
  ///
  /// In pl, this message translates to:
  /// **'Opis (opcjonalnie)'**
  String get labelDescriptionOptional;

  /// No description provided for @labelCategory.
  ///
  /// In pl, this message translates to:
  /// **'Kategoria'**
  String get labelCategory;

  /// No description provided for @labelCategoryOptional.
  ///
  /// In pl, this message translates to:
  /// **'Kategoria (opcjonalnie)'**
  String get labelCategoryOptional;

  /// No description provided for @labelProjectName.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa projektu'**
  String get labelProjectName;

  /// No description provided for @labelDeadline.
  ///
  /// In pl, this message translates to:
  /// **'Termin'**
  String get labelDeadline;

  /// No description provided for @labelLanguage.
  ///
  /// In pl, this message translates to:
  /// **'Język'**
  String get labelLanguage;

  /// No description provided for @labelColor.
  ///
  /// In pl, this message translates to:
  /// **'Kolor'**
  String get labelColor;

  /// No description provided for @labelIcon.
  ///
  /// In pl, this message translates to:
  /// **'Ikona'**
  String get labelIcon;

  /// No description provided for @labelTags.
  ///
  /// In pl, this message translates to:
  /// **'Tagi'**
  String get labelTags;

  /// No description provided for @labelAccountName.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa konta'**
  String get labelAccountName;

  /// No description provided for @labelFrom.
  ///
  /// In pl, this message translates to:
  /// **'Z'**
  String get labelFrom;

  /// No description provided for @labelTo.
  ///
  /// In pl, this message translates to:
  /// **'Do'**
  String get labelTo;

  /// No description provided for @labelTask.
  ///
  /// In pl, this message translates to:
  /// **'Zadanie'**
  String get labelTask;

  /// No description provided for @labelCreated.
  ///
  /// In pl, this message translates to:
  /// **'Utworzono'**
  String get labelCreated;

  /// No description provided for @labelJobs.
  ///
  /// In pl, this message translates to:
  /// **'Joby'**
  String get labelJobs;

  /// No description provided for @labelCommits.
  ///
  /// In pl, this message translates to:
  /// **'Commity'**
  String get labelCommits;

  /// No description provided for @labelBranches.
  ///
  /// In pl, this message translates to:
  /// **'Gałęzie'**
  String get labelBranches;

  /// No description provided for @labelCharts.
  ///
  /// In pl, this message translates to:
  /// **'Wykresy'**
  String get labelCharts;

  /// No description provided for @labelFilters.
  ///
  /// In pl, this message translates to:
  /// **'Filtry'**
  String get labelFilters;

  /// No description provided for @labelVisibility.
  ///
  /// In pl, this message translates to:
  /// **'Widoczność'**
  String get labelVisibility;

  /// No description provided for @labelStatus.
  ///
  /// In pl, this message translates to:
  /// **'Status'**
  String get labelStatus;

  /// No description provided for @labelHistory.
  ///
  /// In pl, this message translates to:
  /// **'Historia'**
  String get labelHistory;

  /// No description provided for @labelPopular.
  ///
  /// In pl, this message translates to:
  /// **'Popularne'**
  String get labelPopular;

  /// No description provided for @labelNumeric.
  ///
  /// In pl, this message translates to:
  /// **'Liczbowe'**
  String get labelNumeric;

  /// No description provided for @labelTaskName.
  ///
  /// In pl, this message translates to:
  /// **'Zadanie'**
  String get labelTaskName;

  /// No description provided for @labelActiveTimer.
  ///
  /// In pl, this message translates to:
  /// **'Aktywny timer'**
  String get labelActiveTimer;

  /// No description provided for @labelLastWeek.
  ///
  /// In pl, this message translates to:
  /// **'Ostatni tydzień'**
  String get labelLastWeek;

  /// No description provided for @labelTodaySessions.
  ///
  /// In pl, this message translates to:
  /// **'Dzisiejsze sesje'**
  String get labelTodaySessions;

  /// No description provided for @labelTasks.
  ///
  /// In pl, this message translates to:
  /// **'Zadania'**
  String get labelTasks;

  /// No description provided for @labelNotes.
  ///
  /// In pl, this message translates to:
  /// **'Notatki'**
  String get labelNotes;

  /// No description provided for @labelCodeSnippets.
  ///
  /// In pl, this message translates to:
  /// **'Fragmenty kodu'**
  String get labelCodeSnippets;

  /// No description provided for @labelCompleted.
  ///
  /// In pl, this message translates to:
  /// **'Ukończone ({count})'**
  String labelCompleted(Object count);

  /// No description provided for @labelYourAccounts.
  ///
  /// In pl, this message translates to:
  /// **'Twoje konta'**
  String get labelYourAccounts;

  /// No description provided for @labelAddAccount.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj konto'**
  String get labelAddAccount;

  /// No description provided for @labelEditor.
  ///
  /// In pl, this message translates to:
  /// **'Edytor'**
  String get labelEditor;

  /// No description provided for @labelPreview.
  ///
  /// In pl, this message translates to:
  /// **'Podgląd'**
  String get labelPreview;

  /// No description provided for @placeholderSearch.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj...'**
  String get placeholderSearch;

  /// No description provided for @placeholderSearchProjects.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj projektów...'**
  String get placeholderSearchProjects;

  /// No description provided for @placeholderSearchNotesTasks.
  ///
  /// In pl, this message translates to:
  /// **'Wyszukaj notatki i zadania...'**
  String get placeholderSearchNotesTasks;

  /// No description provided for @placeholderEnterTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wprowadź tytuł...'**
  String get placeholderEnterTitle;

  /// No description provided for @placeholderEnterTaskTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wprowadź tytuł zadania...'**
  String get placeholderEnterTaskTitle;

  /// No description provided for @placeholderEnterNoteTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wprowadź tytuł notatki...'**
  String get placeholderEnterNoteTitle;

  /// No description provided for @placeholderEnterEventTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wprowadź tytuł wydarzenia...'**
  String get placeholderEnterEventTitle;

  /// No description provided for @placeholderEnterDescription.
  ///
  /// In pl, this message translates to:
  /// **'Wprowadź opis...'**
  String get placeholderEnterDescription;

  /// No description provided for @placeholderEnterNoteContent.
  ///
  /// In pl, this message translates to:
  /// **'Wprowadź treść notatki...'**
  String get placeholderEnterNoteContent;

  /// No description provided for @placeholderEnterContent.
  ///
  /// In pl, this message translates to:
  /// **'Wprowadź treść w formacie Markdown...'**
  String get placeholderEnterContent;

  /// No description provided for @placeholderAdditionalDescription.
  ///
  /// In pl, this message translates to:
  /// **'Dodatkowy opis...'**
  String get placeholderAdditionalDescription;

  /// No description provided for @placeholderEnterProjectName.
  ///
  /// In pl, this message translates to:
  /// **'Wprowadź nazwę...'**
  String get placeholderEnterProjectName;

  /// No description provided for @placeholderNewTag.
  ///
  /// In pl, this message translates to:
  /// **'Nowy tag...'**
  String get placeholderNewTag;

  /// No description provided for @placeholderFeedUrl.
  ///
  /// In pl, this message translates to:
  /// **'URL feedu'**
  String get placeholderFeedUrl;

  /// No description provided for @placeholderCategoryExample.
  ///
  /// In pl, this message translates to:
  /// **'Tech, Sport, Nauka...'**
  String get placeholderCategoryExample;

  /// No description provided for @placeholderCategoryTech.
  ///
  /// In pl, this message translates to:
  /// **'Tech, Sport...'**
  String get placeholderCategoryTech;

  /// No description provided for @placeholderAccountExample.
  ///
  /// In pl, this message translates to:
  /// **'np. Praca, Osobiste'**
  String get placeholderAccountExample;

  /// No description provided for @placeholderExampleMode.
  ///
  /// In pl, this message translates to:
  /// **'np. {example}'**
  String placeholderExampleMode(Object example);

  /// No description provided for @dialogNewProject.
  ///
  /// In pl, this message translates to:
  /// **'Nowy projekt'**
  String get dialogNewProject;

  /// No description provided for @dialogEditProject.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj projekt'**
  String get dialogEditProject;

  /// No description provided for @dialogProjectTags.
  ///
  /// In pl, this message translates to:
  /// **'Tagi projektu'**
  String get dialogProjectTags;

  /// No description provided for @dialogNewTask.
  ///
  /// In pl, this message translates to:
  /// **'Nowe zadanie'**
  String get dialogNewTask;

  /// No description provided for @dialogEditTask.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj zadanie'**
  String get dialogEditTask;

  /// No description provided for @dialogNewNote.
  ///
  /// In pl, this message translates to:
  /// **'Nowa notatka'**
  String get dialogNewNote;

  /// No description provided for @dialogEditNote.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj notatkę'**
  String get dialogEditNote;

  /// No description provided for @dialogDeleteNote.
  ///
  /// In pl, this message translates to:
  /// **'Usuń notatkę'**
  String get dialogDeleteNote;

  /// No description provided for @dialogDeleteNoteConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć \"{title}\"?'**
  String dialogDeleteNoteConfirm(Object title);

  /// No description provided for @dialogNewEvent.
  ///
  /// In pl, this message translates to:
  /// **'Nowe wydarzenie'**
  String get dialogNewEvent;

  /// No description provided for @dialogNewCodeSnippet.
  ///
  /// In pl, this message translates to:
  /// **'Nowy fragment kodu'**
  String get dialogNewCodeSnippet;

  /// No description provided for @dialogEditSnippet.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj snippet'**
  String get dialogEditSnippet;

  /// No description provided for @dialogAddRssFeed.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj feed RSS'**
  String get dialogAddRssFeed;

  /// No description provided for @dialogRssSettings.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia RSS'**
  String get dialogRssSettings;

  /// No description provided for @dialogCommitDetails.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły commita'**
  String get dialogCommitDetails;

  /// No description provided for @dialogWorkflowDetails.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły workflow'**
  String get dialogWorkflowDetails;

  /// No description provided for @dialogGitHubAccounts.
  ///
  /// In pl, this message translates to:
  /// **'Konta GitHub'**
  String get dialogGitHubAccounts;

  /// No description provided for @dialogKeyboardShortcuts.
  ///
  /// In pl, this message translates to:
  /// **'Skróty klawiszowe'**
  String get dialogKeyboardShortcuts;

  /// No description provided for @dialogCategory.
  ///
  /// In pl, this message translates to:
  /// **'Kategoria'**
  String get dialogCategory;

  /// No description provided for @dialogCategoryName.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa kategorii'**
  String get dialogCategoryName;

  /// No description provided for @emptyStateNoProjects.
  ///
  /// In pl, this message translates to:
  /// **'Brak projektów'**
  String get emptyStateNoProjects;

  /// No description provided for @emptyStateCreateFirstProject.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz swój pierwszy projekt'**
  String get emptyStateCreateFirstProject;

  /// No description provided for @emptyStateNoTasksToday.
  ///
  /// In pl, this message translates to:
  /// **'Brak zadań na dziś'**
  String get emptyStateNoTasksToday;

  /// No description provided for @emptyStatePlanYourDay.
  ///
  /// In pl, this message translates to:
  /// **'Zaplanuj swój dzień'**
  String get emptyStatePlanYourDay;

  /// No description provided for @emptyStateUnplannedEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Katalog niezaplanowane jest pusty'**
  String get emptyStateUnplannedEmpty;

  /// No description provided for @emptyStateUnplannedHint.
  ///
  /// In pl, this message translates to:
  /// **'Zadania bez terminu pojawią się tutaj'**
  String get emptyStateUnplannedHint;

  /// No description provided for @emptyStateNoTasks.
  ///
  /// In pl, this message translates to:
  /// **'Brak zadań'**
  String get emptyStateNoTasks;

  /// No description provided for @emptyStateNoNotes.
  ///
  /// In pl, this message translates to:
  /// **'Brak notatek'**
  String get emptyStateNoNotes;

  /// No description provided for @emptyStateNoCodeSnippets.
  ///
  /// In pl, this message translates to:
  /// **'Brak fragmentów kodu'**
  String get emptyStateNoCodeSnippets;

  /// No description provided for @emptyStateNoHistory.
  ///
  /// In pl, this message translates to:
  /// **'Brak historii'**
  String get emptyStateNoHistory;

  /// No description provided for @emptyStateNoBranches.
  ///
  /// In pl, this message translates to:
  /// **'Brak gałęzi'**
  String get emptyStateNoBranches;

  /// No description provided for @emptyStateNoFeeds.
  ///
  /// In pl, this message translates to:
  /// **'Brak feedów'**
  String get emptyStateNoFeeds;

  /// No description provided for @emptyStateNoArticles.
  ///
  /// In pl, this message translates to:
  /// **'Brak artykułów'**
  String get emptyStateNoArticles;

  /// No description provided for @emptyStateNoArticlesInFeed.
  ///
  /// In pl, this message translates to:
  /// **'Brak artykułów w tym feedzie'**
  String get emptyStateNoArticlesInFeed;

  /// No description provided for @emptyStateNoWorkflowRuns.
  ///
  /// In pl, this message translates to:
  /// **'Brak workflow runs'**
  String get emptyStateNoWorkflowRuns;

  /// No description provided for @emptyStateNoDeployments.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono żadnych wdrożeń'**
  String get emptyStateNoDeployments;

  /// No description provided for @emptyStateNoGitHubAccounts.
  ///
  /// In pl, this message translates to:
  /// **'Brak kont GitHub'**
  String get emptyStateNoGitHubAccounts;

  /// No description provided for @emptyStateAddGitHubAccount.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj konto GitHub w ustawieniach'**
  String get emptyStateAddGitHubAccount;

  /// No description provided for @emptyStateNoResults.
  ///
  /// In pl, this message translates to:
  /// **'Brak wyników'**
  String get emptyStateNoResults;

  /// No description provided for @emptyStateNoResultsForFilters.
  ///
  /// In pl, this message translates to:
  /// **'Brak wyników dla filtrów'**
  String get emptyStateNoResultsForFilters;

  /// No description provided for @emptyStateNoReposWithWorkflows.
  ///
  /// In pl, this message translates to:
  /// **'Brak repozytoriów z workflows'**
  String get emptyStateNoReposWithWorkflows;

  /// No description provided for @emptyStateChangeFilters.
  ///
  /// In pl, this message translates to:
  /// **'Zmień filtry, aby zobaczyć repozytoria'**
  String get emptyStateChangeFilters;

  /// No description provided for @emptyStateNoReposFound.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono żadnych repozytoriów z GitHub Actions'**
  String get emptyStateNoReposFound;

  /// No description provided for @emptyStateNoJobs.
  ///
  /// In pl, this message translates to:
  /// **'Brak jobów'**
  String get emptyStateNoJobs;

  /// No description provided for @emptyStateNoTags.
  ///
  /// In pl, this message translates to:
  /// **'Brak tagów'**
  String get emptyStateNoTags;

  /// No description provided for @emptyStateGitHubDeletesJobs.
  ///
  /// In pl, this message translates to:
  /// **'GitHub usunął dane jobów po 90 dniach przechowywania.'**
  String get emptyStateGitHubDeletesJobs;

  /// No description provided for @emptyStateNoStepData.
  ///
  /// In pl, this message translates to:
  /// **'Brak danych o etapach (GitHub usuwa je po 90 dniach)'**
  String get emptyStateNoStepData;

  /// No description provided for @errorSyntaxError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd składni'**
  String get errorSyntaxError;

  /// No description provided for @errorSyntaxErrorLeft.
  ///
  /// In pl, this message translates to:
  /// **'Błąd składni (lewa strona):'**
  String get errorSyntaxErrorLeft;

  /// No description provided for @errorSyntaxErrorRight.
  ///
  /// In pl, this message translates to:
  /// **'Błąd składni (prawa strona):'**
  String get errorSyntaxErrorRight;

  /// No description provided for @errorPrefix.
  ///
  /// In pl, this message translates to:
  /// **'Błąd:'**
  String get errorPrefix;

  /// No description provided for @errorMathError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd'**
  String get errorMathError;

  /// No description provided for @errorInvalidNumbers.
  ///
  /// In pl, this message translates to:
  /// **'Błąd: nieprawidłowe liczby'**
  String get errorInvalidNumbers;

  /// No description provided for @errorIntervalBounds.
  ///
  /// In pl, this message translates to:
  /// **'Błąd: a > b'**
  String get errorIntervalBounds;

  /// No description provided for @errorNoInequalityOperator.
  ///
  /// In pl, this message translates to:
  /// **'Błąd: brak operatora nierówności (>, <, >=, <=)'**
  String get errorNoInequalityOperator;

  /// No description provided for @errorNoSolutions.
  ///
  /// In pl, this message translates to:
  /// **'Brak rozwiązań'**
  String get errorNoSolutions;

  /// No description provided for @errorUndefined.
  ///
  /// In pl, this message translates to:
  /// **'Nieokreślone'**
  String get errorUndefined;

  /// No description provided for @errorDoesNotExist.
  ///
  /// In pl, this message translates to:
  /// **'Nie istnieje'**
  String get errorDoesNotExist;

  /// No description provided for @errorFeedFetchFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się pobrać feedu: {error}'**
  String errorFeedFetchFailed(Object error);

  /// No description provided for @errorNoGitHubAccount.
  ///
  /// In pl, this message translates to:
  /// **'Brak konta GitHub'**
  String get errorNoGitHubAccount;

  /// No description provided for @errorInvalidGitHubToken.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowy token GitHub'**
  String get errorInvalidGitHubToken;

  /// No description provided for @errorNoRepoPermissions.
  ///
  /// In pl, this message translates to:
  /// **'Brak uprawnień do repozytorium'**
  String get errorNoRepoPermissions;

  /// No description provided for @errorRepoNotFound.
  ///
  /// In pl, this message translates to:
  /// **'Repozytorium nie znalezione'**
  String get errorRepoNotFound;

  /// No description provided for @errorGitHubApi.
  ///
  /// In pl, this message translates to:
  /// **'Błąd API GitHub:'**
  String get errorGitHubApi;

  /// No description provided for @errorLoadingJobs.
  ///
  /// In pl, this message translates to:
  /// **'Błąd ładowania jobów:'**
  String get errorLoadingJobs;

  /// No description provided for @errorLoadingRepos.
  ///
  /// In pl, this message translates to:
  /// **'Błąd ładowania repo:'**
  String get errorLoadingRepos;

  /// No description provided for @errorLoadingCommits.
  ///
  /// In pl, this message translates to:
  /// **'Błąd ładowania commitów:'**
  String get errorLoadingCommits;

  /// No description provided for @errorLoadingCommit.
  ///
  /// In pl, this message translates to:
  /// **'Błąd ładowania commita:'**
  String get errorLoadingCommit;

  /// No description provided for @errorLoadingBranches.
  ///
  /// In pl, this message translates to:
  /// **'Błąd ładowania gałęzi:'**
  String get errorLoadingBranches;

  /// No description provided for @errorLoadingStats.
  ///
  /// In pl, this message translates to:
  /// **'Błąd ładowania statystyk:'**
  String get errorLoadingStats;

  /// No description provided for @errorInvalidRepoName.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowa nazwa repo'**
  String get errorInvalidRepoName;

  /// No description provided for @errorUnknownTask.
  ///
  /// In pl, this message translates to:
  /// **'Nieznane zadanie'**
  String get errorUnknownTask;

  /// No description provided for @errorFormatExpr.
  ///
  /// In pl, this message translates to:
  /// **'Format: expr | x→wartość'**
  String get errorFormatExpr;

  /// No description provided for @errorFormatInterval.
  ///
  /// In pl, this message translates to:
  /// **'Format: [a, b] lub (a, b)'**
  String get errorFormatInterval;

  /// No description provided for @statusLoading.
  ///
  /// In pl, this message translates to:
  /// **'Ładowanie...'**
  String get statusLoading;

  /// No description provided for @statusSaving.
  ///
  /// In pl, this message translates to:
  /// **'Zapisywanie...'**
  String get statusSaving;

  /// No description provided for @statusAllCommitsLoaded.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie commity załadowane'**
  String get statusAllCommitsLoaded;

  /// No description provided for @statusNoDeployments.
  ///
  /// In pl, this message translates to:
  /// **'Brak wdrożeń'**
  String get statusNoDeployments;

  /// No description provided for @statusClickToLoad.
  ///
  /// In pl, this message translates to:
  /// **'Kliknij aby załadować'**
  String get statusClickToLoad;

  /// No description provided for @statusInProgress.
  ///
  /// In pl, this message translates to:
  /// **'W trakcie'**
  String get statusInProgress;

  /// No description provided for @statusSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Sukces'**
  String get statusSuccess;

  /// No description provided for @statusFailure.
  ///
  /// In pl, this message translates to:
  /// **'Niepowodzenie'**
  String get statusFailure;

  /// No description provided for @statusCancelled.
  ///
  /// In pl, this message translates to:
  /// **'Anulowany'**
  String get statusCancelled;

  /// No description provided for @statusTimeout.
  ///
  /// In pl, this message translates to:
  /// **'Timeout'**
  String get statusTimeout;

  /// No description provided for @statusPublic.
  ///
  /// In pl, this message translates to:
  /// **'Publiczne'**
  String get statusPublic;

  /// No description provided for @statusPrivate.
  ///
  /// In pl, this message translates to:
  /// **'Prywatne'**
  String get statusPrivate;

  /// No description provided for @statusAll.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie'**
  String get statusAll;

  /// No description provided for @statusNone.
  ///
  /// In pl, this message translates to:
  /// **'Brak'**
  String get statusNone;

  /// No description provided for @fileStatusAdded.
  ///
  /// In pl, this message translates to:
  /// **'Dodany'**
  String get fileStatusAdded;

  /// No description provided for @fileStatusDeleted.
  ///
  /// In pl, this message translates to:
  /// **'Usunięty'**
  String get fileStatusDeleted;

  /// No description provided for @fileStatusModified.
  ///
  /// In pl, this message translates to:
  /// **'Zmodyfikowany'**
  String get fileStatusModified;

  /// No description provided for @fileStatusRenamed.
  ///
  /// In pl, this message translates to:
  /// **'Zmieniona nazwa'**
  String get fileStatusRenamed;

  /// No description provided for @fileModifiedFiles.
  ///
  /// In pl, this message translates to:
  /// **'Zmodyfikowane pliki'**
  String get fileModifiedFiles;

  /// No description provided for @fileCount.
  ///
  /// In pl, this message translates to:
  /// **'{count} plik(ów)'**
  String fileCount(Object count);

  /// No description provided for @timeYesterday.
  ///
  /// In pl, this message translates to:
  /// **'wczoraj'**
  String get timeYesterday;

  /// No description provided for @timeYesterdayCapitalized.
  ///
  /// In pl, this message translates to:
  /// **'Wczoraj'**
  String get timeYesterdayCapitalized;

  /// No description provided for @timeDayBeforeYesterday.
  ///
  /// In pl, this message translates to:
  /// **'Przedwczoraj'**
  String get timeDayBeforeYesterday;

  /// No description provided for @timeToday.
  ///
  /// In pl, this message translates to:
  /// **'Dzisiaj'**
  String get timeToday;

  /// No description provided for @timeTomorrow.
  ///
  /// In pl, this message translates to:
  /// **'Jutro'**
  String get timeTomorrow;

  /// No description provided for @timeDays.
  ///
  /// In pl, this message translates to:
  /// **'{count} dni'**
  String timeDays(Object count);

  /// No description provided for @timeSecondsAgo.
  ///
  /// In pl, this message translates to:
  /// **'{count}s temu'**
  String timeSecondsAgo(Object count);

  /// No description provided for @timeMinutesAgo.
  ///
  /// In pl, this message translates to:
  /// **'{count}m temu'**
  String timeMinutesAgo(Object count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In pl, this message translates to:
  /// **'{count}h temu'**
  String timeHoursAgo(Object count);

  /// No description provided for @timeDaysAgo.
  ///
  /// In pl, this message translates to:
  /// **'{count}d temu'**
  String timeDaysAgo(Object count);

  /// No description provided for @timeVsYesterday.
  ///
  /// In pl, this message translates to:
  /// **'{diff}min vs wczoraj'**
  String timeVsYesterday(Object diff);

  /// No description provided for @timeYesterdayTotal.
  ///
  /// In pl, this message translates to:
  /// **'Wczoraj: {duration}'**
  String timeYesterdayTotal(Object duration);

  /// No description provided for @timeFrom.
  ///
  /// In pl, this message translates to:
  /// **'od {time}'**
  String timeFrom(Object time);

  /// No description provided for @timeTodayTime.
  ///
  /// In pl, this message translates to:
  /// **'Dzisiaj {time}'**
  String timeTodayTime(Object time);

  /// No description provided for @timeTomorrowTime.
  ///
  /// In pl, this message translates to:
  /// **'Jutro {time}'**
  String timeTomorrowTime(Object time);

  /// No description provided for @weekdayMonday.
  ///
  /// In pl, this message translates to:
  /// **'Poniedziałek'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In pl, this message translates to:
  /// **'Wtorek'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In pl, this message translates to:
  /// **'Środa'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In pl, this message translates to:
  /// **'Czwartek'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In pl, this message translates to:
  /// **'Piątek'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In pl, this message translates to:
  /// **'Sobota'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In pl, this message translates to:
  /// **'Niedziela'**
  String get weekdaySunday;

  /// No description provided for @weekdayShortMon.
  ///
  /// In pl, this message translates to:
  /// **'Pn'**
  String get weekdayShortMon;

  /// No description provided for @weekdayShortTue.
  ///
  /// In pl, this message translates to:
  /// **'Wt'**
  String get weekdayShortTue;

  /// No description provided for @weekdayShortWed.
  ///
  /// In pl, this message translates to:
  /// **'Śr'**
  String get weekdayShortWed;

  /// No description provided for @weekdayShortThu.
  ///
  /// In pl, this message translates to:
  /// **'Czw'**
  String get weekdayShortThu;

  /// No description provided for @weekdayShortFri.
  ///
  /// In pl, this message translates to:
  /// **'Pt'**
  String get weekdayShortFri;

  /// No description provided for @weekdayShortSat.
  ///
  /// In pl, this message translates to:
  /// **'Sb'**
  String get weekdayShortSat;

  /// No description provided for @weekdayShortSun.
  ///
  /// In pl, this message translates to:
  /// **'Nd'**
  String get weekdayShortSun;

  /// No description provided for @weekdayShortAltMon.
  ///
  /// In pl, this message translates to:
  /// **'Pn'**
  String get weekdayShortAltMon;

  /// No description provided for @weekdayShortAltTue.
  ///
  /// In pl, this message translates to:
  /// **'Wt'**
  String get weekdayShortAltTue;

  /// No description provided for @weekdayShortAltWed.
  ///
  /// In pl, this message translates to:
  /// **'Śr'**
  String get weekdayShortAltWed;

  /// No description provided for @weekdayShortAltThu.
  ///
  /// In pl, this message translates to:
  /// **'Cz'**
  String get weekdayShortAltThu;

  /// No description provided for @weekdayShortAltFri.
  ///
  /// In pl, this message translates to:
  /// **'Pt'**
  String get weekdayShortAltFri;

  /// No description provided for @weekdayShortAltSat.
  ///
  /// In pl, this message translates to:
  /// **'So'**
  String get weekdayShortAltSat;

  /// No description provided for @weekdayShortAltSun.
  ///
  /// In pl, this message translates to:
  /// **'Nd'**
  String get weekdayShortAltSun;

  /// No description provided for @monthJanuary.
  ///
  /// In pl, this message translates to:
  /// **'Styczeń'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In pl, this message translates to:
  /// **'Luty'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In pl, this message translates to:
  /// **'Marzec'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In pl, this message translates to:
  /// **'Kwiecień'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In pl, this message translates to:
  /// **'Maj'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In pl, this message translates to:
  /// **'Czerwiec'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In pl, this message translates to:
  /// **'Lipiec'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In pl, this message translates to:
  /// **'Sierpień'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In pl, this message translates to:
  /// **'Wrzesień'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In pl, this message translates to:
  /// **'Październik'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In pl, this message translates to:
  /// **'Listopad'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In pl, this message translates to:
  /// **'Grudzień'**
  String get monthDecember;

  /// No description provided for @monthGenJanuary.
  ///
  /// In pl, this message translates to:
  /// **'stycznia'**
  String get monthGenJanuary;

  /// No description provided for @monthGenFebruary.
  ///
  /// In pl, this message translates to:
  /// **'lutego'**
  String get monthGenFebruary;

  /// No description provided for @monthGenMarch.
  ///
  /// In pl, this message translates to:
  /// **'marca'**
  String get monthGenMarch;

  /// No description provided for @monthGenApril.
  ///
  /// In pl, this message translates to:
  /// **'kwietnia'**
  String get monthGenApril;

  /// No description provided for @monthGenMay.
  ///
  /// In pl, this message translates to:
  /// **'maja'**
  String get monthGenMay;

  /// No description provided for @monthGenJune.
  ///
  /// In pl, this message translates to:
  /// **'czerwca'**
  String get monthGenJune;

  /// No description provided for @monthGenJuly.
  ///
  /// In pl, this message translates to:
  /// **'lipca'**
  String get monthGenJuly;

  /// No description provided for @monthGenAugust.
  ///
  /// In pl, this message translates to:
  /// **'sierpnia'**
  String get monthGenAugust;

  /// No description provided for @monthGenSeptember.
  ///
  /// In pl, this message translates to:
  /// **'września'**
  String get monthGenSeptember;

  /// No description provided for @monthGenOctober.
  ///
  /// In pl, this message translates to:
  /// **'października'**
  String get monthGenOctober;

  /// No description provided for @monthGenNovember.
  ///
  /// In pl, this message translates to:
  /// **'listopada'**
  String get monthGenNovember;

  /// No description provided for @monthGenDecember.
  ///
  /// In pl, this message translates to:
  /// **'grudnia'**
  String get monthGenDecember;

  /// No description provided for @converterLength.
  ///
  /// In pl, this message translates to:
  /// **'Długość'**
  String get converterLength;

  /// No description provided for @converterMass.
  ///
  /// In pl, this message translates to:
  /// **'Masa'**
  String get converterMass;

  /// No description provided for @converterTemperature.
  ///
  /// In pl, this message translates to:
  /// **'Temperatura'**
  String get converterTemperature;

  /// No description provided for @converterTime.
  ///
  /// In pl, this message translates to:
  /// **'Czas'**
  String get converterTime;

  /// No description provided for @converterSpeed.
  ///
  /// In pl, this message translates to:
  /// **'Prędkość'**
  String get converterSpeed;

  /// No description provided for @converterVolume.
  ///
  /// In pl, this message translates to:
  /// **'Objętość'**
  String get converterVolume;

  /// No description provided for @converterData.
  ///
  /// In pl, this message translates to:
  /// **'Dane'**
  String get converterData;

  /// No description provided for @converterAngle.
  ///
  /// In pl, this message translates to:
  /// **'Kąt'**
  String get converterAngle;

  /// No description provided for @converterTabLabel.
  ///
  /// In pl, this message translates to:
  /// **'Konwerter'**
  String get converterTabLabel;

  /// No description provided for @converterAddFunction.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj funkcję'**
  String get converterAddFunction;

  /// No description provided for @tabCalculator.
  ///
  /// In pl, this message translates to:
  /// **'Kalkulator'**
  String get tabCalculator;

  /// No description provided for @tabConverter.
  ///
  /// In pl, this message translates to:
  /// **'Konwerter'**
  String get tabConverter;

  /// No description provided for @tabGraph.
  ///
  /// In pl, this message translates to:
  /// **'Wykres'**
  String get tabGraph;

  /// No description provided for @tooltipRefresh.
  ///
  /// In pl, this message translates to:
  /// **'Odśwież'**
  String get tooltipRefresh;

  /// No description provided for @tooltipSettings.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia'**
  String get tooltipSettings;

  /// No description provided for @tooltipSave.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz'**
  String get tooltipSave;

  /// No description provided for @tooltipSaveCtrlS.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz (Ctrl+S)'**
  String get tooltipSaveCtrlS;

  /// No description provided for @tooltipBack.
  ///
  /// In pl, this message translates to:
  /// **'Wróć'**
  String get tooltipBack;

  /// No description provided for @tooltipAddFeed.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj feed'**
  String get tooltipAddFeed;

  /// No description provided for @tooltipRefreshAll.
  ///
  /// In pl, this message translates to:
  /// **'Odśwież wszystko'**
  String get tooltipRefreshAll;

  /// No description provided for @tooltipNewNote.
  ///
  /// In pl, this message translates to:
  /// **'Nowa notatka'**
  String get tooltipNewNote;

  /// No description provided for @tooltipNewTask.
  ///
  /// In pl, this message translates to:
  /// **'Nowe zadanie'**
  String get tooltipNewTask;

  /// No description provided for @tooltipNewCodeSnippet.
  ///
  /// In pl, this message translates to:
  /// **'Nowy fragment kodu'**
  String get tooltipNewCodeSnippet;

  /// No description provided for @tooltipNewProject.
  ///
  /// In pl, this message translates to:
  /// **'Nowy projekt'**
  String get tooltipNewProject;

  /// No description provided for @tooltipNewEvent.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj wydarzenie (Ctrl+E)'**
  String get tooltipNewEvent;

  /// No description provided for @tooltipRemoveFromFavorites.
  ///
  /// In pl, this message translates to:
  /// **'Usuń z ulubionych'**
  String get tooltipRemoveFromFavorites;

  /// No description provided for @tooltipAddToFavorites.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj do ulubionych'**
  String get tooltipAddToFavorites;

  /// No description provided for @tooltipDeleteAccount.
  ///
  /// In pl, this message translates to:
  /// **'Usuń'**
  String get tooltipDeleteAccount;

  /// No description provided for @tooltipDeleteNote.
  ///
  /// In pl, this message translates to:
  /// **'Usuń notatkę'**
  String get tooltipDeleteNote;

  /// No description provided for @tooltipHidePreview.
  ///
  /// In pl, this message translates to:
  /// **'Ukryj podgląd'**
  String get tooltipHidePreview;

  /// No description provided for @tooltipShowPreview.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż podgląd'**
  String get tooltipShowPreview;

  /// No description provided for @tooltipDayView.
  ///
  /// In pl, this message translates to:
  /// **'Widok dnia'**
  String get tooltipDayView;

  /// No description provided for @tooltipWeekView.
  ///
  /// In pl, this message translates to:
  /// **'Widok tygodnia'**
  String get tooltipWeekView;

  /// No description provided for @tooltipMonthView.
  ///
  /// In pl, this message translates to:
  /// **'Widok miesiąca'**
  String get tooltipMonthView;

  /// No description provided for @tooltipTags.
  ///
  /// In pl, this message translates to:
  /// **'Tagi'**
  String get tooltipTags;

  /// No description provided for @menuEdit.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj'**
  String get menuEdit;

  /// No description provided for @menuDelete.
  ///
  /// In pl, this message translates to:
  /// **'Usuń'**
  String get menuDelete;

  /// No description provided for @menuRefresh.
  ///
  /// In pl, this message translates to:
  /// **'Odśwież'**
  String get menuRefresh;

  /// No description provided for @menuMarkAllRead.
  ///
  /// In pl, this message translates to:
  /// **'Oznacz wszystkie jako przeczytane'**
  String get menuMarkAllRead;

  /// No description provided for @menuChangeCategory.
  ///
  /// In pl, this message translates to:
  /// **'Zmień kategorię'**
  String get menuChangeCategory;

  /// No description provided for @menuDeleteFeed.
  ///
  /// In pl, this message translates to:
  /// **'Usuń feed'**
  String get menuDeleteFeed;

  /// No description provided for @menuMarkAsUnread.
  ///
  /// In pl, this message translates to:
  /// **'Oznacz jako nieprzeczytane'**
  String get menuMarkAsUnread;

  /// No description provided for @menuMarkAsRead.
  ///
  /// In pl, this message translates to:
  /// **'Oznacz jako przeczytane'**
  String get menuMarkAsRead;

  /// No description provided for @settingsAutoRefresh.
  ///
  /// In pl, this message translates to:
  /// **'Automatyczne odświeżanie'**
  String get settingsAutoRefresh;

  /// No description provided for @settingsAutoRefreshDesc.
  ///
  /// In pl, this message translates to:
  /// **'Odświeża feedy co {minutes} min'**
  String settingsAutoRefreshDesc(Object minutes);

  /// No description provided for @settingsInterval.
  ///
  /// In pl, this message translates to:
  /// **'Interwał:'**
  String get settingsInterval;

  /// No description provided for @settingsAutoCleanup.
  ///
  /// In pl, this message translates to:
  /// **'Automatyczne czyszczenie'**
  String get settingsAutoCleanup;

  /// No description provided for @settingsAutoCleanupDesc.
  ///
  /// In pl, this message translates to:
  /// **'Usuwa artykuły starsze niż {days} dni'**
  String settingsAutoCleanupDesc(Object days);

  /// No description provided for @settingsDaysThreshold.
  ///
  /// In pl, this message translates to:
  /// **'Po ilu dniach:'**
  String get settingsDaysThreshold;

  /// No description provided for @settingsSplitView.
  ///
  /// In pl, this message translates to:
  /// **'Widok podzielony'**
  String get settingsSplitView;

  /// No description provided for @settingsSplitViewFeedList.
  ///
  /// In pl, this message translates to:
  /// **'Lista feedów + artykuły'**
  String get settingsSplitViewFeedList;

  /// No description provided for @settingsSplitViewArticlesOnly.
  ///
  /// In pl, this message translates to:
  /// **'Tylko lista artykułów'**
  String get settingsSplitViewArticlesOnly;

  /// No description provided for @shortcutNewNoteProject.
  ///
  /// In pl, this message translates to:
  /// **'Nowa notatka w aktualnym projekcie'**
  String get shortcutNewNoteProject;

  /// No description provided for @shortcutNewTaskProject.
  ///
  /// In pl, this message translates to:
  /// **'Nowe zadanie w aktualnym projekcie'**
  String get shortcutNewTaskProject;

  /// No description provided for @shortcutToggleHelp.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż/ukryj pomoc skrótów'**
  String get shortcutToggleHelp;

  /// No description provided for @shortcutSearchNotes.
  ///
  /// In pl, this message translates to:
  /// **'Wyszukaj notatki (command bar)'**
  String get shortcutSearchNotes;

  /// No description provided for @shortcutNewEvent.
  ///
  /// In pl, this message translates to:
  /// **'Nowe wydarzenie w kalendarzu'**
  String get shortcutNewEvent;

  /// No description provided for @shortcutZoomCalendar.
  ///
  /// In pl, this message translates to:
  /// **'Przybliż/oddal widok kalendarza'**
  String get shortcutZoomCalendar;

  /// No description provided for @shortcutNavMonthWeek.
  ///
  /// In pl, this message translates to:
  /// **'Nawigacja miesiąc / tydzień'**
  String get shortcutNavMonthWeek;

  /// No description provided for @shortcutNavDay.
  ///
  /// In pl, this message translates to:
  /// **'Nawigacja dzień'**
  String get shortcutNavDay;

  /// No description provided for @chartCommitActivity.
  ///
  /// In pl, this message translates to:
  /// **'Aktywność commitów (ostatni rok)'**
  String get chartCommitActivity;

  /// No description provided for @chartCodeFrequency.
  ///
  /// In pl, this message translates to:
  /// **'Częstotliwość kodu (ostatnie 6 mies.)'**
  String get chartCodeFrequency;

  /// No description provided for @chartLegendAdditions.
  ///
  /// In pl, this message translates to:
  /// **'Dodania'**
  String get chartLegendAdditions;

  /// No description provided for @chartLegendDeletions.
  ///
  /// In pl, this message translates to:
  /// **'Usunięcia'**
  String get chartLegendDeletions;

  /// No description provided for @chartActivityDayHour.
  ///
  /// In pl, this message translates to:
  /// **'Aktywność (dzień × godzina)'**
  String get chartActivityDayHour;

  /// No description provided for @chartShareLast52.
  ///
  /// In pl, this message translates to:
  /// **'Udział (ostatnie 52 tygodnie)'**
  String get chartShareLast52;

  /// No description provided for @chartLegendAllCommits.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie commity'**
  String get chartLegendAllCommits;

  /// No description provided for @notificationChannelDeadlines.
  ///
  /// In pl, this message translates to:
  /// **'Terminy zadań'**
  String get notificationChannelDeadlines;

  /// No description provided for @notificationChannelDeadlinesDesc.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia o terminach zadań'**
  String get notificationChannelDeadlinesDesc;

  /// No description provided for @notificationTestTitle.
  ///
  /// In pl, this message translates to:
  /// **'Test powiadomienia'**
  String get notificationTestTitle;

  /// No description provided for @notificationTestBody.
  ///
  /// In pl, this message translates to:
  /// **'Jeśli widzisz to, działa!'**
  String get notificationTestBody;

  /// No description provided for @notificationTaskDeadline.
  ///
  /// In pl, this message translates to:
  /// **'Termin zadania'**
  String get notificationTaskDeadline;

  /// No description provided for @badgeNote.
  ///
  /// In pl, this message translates to:
  /// **'Notatka'**
  String get badgeNote;

  /// No description provided for @badgeTask.
  ///
  /// In pl, this message translates to:
  /// **'Zadanie'**
  String get badgeTask;

  /// No description provided for @actionLinkTask.
  ///
  /// In pl, this message translates to:
  /// **'Powiąż z zadaniem'**
  String get actionLinkTask;

  /// No description provided for @actionLinkedTask.
  ///
  /// In pl, this message translates to:
  /// **'Powiązane zadanie'**
  String get actionLinkedTask;

  /// No description provided for @actionOptionalTo.
  ///
  /// In pl, this message translates to:
  /// **'Do (opcjonalnie)'**
  String get actionOptionalTo;

  /// No description provided for @settingsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In pl, this message translates to:
  /// **'Język'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDesc.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz język interfejsu'**
  String get settingsLanguageDesc;

  /// No description provided for @settingsLanguagePolish.
  ///
  /// In pl, this message translates to:
  /// **'Polski'**
  String get settingsLanguagePolish;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In pl, this message translates to:
  /// **'Angielski'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In pl, this message translates to:
  /// **'Systemowy'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsDataManagement.
  ///
  /// In pl, this message translates to:
  /// **'Zarządzanie danymi'**
  String get settingsDataManagement;

  /// No description provided for @settingsExportData.
  ///
  /// In pl, this message translates to:
  /// **'Eksportuj dane'**
  String get settingsExportData;

  /// No description provided for @settingsExportDataDesc.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz wszystkie dane do pliku JSON'**
  String get settingsExportDataDesc;

  /// No description provided for @settingsImportData.
  ///
  /// In pl, this message translates to:
  /// **'Importuj dane'**
  String get settingsImportData;

  /// No description provided for @settingsImportDataDesc.
  ///
  /// In pl, this message translates to:
  /// **'Wczytaj dane z pliku JSON'**
  String get settingsImportDataDesc;

  /// No description provided for @settingsExportSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Dane zostały wyeksportowane'**
  String get settingsExportSuccess;

  /// No description provided for @settingsImportSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Dane zostały zaimportowane'**
  String get settingsImportSuccess;

  /// No description provided for @settingsImportConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz zaimportować dane? Obecne dane zostaną zastąpione.'**
  String get settingsImportConfirm;

  /// No description provided for @buttonImport.
  ///
  /// In pl, this message translates to:
  /// **'Importuj'**
  String get buttonImport;

  /// No description provided for @calcModeEval.
  ///
  /// In pl, this message translates to:
  /// **'Oblicz'**
  String get calcModeEval;

  /// No description provided for @calcModeDerive.
  ///
  /// In pl, this message translates to:
  /// **'Pochodna'**
  String get calcModeDerive;

  /// No description provided for @calcModeIntegrate.
  ///
  /// In pl, this message translates to:
  /// **'Całka'**
  String get calcModeIntegrate;

  /// No description provided for @calcModeSolve.
  ///
  /// In pl, this message translates to:
  /// **'Równanie'**
  String get calcModeSolve;

  /// No description provided for @calcModeLimit.
  ///
  /// In pl, this message translates to:
  /// **'Granica'**
  String get calcModeLimit;

  /// No description provided for @calcModeSimplify.
  ///
  /// In pl, this message translates to:
  /// **'Uprość'**
  String get calcModeSimplify;

  /// No description provided for @calcModeInequality.
  ///
  /// In pl, this message translates to:
  /// **'Nierówność'**
  String get calcModeInequality;

  /// No description provided for @calcModeInterval.
  ///
  /// In pl, this message translates to:
  /// **'Przedział'**
  String get calcModeInterval;

  /// No description provided for @navigationIssues.
  ///
  /// In pl, this message translates to:
  /// **'Issues'**
  String get navigationIssues;

  /// No description provided for @navigationPullRequests.
  ///
  /// In pl, this message translates to:
  /// **'Pull Requests'**
  String get navigationPullRequests;

  /// No description provided for @labelIssues.
  ///
  /// In pl, this message translates to:
  /// **'Issues'**
  String get labelIssues;

  /// No description provided for @labelComments.
  ///
  /// In pl, this message translates to:
  /// **'Komentarze'**
  String get labelComments;

  /// No description provided for @labelLabels.
  ///
  /// In pl, this message translates to:
  /// **'Etykiety'**
  String get labelLabels;

  /// No description provided for @labelAssignees.
  ///
  /// In pl, this message translates to:
  /// **'Przypisani'**
  String get labelAssignees;

  /// No description provided for @labelMilestone.
  ///
  /// In pl, this message translates to:
  /// **'Kamień milowy'**
  String get labelMilestone;

  /// No description provided for @labelReactions.
  ///
  /// In pl, this message translates to:
  /// **'Reakcje'**
  String get labelReactions;

  /// No description provided for @labelBody.
  ///
  /// In pl, this message translates to:
  /// **'Treść'**
  String get labelBody;

  /// No description provided for @labelAuthor.
  ///
  /// In pl, this message translates to:
  /// **'Autor'**
  String get labelAuthor;

  /// No description provided for @emptyStateNoIssues.
  ///
  /// In pl, this message translates to:
  /// **'Brak issues'**
  String get emptyStateNoIssues;

  /// No description provided for @dialogNewIssue.
  ///
  /// In pl, this message translates to:
  /// **'Nowy issue'**
  String get dialogNewIssue;

  /// No description provided for @dialogEditIssue.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj issue'**
  String get dialogEditIssue;

  /// No description provided for @placeholderIssueTitle.
  ///
  /// In pl, this message translates to:
  /// **'Tytuł issue...'**
  String get placeholderIssueTitle;

  /// No description provided for @placeholderIssueBody.
  ///
  /// In pl, this message translates to:
  /// **'Opisz issue...'**
  String get placeholderIssueBody;

  /// No description provided for @placeholderEnterComment.
  ///
  /// In pl, this message translates to:
  /// **'Napisz komentarz...'**
  String get placeholderEnterComment;

  /// No description provided for @placeholderLabels.
  ///
  /// In pl, this message translates to:
  /// **'Etykiety (oddzielone przecinkiem)...'**
  String get placeholderLabels;

  /// No description provided for @buttonReopen.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz ponownie'**
  String get buttonReopen;

  /// No description provided for @buttonCloseIssue.
  ///
  /// In pl, this message translates to:
  /// **'Zamknij issue'**
  String get buttonCloseIssue;

  /// No description provided for @buttonComment.
  ///
  /// In pl, this message translates to:
  /// **'Skomentuj'**
  String get buttonComment;

  /// No description provided for @buttonOpenOnGitHub.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz na GitHub'**
  String get buttonOpenOnGitHub;

  /// No description provided for @tooltipNewIssue.
  ///
  /// In pl, this message translates to:
  /// **'Nowy issue'**
  String get tooltipNewIssue;

  /// No description provided for @statusOpen.
  ///
  /// In pl, this message translates to:
  /// **'Otwarty'**
  String get statusOpen;

  /// No description provided for @statusClosed.
  ///
  /// In pl, this message translates to:
  /// **'Zamknięty'**
  String get statusClosed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
