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
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get general => 'GENERAL';

  @override
  String get notificationSettings => 'Notification Settings';

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

  @override
  String get pending => 'Pending';

  @override
  String get egUsernameHint => 'e.g. johndoe';

  @override
  String friendRequestSentTo(String username) {
    return 'Friend request sent to @$username';
  }

  @override
  String get failedToSendRequest => 'Failed to send request';

  @override
  String get searchFriends => 'Search friends...';

  @override
  String get myFriends => 'MY FRIENDS';

  @override
  String get allFriends => 'ALL FRIENDS';

  @override
  String get globalSearchAddFriends => 'GLOBAL SEARCH / ADD FRIENDS';

  @override
  String get requested => 'Requested';

  @override
  String get friendRequestAccepted => 'Friend request accepted!';

  @override
  String get failedToAcceptRequest => 'Failed to accept request';

  @override
  String get friendRequestRejected => 'Friend request rejected!';

  @override
  String get failedToRejectRequest => 'Failed to reject request';

  @override
  String get noContactsFound => 'No Contacts found';

  @override
  String get noMatchingResults => 'No matching results for your query.';

  @override
  String get sendFriendRequestsPrompt =>
      'Send friend requests to start chatting and calling.';

  @override
  String get noPendingRequests => 'No pending requests';

  @override
  String get online => 'Online';

  @override
  String get unknownUser => 'Unknown User';

  @override
  String get unfriend => 'Unfriend';

  @override
  String get unfriendConfirmation =>
      'Are you sure you want to remove this friend?';

  @override
  String get friendRemoved => 'Friend removed successfully';

  @override
  String get failedToRemoveFriend => 'Failed to remove friend';

  @override
  String get commentsTitle => 'Comments';

  @override
  String get topComments => 'Top comments';

  @override
  String get newestFirst => 'Newest first';

  @override
  String get oldestFirst => 'Oldest first';

  @override
  String get noCommentsYet => 'No comments yet';

  @override
  String get startConversationPrompt =>
      'Start the conversation and share what you think!';

  @override
  String get saySomethingNice => 'Say something nice...';

  @override
  String get addCommentHint => 'Add a comment...';

  @override
  String replyToUserHint(String username) {
    return 'Reply to @$username...';
  }

  @override
  String get replyingTo => 'Replying to ';

  @override
  String get replyAction => 'Reply';

  @override
  String get likeAction => 'Like';

  @override
  String get loveAction => 'Love';

  @override
  String get hahaAction => 'Haha';

  @override
  String get fireAction => 'Fire';

  @override
  String get wowAction => 'Wow';

  @override
  String get sadAction => 'Sad';

  @override
  String get editedTag => 'edited';

  @override
  String get authorBadge => 'Author';

  @override
  String get pinnedBadge => 'Pinned';

  @override
  String get pinnedByCreator => 'Pinned by creator';

  @override
  String get pinComment => 'Pin comment';

  @override
  String get unpinComment => 'Unpin comment';

  @override
  String get editComment => 'Edit comment';

  @override
  String get editCommentHint => 'Edit your comment...';

  @override
  String get deleteComment => 'Delete comment';

  @override
  String get deleteCommentConfirmTitle => 'Delete comment?';

  @override
  String get deleteCommentConfirmMessage =>
      'Are you sure you want to delete this comment? This cannot be undone.';

  @override
  String get copyText => 'Copy text';

  @override
  String get commentCopied => 'Comment copied to clipboard';

  @override
  String get reportComment => 'Report comment';

  @override
  String get reportSubmitted => 'Report submitted';

  @override
  String get seeMore => 'See more';

  @override
  String get seeLess => 'See less';

  @override
  String get viewOneReply => 'View 1 reply';

  @override
  String viewReplies(int count) {
    return 'View $count replies';
  }

  @override
  String get viewMoreReplies => 'View more replies...';

  @override
  String get hideReplies => 'Hide replies';

  @override
  String viewAllComments(int count) {
    return 'View all $count comments';
  }

  @override
  String reactionsCount(int count) {
    return 'Reactions ($count)';
  }

  @override
  String allReactionsCount(int count) {
    return 'All ($count)';
  }

  @override
  String get noReactionsInCategory => 'No reactions in this category';

  @override
  String replyToUserAction(String username) {
    return 'Reply to @$username';
  }

  @override
  String get likeCountSingular => '1 like';

  @override
  String likeCountPlural(int count) {
    return '$count likes';
  }

  @override
  String get tabHome => 'Home';

  @override
  String get liveStreams => 'Live streams';

  @override
  String get createPost => 'Create post';

  @override
  String get noPostsYet => 'No posts yet';

  @override
  String get postDeletedSuccess => 'Post deleted successfully.';

  @override
  String get postDeleteFailed => 'Failed to delete post.';

  @override
  String get yourStory => 'Your story';

  @override
  String whatsOnYourMind(String firstName) {
    return 'What\'s on your mind, $firstName?';
  }

  @override
  String get photo => 'Photo';

  @override
  String get camera => 'Camera';

  @override
  String get feeling => 'Feeling';

  @override
  String get beTheFirstToLike => 'Be the first to like this';

  @override
  String get likedBy => 'Liked by ';

  @override
  String othersCount(String count) {
    return '$count others';
  }

  @override
  String get seeMoreInline => '...more';

  @override
  String get postOptions => 'Post Options';

  @override
  String photosOrVideosCount(int count) {
    return '$count photos / videos';
  }

  @override
  String get editPost => 'Edit post';

  @override
  String editAudience(String visibility) {
    return 'Edit audience ($visibility)';
  }

  @override
  String get deletePost => 'Delete post';

  @override
  String get deletePostConfirmTitle => 'Delete post?';

  @override
  String get deletePostConfirmMessage =>
      'Are you sure you want to delete this post? This cannot be undone.';

  @override
  String get deleteAction => 'Delete';

  @override
  String get savePost => 'Save post';

  @override
  String get postSavedToCollection => 'Post saved to collection';

  @override
  String get hidePost => 'Hide post';

  @override
  String get postHiddenFromFeed => 'Post hidden from feed';

  @override
  String get reportPost => 'Report post';

  @override
  String get thankYouForReporting => 'Thank you for reporting';

  @override
  String get copyLinkToPost => 'Copy link to post';

  @override
  String get linkCopiedToClipboard => 'Link copied to clipboard';

  @override
  String get visibilityPublic => 'Public';

  @override
  String get visibilityFriends => 'Friends';

  @override
  String get visibilityPrivate => 'Only me';

  @override
  String failedToPickImage(String error) {
    return 'Failed to pick image: $error';
  }

  @override
  String failedToPickVideo(String error) {
    return 'Failed to pick video: $error';
  }

  @override
  String filterApplied(String filterName) {
    return 'Filter: $filterName';
  }

  @override
  String get sharedToCloseFriends => 'Shared to Close Friends! ⭐️';

  @override
  String get sharedToYourStory => 'Shared to your story! ✨';

  @override
  String get failedToShareStory => 'Failed to share story. Please try again.';

  @override
  String get discardStoryTitle => 'Discard story?';

  @override
  String get discardStoryMessage =>
      'If you go back now, you\'ll lose any edits you made.';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discard => 'Discard';

  @override
  String get textToolTooltip => 'Text';

  @override
  String get backgroundGradientTooltip => 'Background gradient';

  @override
  String get photoFilterTooltip => 'Photo filter';

  @override
  String get stickersTooltip => 'Stickers';

  @override
  String get sharingStory => 'Sharing story...';

  @override
  String get tapToType => 'Tap to type';

  @override
  String get modeCreate => 'Create';

  @override
  String get modeGallery => 'Gallery';

  @override
  String get modeCamera => 'Camera';

  @override
  String get pickPhoto => 'Pick Photo';

  @override
  String get pickVideo => 'Pick Video';

  @override
  String get closeFriends => 'Close Friends';

  @override
  String get storyAudience => 'Story Audience';

  @override
  String get storyAudiencePublicSubtitle => 'Anyone on Lotus Connect can view';

  @override
  String get storyAudienceCloseFriendsSubtitle =>
      'Only people in your Close Friends list';

  @override
  String get storyAudienceFriendsSubtitle => 'Visible only to accepted friends';

  @override
  String get releaseToRemove => 'Release to remove';

  @override
  String get dragHereToDelete => 'Drag here to delete';

  @override
  String get done => 'Done';

  @override
  String get typeSomething => 'Type something...';

  @override
  String get stickers => 'Stickers';

  @override
  String get mentionSomeone => 'Mention Someone';

  @override
  String get mentionHint => '@username';

  @override
  String get locations => 'Locations';

  @override
  String get customLocation => 'Custom...';

  @override
  String get addLocation => 'Add Location';

  @override
  String get cityOrVenueHint => 'City or venue';

  @override
  String get statusAndVibes => 'Status & Vibes';

  @override
  String get emojis => 'Emojis';

  @override
  String get discardPostTitle => 'Discard post?';

  @override
  String get discardPostMessage =>
      'If you go back now, your current post draft and attachments will be lost.';

  @override
  String failedToPickImages(String error) {
    return 'Failed to pick images: $error';
  }

  @override
  String failedToCapturePhoto(String error) {
    return 'Failed to capture photo: $error';
  }

  @override
  String get postUpdatedSuccess => 'Post updated successfully!';

  @override
  String get postSharedSuccess => 'Post shared successfully!';

  @override
  String get postAction => 'Post';

  @override
  String get isFeeling => 'is feeling';

  @override
  String get atLocation => 'at';

  @override
  String itemsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items selected',
      one: '1 item selected',
    );
    return '$_temp0';
  }

  @override
  String get addMore => 'Add more';

  @override
  String get uploadingMediaAndPublishing => 'Uploading media & publishing...';

  @override
  String get savingChanges => 'Saving changes...';

  @override
  String get publishingPost => 'Publishing post...';

  @override
  String get addToYourPost => 'Add to your post';

  @override
  String get photoVideoTooltip => 'Photo / Video';

  @override
  String get feelingActivityTooltip => 'Feeling / Activity';

  @override
  String get locationTooltip => 'Location';

  @override
  String get backgroundColorTooltip => 'Background Color';

  @override
  String get postAudience => 'Post Audience';

  @override
  String get postAudiencePublicSubtitle =>
      'Anyone on or off Lotus Connect can see this post';

  @override
  String get postAudienceFriendsSubtitle =>
      'Only people in your accepted friends list';

  @override
  String get postAudiencePrivateSubtitle =>
      'Only you can see this post in your timeline';

  @override
  String get howAreYouFeeling => 'How are you feeling?';

  @override
  String get searchFeelings => 'Search feelings...';

  @override
  String get whereAreYou => 'Where are you?';

  @override
  String useLocation(String location) {
    return 'Use \"$location\"';
  }

  @override
  String get replySent => 'Reply sent!';

  @override
  String get sendMessageHint => 'Send message...';

  @override
  String get send => 'Send';

  @override
  String get justNow => 'Just now';

  @override
  String get goLive => 'Go Live';

  @override
  String get filterAll => 'All';

  @override
  String get liveNow => 'Live Now';

  @override
  String get endedReplays => 'Ended Replays';

  @override
  String get noLiveStreams => 'No live streams right now';

  @override
  String get noLiveStreamsPrompt =>
      'Be the first to start a live stream and connect with friends!';

  @override
  String get startStreamingNow => 'Start Streaming Now';

  @override
  String get streamEnded => 'ENDED';

  @override
  String get pleaseEnterStreamTitle =>
      'Please enter a title for your live stream';

  @override
  String get failedToStartLiveStream => 'Failed to start live stream';

  @override
  String failedToGoLive(String error) {
    return 'Failed to go live: $error';
  }

  @override
  String get cameraInitializing => 'Camera initializing...';

  @override
  String get flipCamera => 'Flip Camera';

  @override
  String get streamTitleHint => 'Add a title to attract viewers...';

  @override
  String get privacyLabel => 'Privacy:';

  @override
  String get privacyPrivate => 'Private';

  @override
  String get rtmpIngestTip =>
      'Supports mobile camera & desktop OBS/Streamlabs RTMP ingest';

  @override
  String get goLiveNow => 'GO LIVE NOW';

  @override
  String get liveStreamEndedTitle => 'Live Stream Ended';

  @override
  String get streamDuration => 'Duration';

  @override
  String get peakViewers => 'Peak Viewers';

  @override
  String get totalLikes => 'Total Likes';

  @override
  String get totalViews => 'Total Views';

  @override
  String get follow => 'Follow';

  @override
  String get streamLinkCopied => 'Stream link copied to clipboard!';

  @override
  String get endLiveStreamTitle => 'End Live Stream?';

  @override
  String get endLiveStreamConfirm =>
      'Are you sure you want to conclude this live stream?';

  @override
  String get endStream => 'End Stream';

  @override
  String userIsTyping(String name) {
    return '$name is typing...';
  }

  @override
  String messageUserHint(String name) {
    return 'Message $name...';
  }

  @override
  String get newMessage => 'New message';

  @override
  String get senderYou => 'You';

  @override
  String get pinnedSection => 'PINNED';

  @override
  String get recentSection => 'RECENT';

  @override
  String get noPrivateChatsFound =>
      'No private chats found.\nTap + to start a chat or pull down to refresh!';

  @override
  String get tapToResumeConversation => 'Tap to resume conversation...';

  @override
  String draftPrefix(String draft) {
    return 'Draft: $draft';
  }

  @override
  String get newUserToUserChat => 'New User-to-User Chat';

  @override
  String get recipientUserUuid => 'Recipient User UUID';

  @override
  String get recipientUuidHint => 'e.g. friend-uuid-v7';

  @override
  String get conversationTitle => 'Conversation Title';

  @override
  String get conversationTitleHint => 'e.g. Secret Chat';

  @override
  String get failedToStartChat => 'Failed to start chat with user';

  @override
  String get start => 'Start';

  @override
  String get attachImage => 'Attach Image';

  @override
  String get voiceInput => 'Voice Input';

  @override
  String get addAttachment => 'Add Attachment';

  @override
  String get aiDisclaimer =>
      'AI MAY PROVIDE INACCURATE DATA. VERIFY CRITICAL INFO.';

  @override
  String get neuralAi => 'Neural AI';

  @override
  String get neuralAiIsTyping => 'Neural AI is typing...';

  @override
  String get regenerate => 'Regenerate';

  @override
  String get star => 'Star';

  @override
  String get copy => 'Copy';

  @override
  String get messageCopied => 'Message copied to clipboard';

  @override
  String get failedToLoadImage => 'Failed to load image';

  @override
  String get unableToPlayVideo => 'Unable to play video';

  @override
  String get appName => 'Lotus Connect';

  @override
  String get agreeToTermsSuffix => '.';

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get passwordStrength => 'Password strength';

  @override
  String get failedToLogin => 'Failed to log in';

  @override
  String get failedToRegister => 'Failed to register';
}
