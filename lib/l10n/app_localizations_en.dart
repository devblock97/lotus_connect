// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabAi => 'AI';

  @override
  String get tabChats => 'Chats';

  @override
  String get tabCalls => 'Calls';

  @override
  String get tabAlerts => 'Alerts';

  @override
  String get tabProfile => 'Profile';

  @override
  String get activeSession => 'ACTIVE SESSION';

  @override
  String get searchConversations => 'Search conversations...';

  @override
  String get messageInputHint => 'Message Neural AI...';

  @override
  String get projectGoals =>
      'Project goals: Optimize latency by 100ms & guarantee offline cache';

  @override
  String get today => 'TODAY';

  @override
  String get profileSettings => 'Profile & Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get aiEngineSettings => 'AI ENGINE SETTINGS';

  @override
  String get activeAiEngine => 'Active AI Engine';

  @override
  String get googleGeminiLive => 'Google Gemini';

  @override
  String get localLlmOllama => 'Local LLM (Ollama)';

  @override
  String get neuralAiMock => 'Neural AI (Mock)';

  @override
  String get geminiApiKey => 'Google AI Studio API Key';

  @override
  String get pasteApiKey => 'Paste AI Studio API Key';

  @override
  String get localEndpoint => 'Local LLM Endpoint (Ollama / LM Studio)';

  @override
  String get storedNotice =>
      'Stored securely in local SQLite database for future sessions';

  @override
  String get ollamaRunningNotice =>
      'Stored in local database. Make sure Ollama/LM Studio is running.';

  @override
  String get appearance => 'APPEARANCE';

  @override
  String get themeSelection => 'Theme Selection';

  @override
  String get general => 'GENERAL';

  @override
  String get language => 'Language';

  @override
  String get information => 'INFORMATION';

  @override
  String get about => 'About LotusConnect';

  @override
  String get logOut => 'Log Out';

  @override
  String get keySaved => 'Gemini API Key saved to database!';

  @override
  String get noConfigRequired =>
      'Mock mode does not require any endpoint configuration.';

  @override
  String get voiceCall => 'Voice call';

  @override
  String get videoCall => 'Video call';

  @override
  String get privateConversation => 'Private conversation';

  @override
  String get contactsAndFriends => 'Contacts & Friends';

  @override
  String get startChatWithUserUuid => 'Start Chat with User (UUID)';

  @override
  String get viewContactsAndFriends => 'View Contacts & Friends';

  @override
  String get addFriend => 'Add Friend';

  @override
  String get enterUsernameToSendRequest =>
      'Enter username of the user to send a friend request to:';

  @override
  String get cancel => 'Cancel';

  @override
  String get sendRequest => 'Send Request';

  @override
  String get contacts => 'Contacts';

  @override
  String get refreshContacts => 'Refresh Contacts';

  @override
  String get viewMore => 'View more';

  @override
  String get add => 'Add';

  @override
  String get friendRequests => 'Friend Requests';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get decline => 'Decline';

  @override
  String get chat => 'Chat';

  @override
  String get deleteMessage => 'Delete Message';

  @override
  String get deleteMessageConfirm =>
      'Are you sure you want to delete this message?';

  @override
  String get editMessage => 'Edit Message';

  @override
  String get save => 'Save';
}
