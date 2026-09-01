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

  /// No description provided for @voiceCall.
  ///
  /// In en, this message translates to:
  /// **'Voice call'**
  String get voiceCall;

  /// No description provided for @videoCall.
  ///
  /// In en, this message translates to:
  /// **'Video call'**
  String get videoCall;

  /// No description provided for @privateConversation.
  ///
  /// In en, this message translates to:
  /// **'Private conversation'**
  String get privateConversation;

  /// No description provided for @contactsAndFriends.
  ///
  /// In en, this message translates to:
  /// **'Contacts & Friends'**
  String get contactsAndFriends;

  /// No description provided for @startChatWithUserUuid.
  ///
  /// In en, this message translates to:
  /// **'Start Chat with User (UUID)'**
  String get startChatWithUserUuid;

  /// No description provided for @viewContactsAndFriends.
  ///
  /// In en, this message translates to:
  /// **'View Contacts & Friends'**
  String get viewContactsAndFriends;

  /// No description provided for @addFriend.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get addFriend;

  /// No description provided for @enterUsernameToSendRequest.
  ///
  /// In en, this message translates to:
  /// **'Enter username of the user to send a friend request to:'**
  String get enterUsernameToSendRequest;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendRequest;

  /// No description provided for @contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// No description provided for @refreshContacts.
  ///
  /// In en, this message translates to:
  /// **'Refresh Contacts'**
  String get refreshContacts;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View more'**
  String get viewMore;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @friendRequests.
  ///
  /// In en, this message translates to:
  /// **'Friend Requests'**
  String get friendRequests;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete Message'**
  String get deleteMessage;

  /// No description provided for @deleteMessageConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this message?'**
  String get deleteMessageConfirm;

  /// No description provided for @editMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit Message'**
  String get editMessage;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @pleaseEnterRecipientPeerId.
  ///
  /// In en, this message translates to:
  /// **'Please enter a recipient Peer ID'**
  String get pleaseEnterRecipientPeerId;

  /// No description provided for @signalingEventLogs.
  ///
  /// In en, this message translates to:
  /// **'Signaling Event Logs'**
  String get signalingEventLogs;

  /// No description provided for @noEventsLoggedYet.
  ///
  /// In en, this message translates to:
  /// **'No events logged yet. Start a call to trace signaling traffic.'**
  String get noEventsLoggedYet;

  /// No description provided for @clearLogs.
  ///
  /// In en, this message translates to:
  /// **'Clear Logs'**
  String get clearLogs;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @startNewCall.
  ///
  /// In en, this message translates to:
  /// **'Start New Call'**
  String get startNewCall;

  /// No description provided for @enterUserAddressToPlaceCall.
  ///
  /// In en, this message translates to:
  /// **'Enter user address/UUID to place a WebRTC call:'**
  String get enterUserAddressToPlaceCall;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @viewSignalingLogs.
  ///
  /// In en, this message translates to:
  /// **'View signaling logs'**
  String get viewSignalingLogs;

  /// No description provided for @refreshHistory.
  ///
  /// In en, this message translates to:
  /// **'Refresh history'**
  String get refreshHistory;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @searchFriendsOrCalls.
  ///
  /// In en, this message translates to:
  /// **'Search friends or calls...'**
  String get searchFriendsOrCalls;

  /// No description provided for @noFriendsFound.
  ///
  /// In en, this message translates to:
  /// **'No friends found'**
  String get noFriendsFound;

  /// No description provided for @noCallHistoryLogs.
  ///
  /// In en, this message translates to:
  /// **'No call history logs'**
  String get noCallHistoryLogs;

  /// No description provided for @incomingCall.
  ///
  /// In en, this message translates to:
  /// **'Incoming Call'**
  String get incomingCall;

  /// No description provided for @outgoingCall.
  ///
  /// In en, this message translates to:
  /// **'Outgoing Call'**
  String get outgoingCall;

  /// No description provided for @calling.
  ///
  /// In en, this message translates to:
  /// **'Calling...'**
  String get calling;

  /// No description provided for @ringing.
  ///
  /// In en, this message translates to:
  /// **'Ringing...'**
  String get ringing;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @callEnded.
  ///
  /// In en, this message translates to:
  /// **'Call Ended'**
  String get callEnded;

  /// No description provided for @missedCall.
  ///
  /// In en, this message translates to:
  /// **'Missed Call'**
  String get missedCall;

  /// No description provided for @speaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get speaker;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// No description provided for @videoOn.
  ///
  /// In en, this message translates to:
  /// **'Video On'**
  String get videoOn;

  /// No description provided for @videoOff.
  ///
  /// In en, this message translates to:
  /// **'Video Off'**
  String get videoOff;

  /// No description provided for @endCall.
  ///
  /// In en, this message translates to:
  /// **'End Call'**
  String get endCall;

  /// No description provided for @screenSharingSimulation.
  ///
  /// In en, this message translates to:
  /// **'Screen sharing simulation initiated'**
  String get screenSharingSimulation;

  /// No description provided for @chatScreenOverlayOpened.
  ///
  /// In en, this message translates to:
  /// **'Chat screen overlay opened'**
  String get chatScreenOverlayOpened;

  /// No description provided for @moreWithOptionsOpened.
  ///
  /// In en, this message translates to:
  /// **'More call options opened'**
  String get moreWithOptionsOpened;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'YESTERDAY'**
  String get yesterday;

  /// No description provided for @older.
  ///
  /// In en, this message translates to:
  /// **'OLDER'**
  String get older;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @remindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind Me'**
  String get remindMe;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @voiceConnected.
  ///
  /// In en, this message translates to:
  /// **'Voice Connected'**
  String get voiceConnected;

  /// No description provided for @endToEndEncrypted.
  ///
  /// In en, this message translates to:
  /// **'END-TO-END ENCRYPTED'**
  String get endToEndEncrypted;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get you;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your secure conversations.'**
  String get signInSubtitle;

  /// No description provided for @joinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the future of secure communication.'**
  String get joinSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get fullNameLabel;

  /// No description provided for @enterFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullNameHint;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name required'**
  String get fullNameRequired;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'USERNAME'**
  String get usernameLabel;

  /// No description provided for @chooseUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a unique username'**
  String get chooseUsernameHint;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username required'**
  String get usernameRequired;

  /// No description provided for @usernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameMinLength;

  /// No description provided for @usernameAlphanumericOnly.
  ///
  /// In en, this message translates to:
  /// **'Only alphanumeric characters & underscores'**
  String get usernameAlphanumericOnly;

  /// No description provided for @emailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'EMAIL ADDRESS'**
  String get emailAddressLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'name@company.com'**
  String get emailHint;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get passwordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'•••••••••'**
  String get loginPasswordHint;

  /// No description provided for @createPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Create a strong password'**
  String get createPasswordHint;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM PASSWORD'**
  String get confirmPasswordLabel;

  /// No description provided for @repeatPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get repeatPasswordHint;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm password required'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @agreeToTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get agreeToTermsPrefix;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @andWord.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get andWord;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @mustAgreeTerms.
  ///
  /// In en, this message translates to:
  /// **'You must agree to the Terms of Service & Privacy Policy.'**
  String get mustAgreeTerms;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @logInButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logInButton;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'OR CONTINUE WITH'**
  String get orContinueWith;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @registerAction.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerAction;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please login.'**
  String get registrationSuccess;

  /// No description provided for @authenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get authenticationFailed;

  /// No description provided for @configureServerHost.
  ///
  /// In en, this message translates to:
  /// **'Configure Server Host'**
  String get configureServerHost;

  /// No description provided for @enterBackendBaseUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter the backend base URL (e.g. http://10.0.2.2:8080/api/v1):'**
  String get enterBackendBaseUrl;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @egUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. johndoe'**
  String get egUsernameHint;

  /// Notification when a friend request is sent
  ///
  /// In en, this message translates to:
  /// **'Friend request sent to @{username}'**
  String friendRequestSentTo(String username);

  /// No description provided for @failedToSendRequest.
  ///
  /// In en, this message translates to:
  /// **'Failed to send request'**
  String get failedToSendRequest;

  /// No description provided for @searchFriends.
  ///
  /// In en, this message translates to:
  /// **'Search friends...'**
  String get searchFriends;

  /// No description provided for @myFriends.
  ///
  /// In en, this message translates to:
  /// **'MY FRIENDS'**
  String get myFriends;

  /// No description provided for @allFriends.
  ///
  /// In en, this message translates to:
  /// **'ALL FRIENDS'**
  String get allFriends;

  /// No description provided for @globalSearchAddFriends.
  ///
  /// In en, this message translates to:
  /// **'GLOBAL SEARCH / ADD FRIENDS'**
  String get globalSearchAddFriends;

  /// No description provided for @requested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requested;

  /// No description provided for @friendRequestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Friend request accepted!'**
  String get friendRequestAccepted;

  /// No description provided for @failedToAcceptRequest.
  ///
  /// In en, this message translates to:
  /// **'Failed to accept request'**
  String get failedToAcceptRequest;

  /// No description provided for @friendRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Friend request rejected!'**
  String get friendRequestRejected;

  /// No description provided for @failedToRejectRequest.
  ///
  /// In en, this message translates to:
  /// **'Failed to reject request'**
  String get failedToRejectRequest;

  /// No description provided for @noContactsFound.
  ///
  /// In en, this message translates to:
  /// **'No Contacts found'**
  String get noContactsFound;

  /// No description provided for @noMatchingResults.
  ///
  /// In en, this message translates to:
  /// **'No matching results for your query.'**
  String get noMatchingResults;

  /// No description provided for @sendFriendRequestsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Send friend requests to start chatting and calling.'**
  String get sendFriendRequestsPrompt;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get noPendingRequests;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// No description provided for @unfriend.
  ///
  /// In en, this message translates to:
  /// **'Unfriend'**
  String get unfriend;

  /// No description provided for @unfriendConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this friend?'**
  String get unfriendConfirmation;

  /// No description provided for @friendRemoved.
  ///
  /// In en, this message translates to:
  /// **'Friend removed successfully'**
  String get friendRemoved;

  /// No description provided for @failedToRemoveFriend.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove friend'**
  String get failedToRemoveFriend;
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
