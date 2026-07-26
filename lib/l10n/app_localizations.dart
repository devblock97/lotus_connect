import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

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
    Locale('ja'),
    Locale('vi'),
    Locale('zh')
  ];

  /// No description provided for @tabAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get tabAi;

  /// No description provided for @tabChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get tabChats;

  /// No description provided for @tabCalls.
  ///
  /// In en, this message translates to:
  /// **'Calls'**
  String get tabCalls;

  /// No description provided for @tabAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get tabAlerts;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @activeSession.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE SESSION'**
  String get activeSession;

  /// No description provided for @searchConversations.
  ///
  /// In en, this message translates to:
  /// **'Search conversations...'**
  String get searchConversations;

  /// No description provided for @messageInputHint.
  ///
  /// In en, this message translates to:
  /// **'Message Neural AI...'**
  String get messageInputHint;

  /// No description provided for @projectGoals.
  ///
  /// In en, this message translates to:
  /// **'Project goals: Optimize latency by 100ms & guarantee offline cache'**
  String get projectGoals;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get today;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileSettings;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @aiEngineSettings.
  ///
  /// In en, this message translates to:
  /// **'AI ENGINE SETTINGS'**
  String get aiEngineSettings;

  /// No description provided for @activeAiEngine.
  ///
  /// In en, this message translates to:
  /// **'Active AI Engine'**
  String get activeAiEngine;

  /// No description provided for @googleGeminiLive.
  ///
  /// In en, this message translates to:
  /// **'Google Gemini'**
  String get googleGeminiLive;

  /// No description provided for @localLlmOllama.
  ///
  /// In en, this message translates to:
  /// **'Local LLM (Ollama)'**
  String get localLlmOllama;

  /// No description provided for @neuralAiMock.
  ///
  /// In en, this message translates to:
  /// **'Neural AI (Mock)'**
  String get neuralAiMock;

  /// No description provided for @geminiApiKey.
  ///
  /// In en, this message translates to:
  /// **'Google AI Studio API Key'**
  String get geminiApiKey;

  /// No description provided for @pasteApiKey.
  ///
  /// In en, this message translates to:
  /// **'Paste AI Studio API Key'**
  String get pasteApiKey;

  /// No description provided for @localEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Local LLM Endpoint (Ollama / LM Studio)'**
  String get localEndpoint;

  /// No description provided for @storedNotice.
  ///
  /// In en, this message translates to:
  /// **'Stored securely in local SQLite database for future sessions'**
  String get storedNotice;

  /// No description provided for @ollamaRunningNotice.
  ///
  /// In en, this message translates to:
  /// **'Stored in local database. Make sure Ollama/LM Studio is running.'**
  String get ollamaRunningNotice;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearance;

  /// No description provided for @themeSelection.
  ///
  /// In en, this message translates to:
  /// **'Theme Selection'**
  String get themeSelection;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'GENERAL'**
  String get general;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'INFORMATION'**
  String get information;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About LotusConnect'**
  String get about;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @keySaved.
  ///
  /// In en, this message translates to:
  /// **'Gemini API Key saved to database!'**
  String get keySaved;

  /// No description provided for @noConfigRequired.
  ///
  /// In en, this message translates to:
  /// **'Mock mode does not require any endpoint configuration.'**
  String get noConfigRequired;
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
      <String>['en', 'ja', 'vi', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
