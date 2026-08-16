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

  @override
  String get pleaseEnterRecipientPeerId => 'Please enter a recipient Peer ID';

  @override
  String get signalingEventLogs => 'Signaling Event Logs';

  @override
  String get noEventsLoggedYet =>
      'No events logged yet. Start a call to trace signaling traffic.';

  @override
  String get clearLogs => 'Clear Logs';

  @override
  String get close => 'Close';

  @override
  String get startNewCall => 'Start New Call';

  @override
  String get enterUserAddressToPlaceCall =>
      'Enter user address/UUID to place a WebRTC call:';

  @override
  String get voice => 'Voice';

  @override
  String get video => 'Video';

  @override
  String get viewSignalingLogs => 'View signaling logs';

  @override
  String get refreshHistory => 'Refresh history';

  @override
  String get friends => 'Friends';

  @override
  String get history => 'History';

  @override
  String get searchFriendsOrCalls => 'Search friends or calls...';

  @override
  String get noFriendsFound => 'No friends found';

  @override
  String get noCallHistoryLogs => 'No call history logs';

  @override
  String get incomingCall => 'Incoming Call';

  @override
  String get outgoingCall => 'Outgoing Call';

  @override
  String get calling => 'Calling...';

  @override
  String get ringing => 'Ringing...';

  @override
  String get connected => 'Connected';

  @override
  String get callEnded => 'Call Ended';

  @override
  String get missedCall => 'Missed Call';

  @override
  String get speaker => 'Speaker';

  @override
  String get mute => 'Mute';

  @override
  String get unmute => 'Unmute';

  @override
  String get videoOn => 'Video On';

  @override
  String get videoOff => 'Video Off';

  @override
  String get endCall => 'End Call';

  @override
  String get screenSharingSimulation => 'Screen sharing simulation initiated';

  @override
  String get chatScreenOverlayOpened => 'Chat screen overlay opened';

  @override
  String get moreWithOptionsOpened => 'More call options opened';

  @override
  String get yesterday => 'YESTERDAY';

  @override
  String get older => 'OLDER';

  @override
  String get missed => 'Missed';

  @override
  String get remindMe => 'Remind Me';

  @override
  String get message => 'Message';

  @override
  String get voiceConnected => 'Voice Connected';

  @override
  String get endToEndEncrypted => 'END-TO-END ENCRYPTED';

  @override
  String get you => 'YOU';

  @override
  String get signInSubtitle => 'Sign in to continue your secure conversations.';

  @override
  String get joinSubtitle => 'Join the future of secure communication.';

  @override
  String get fullNameLabel => 'FULL NAME';

  @override
  String get enterFullNameHint => 'Enter your full name';

  @override
  String get fullNameRequired => 'Full name required';

  @override
  String get usernameLabel => 'USERNAME';

  @override
  String get chooseUsernameHint => 'Choose a unique username';

  @override
  String get usernameRequired => 'Username required';

  @override
  String get usernameMinLength => 'Username must be at least 3 characters';

  @override
  String get usernameAlphanumericOnly =>
      'Only alphanumeric characters & underscores';

  @override
  String get emailAddressLabel => 'EMAIL ADDRESS';

  @override
  String get emailHint => 'name@company.com';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get passwordLabel => 'PASSWORD';

  @override
  String get loginPasswordHint => '•••••••••';

  @override
  String get createPasswordHint => 'Create a strong password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get confirmPasswordLabel => 'CONFIRM PASSWORD';

  @override
  String get repeatPasswordHint => 'Repeat your password';

  @override
  String get confirmPasswordRequired => 'Confirm password required';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get agreeToTermsPrefix => 'I agree to the ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get andWord => ' and ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get mustAgreeTerms =>
      'You must agree to the Terms of Service & Privacy Policy.';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get logInButton => 'Log In';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get orContinueWith => 'OR CONTINUE WITH';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get registerAction => 'Register';

  @override
  String get registrationSuccess => 'Registration successful! Please login.';

  @override
  String get authenticationFailed => 'Authentication failed';

  @override
  String get configureServerHost => 'Configure Server Host';

  @override
  String get enterBackendBaseUrl =>
      'Enter the backend base URL (e.g. http://10.0.2.2:8080/api/v1):';
}
