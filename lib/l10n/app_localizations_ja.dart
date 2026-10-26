// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get tabAi => 'AIチャット';

  @override
  String get tabChats => 'チャット';

  @override
  String get tabCalls => '通話';

  @override
  String get tabAlerts => '通知';

  @override
  String get tabProfile => '設定';

  @override
  String get activeSession => '有効なセッション';

  @override
  String get searchConversations => 'スレッドを検索...';

  @override
  String get messageInputHint => 'メッセージを入力...';

  @override
  String get projectGoals => '目標: レイテンシを100ms削減 & オフラインキャッシュの保証';

  @override
  String get today => '今日';

  @override
  String get profileSettings => 'プロフィールと設定';

  @override
  String get editProfile => 'プロフィール編集';

  @override
  String get aiEngineSettings => 'AIエンジン設定';

  @override
  String get activeAiEngine => '有効なAIエンジン';

  @override
  String get googleGeminiLive => 'Google Gemini';

  @override
  String get localLlmOllama => 'ローカルLLM (Ollama)';

  @override
  String get neuralAiMock => 'モックAI';

  @override
  String get geminiApiKey => 'Google AI Studio APIキー';

  @override
  String get pasteApiKey => 'APIキーを貼り付け';

  @override
  String get localEndpoint => 'ローカルLLMエンドポイント (Ollama / LM Studio)';

  @override
  String get storedNotice => 'デバイスのローカルSQLiteに安全に保存されます';

  @override
  String get ollamaRunningNotice => '保存完了。Ollama/LM Studioが起動していることを確認してください。';

  @override
  String get appearance => '外観設定';

  @override
  String get themeSelection => 'テーマ選択';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeSepia => 'セピア';

  @override
  String get general => '一般設定';

  @override
  String get notificationSettings => '通知設定';

  @override
  String get language => '言語';

  @override
  String get information => 'アプリ情報';

  @override
  String get about => 'LotusConnectについて';

  @override
  String get logOut => 'ログアウト';

  @override
  String get keySaved => 'Gemini APIキーを保存しました！';

  @override
  String get noConfigRequired => 'モックモードはエンドポイント設定不要です。';

  @override
  String get voiceCall => '音声通話';

  @override
  String get videoCall => 'ビデオ通話';

  @override
  String get privateConversation => 'プライベートチャット';

  @override
  String get contactsAndFriends => '連絡先と友達';

  @override
  String get startChatWithUserUuid => 'ユーザー(UUID)とチャットを開始';

  @override
  String get viewContactsAndFriends => '連絡先と友達を表示';

  @override
  String get addFriend => '友達を追加';

  @override
  String get enterUsernameToSendRequest => '友達リクエストを送信するユーザーのユーザー名を入力してください：';

  @override
  String get cancel => 'キャンセル';

  @override
  String get sendRequest => 'リクエストを送信';

  @override
  String get contacts => '連絡先';

  @override
  String get refreshContacts => '連絡先を更新';

  @override
  String get viewMore => 'もっと見る';

  @override
  String get add => '追加';

  @override
  String get friendRequests => '友達リクエスト';

  @override
  String get accept => '承諾';

  @override
  String get reject => '拒否';

  @override
  String get decline => '辞退';

  @override
  String get chat => 'チャット';

  @override
  String get deleteMessage => 'メッセージを削除';

  @override
  String get deleteMessageConfirm => 'このメッセージを削除してもよろしいですか？';

  @override
  String get editMessage => 'メッセージを編集';

  @override
  String get save => '保存';

  @override
  String get pleaseEnterRecipientPeerId => '宛先のピアIDを入力してください';

  @override
  String get signalingEventLogs => 'シグナリングイベントログ';

  @override
  String get noEventsLoggedYet =>
      'ログに記録されたイベントはまだありません。通話を開始してシグナリングトラフィックを追跡します。';

  @override
  String get clearLogs => 'ログをクリア';

  @override
  String get close => '閉じる';

  @override
  String get startNewCall => '新しい通話を開始';

  @override
  String get enterUserAddressToPlaceCall =>
      'WebRTC通話を発信するには、ユーザーアドレス/UUIDを入力してください：';

  @override
  String get voice => '音声通話';

  @override
  String get video => '動画';

  @override
  String get viewSignalingLogs => 'シグナリングログを表示';

  @override
  String get refreshHistory => '履歴を更新';

  @override
  String get friends => '友達';

  @override
  String get history => '履歴';

  @override
  String get searchFriendsOrCalls => '友達や通話を検索...';

  @override
  String get noFriendsFound => '友達が見つかりません';

  @override
  String get noCallHistoryLogs => '通話履歴はありません';

  @override
  String get incomingCall => '着信';

  @override
  String get outgoingCall => '発信';

  @override
  String get calling => 'ダイヤル中...';

  @override
  String get ringing => '呼び出し中...';

  @override
  String get connected => '接続中';

  @override
  String get callEnded => '通話終了';

  @override
  String get missedCall => '不在着信';

  @override
  String get speaker => 'スピーカー';

  @override
  String get mute => '消音';

  @override
  String get unmute => '消音解除';

  @override
  String get videoOn => 'ビデオON';

  @override
  String get videoOff => 'ビデオOFF';

  @override
  String get endCall => '通話を終了';

  @override
  String get screenSharingSimulation => '画面共有シミュレーションが開始されました';

  @override
  String get chatScreenOverlayOpened => 'チャット画面オーバーレイが開きました';

  @override
  String get moreWithOptionsOpened => '通話の詳細オプションが開きました';

  @override
  String get yesterday => '昨日';

  @override
  String get older => '過去';

  @override
  String get missed => '不在';

  @override
  String get remindMe => 'リマインダー';

  @override
  String get message => 'メッセージ';

  @override
  String get voiceConnected => '音声通話接続中';

  @override
  String get endToEndEncrypted => 'エンドツーエンドで暗号化';

  @override
  String get you => '自分';

  @override
  String get signInSubtitle => 'サインインして安全なチャットを再開します。';

  @override
  String get joinSubtitle => '安全なコミュニケーションの未来へ。';

  @override
  String get fullNameLabel => '氏名';

  @override
  String get enterFullNameHint => '氏名を入力してください';

  @override
  String get fullNameRequired => '氏名は必須です';

  @override
  String get usernameLabel => 'ユーザー名';

  @override
  String get chooseUsernameHint => '一意のユーザー名を選択';

  @override
  String get usernameRequired => 'ユーザー名は必須です';

  @override
  String get usernameMinLength => 'ユーザー名は3文字以上必要です';

  @override
  String get usernameAlphanumericOnly => '英数字とアンダースコアのみ使用可能';

  @override
  String get emailAddressLabel => 'メールアドレス';

  @override
  String get emailHint => 'name@company.com';

  @override
  String get invalidEmail => '無効なメールアドレスです';

  @override
  String get passwordLabel => 'パスワード';

  @override
  String get loginPasswordHint => '•••••••••';

  @override
  String get createPasswordHint => '強力なパスワードを作成';

  @override
  String get passwordMinLength => 'パスワードは6文字以上必要です';

  @override
  String get confirmPasswordLabel => 'パスワードの確認';

  @override
  String get repeatPasswordHint => 'パスワードを再入力してください';

  @override
  String get confirmPasswordRequired => 'パスワードの確認は必須です';

  @override
  String get passwordsDoNotMatch => 'パスワードが一致しません';

  @override
  String get agreeToTermsPrefix => '利用規約と';

  @override
  String get termsOfService => '利用規約';

  @override
  String get andWord => 'および';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get mustAgreeTerms => '利用規約とプライバシーポリシーに同意する必要があります。';

  @override
  String get forgotPassword => 'パスワードをお忘れですか？';

  @override
  String get logInButton => 'ログイン';

  @override
  String get createAccountButton => 'アカウント作成';

  @override
  String get orContinueWith => 'または以下で継続';

  @override
  String get dontHaveAccount => 'アカウントをお持ちでないですか？ ';

  @override
  String get alreadyHaveAccount => '既にアカウントをお持ちですか？ ';

  @override
  String get registerAction => '新規登録';

  @override
  String get registrationSuccess => '登録が完了しました！ログインしてください。';

  @override
  String get authenticationFailed => '認証に失敗しました';

  @override
  String get configureServerHost => 'サーバーホストの設定';

  @override
  String get enterBackendBaseUrl =>
      'バックエンドのベースURLを入力 (例: http://10.0.2.2:8080/api/v1):';

  @override
  String get pending => '保留中';

  @override
  String get egUsernameHint => '例: johndoe';

  @override
  String friendRequestSentTo(String username) {
    return '@$username に友達リクエストを送信しました';
  }

  @override
  String get failedToSendRequest => 'リクエストの送信に失敗しました';

  @override
  String get searchFriends => '友達を検索...';

  @override
  String get myFriends => 'マイフレンド';

  @override
  String get allFriends => 'すべての友達';

  @override
  String get globalSearchAddFriends => 'グローバル検索 / 友達追加';

  @override
  String get requested => 'リクエスト済み';

  @override
  String get friendRequestAccepted => '友達リクエストを承認しました！';

  @override
  String get failedToAcceptRequest => 'リクエストの承認に失敗しました';

  @override
  String get friendRequestRejected => '友達リクエストを拒否しました！';

  @override
  String get failedToRejectRequest => 'リクエストの拒否に失敗しました';

  @override
  String get noContactsFound => '連絡先が見つかりません';

  @override
  String get noMatchingResults => '一致する結果は見つかりませんでした。';

  @override
  String get sendFriendRequestsPrompt => '友達リクエストを送信してチャットや通話を始めましょう。';

  @override
  String get noPendingRequests => '保留中のリクエストはありません';

  @override
  String get online => 'オンライン';

  @override
  String get unknownUser => '不明なユーザー';

  @override
  String get unfriend => '友達を解除';

  @override
  String get unfriendConfirmation => 'この友達を解除してもよろしいですか？';

  @override
  String get friendRemoved => '友達を正常に解除しました';

  @override
  String get failedToRemoveFriend => '友達の解除に失敗しました';

  @override
  String get commentsTitle => 'コメント';

  @override
  String get topComments => '人気のコメント';

  @override
  String get newestFirst => '新しい順';

  @override
  String get oldestFirst => '古い順';

  @override
  String get noCommentsYet => 'コメントはまだありません';

  @override
  String get startConversationPrompt => '最初のコメントを投稿して会話を始めましょう！';

  @override
  String get saySomethingNice => '優しい言葉をかけましょう...';

  @override
  String get addCommentHint => 'コメントを追加...';

  @override
  String replyToUserHint(String username) {
    return '@$usernameに返信...';
  }

  @override
  String get replyingTo => '返信先: ';

  @override
  String get replyAction => '返信';

  @override
  String get likeAction => 'いいね！';

  @override
  String get loveAction => '超いいね！';

  @override
  String get hahaAction => 'うけるね';

  @override
  String get fireAction => 'すごい';

  @override
  String get wowAction => 'すごいね';

  @override
  String get sadAction => '悲しいね';

  @override
  String get editedTag => '編集済み';

  @override
  String get authorBadge => '投稿者';

  @override
  String get pinnedBadge => '固定済み';

  @override
  String get pinnedByCreator => '投稿者によって固定されました';

  @override
  String get pinComment => 'コメントを固定';

  @override
  String get unpinComment => 'コメントの固定を解除';

  @override
  String get editComment => 'コメントを編集';

  @override
  String get editCommentHint => 'コメントを編集...';

  @override
  String get deleteComment => 'コメントを削除';

  @override
  String get deleteCommentConfirmTitle => 'コメントを削除しますか？';

  @override
  String get deleteCommentConfirmMessage => 'このコメントを削除してもよろしいですか？この操作は取り消せません。';

  @override
  String get copyText => 'テキストをコピー';

  @override
  String get commentCopied => 'コメントをクリップボードにコピーしました';

  @override
  String get reportComment => 'コメントを通報';

  @override
  String get reportSubmitted => '通報を送信しました';

  @override
  String get seeMore => 'もっと見る';

  @override
  String get seeLess => '一部を表示';

  @override
  String get viewOneReply => '返信1件を表示';

  @override
  String viewReplies(int count) {
    return '返信$count件を表示';
  }

  @override
  String get viewMoreReplies => '他の返信を表示...';

  @override
  String get hideReplies => '返信を非表示';

  @override
  String viewAllComments(int count) {
    return '$count件のコメントをすべて見る';
  }

  @override
  String reactionsCount(int count) {
    return 'リアクション ($count)';
  }

  @override
  String allReactionsCount(int count) {
    return 'すべて ($count)';
  }

  @override
  String get noReactionsInCategory => 'このカテゴリーのリアクションはありません';

  @override
  String replyToUserAction(String username) {
    return '@$usernameに返信';
  }

  @override
  String get likeCountSingular => 'いいね！ 1件';

  @override
  String likeCountPlural(int count) {
    return 'いいね！ $count件';
  }

  @override
  String get tabHome => 'ホーム';

  @override
  String get liveStreams => 'ライブ配信';

  @override
  String get createPost => '投稿を作成';

  @override
  String get noPostsYet => '投稿はまだありません';

  @override
  String get postDeletedSuccess => '投稿を正常に削除しました。';

  @override
  String get postDeleteFailed => '投稿の削除に失敗しました。';

  @override
  String get yourStory => 'あなたのストーリーズ';

  @override
  String whatsOnYourMind(String firstName) {
    return '$firstNameさん、今何してる？';
  }

  @override
  String get photo => '写真';

  @override
  String get camera => 'カメラ';

  @override
  String get feeling => '気分';

  @override
  String get beTheFirstToLike => '最初に「いいね！」しましょう';

  @override
  String get likedBy => 'いいね！: ';

  @override
  String othersCount(String count) {
    return '他$count人';
  }

  @override
  String get seeMoreInline => '...もっと見る';

  @override
  String get postOptions => '投稿のオプション';

  @override
  String photosOrVideosCount(int count) {
    return '$count件の写真・動画';
  }

  @override
  String get editPost => '投稿を編集';

  @override
  String editAudience(String visibility) {
    return '公開範囲を編集 ($visibility)';
  }

  @override
  String get deletePost => '投稿を削除';

  @override
  String get deletePostConfirmTitle => '投稿を削除しますか？';

  @override
  String get deletePostConfirmMessage => 'この投稿を削除してもよろしいですか？この操作は取り消せません。';

  @override
  String get deleteAction => '削除';

  @override
  String get savePost => '投稿を保存';

  @override
  String get postSavedToCollection => '投稿をコレクションに保存しました';

  @override
  String get hidePost => '投稿を非表示';

  @override
  String get postHiddenFromFeed => '投稿をフィードで非表示にしました';

  @override
  String get reportPost => '投稿を報告';

  @override
  String get thankYouForReporting => 'ご報告ありがとうございます';

  @override
  String get copyLinkToPost => '投稿のリンクをコピー';

  @override
  String get linkCopiedToClipboard => 'リンクをクリップボードにコピーしました';

  @override
  String get visibilityPublic => '公開';

  @override
  String get visibilityFriends => '友達';

  @override
  String get visibilityPrivate => '自分のみ';

  @override
  String failedToPickImage(String error) {
    return '写真の選択に失敗しました: $error';
  }

  @override
  String failedToPickVideo(String error) {
    return '動画の選択に失敗しました: $error';
  }

  @override
  String filterApplied(String filterName) {
    return 'フィルター: $filterName';
  }

  @override
  String get sharedToCloseFriends => '親しい友達にシェアしました！⭐️';

  @override
  String get sharedToYourStory => 'ストーリーズにシェアしました！✨';

  @override
  String get failedToShareStory => 'ストーリーズのシェアに失敗しました。もう一度お試しください。';

  @override
  String get discardStoryTitle => 'ストーリーズを破棄しますか？';

  @override
  String get discardStoryMessage => '今戻ると、編集内容がすべて失われます。';

  @override
  String get keepEditing => '編集を続ける';

  @override
  String get discard => '破棄';

  @override
  String get textToolTooltip => 'テキスト';

  @override
  String get backgroundGradientTooltip => '背景グラデーション';

  @override
  String get photoFilterTooltip => '写真フィルター';

  @override
  String get stickersTooltip => 'スタンプ';

  @override
  String get sharingStory => 'ストーリーズをシェア中...';

  @override
  String get tapToType => 'タップして入力';

  @override
  String get modeCreate => '作成';

  @override
  String get modeGallery => 'ギャラリー';

  @override
  String get modeCamera => 'カメラ';

  @override
  String get pickPhoto => '写真を選択';

  @override
  String get pickVideo => '動画を選択';

  @override
  String get closeFriends => '親しい友達';

  @override
  String get storyAudience => 'ストーリーズの公開範囲';

  @override
  String get storyAudiencePublicSubtitle => 'Lotus Connect上の誰でも閲覧可能';

  @override
  String get storyAudienceCloseFriendsSubtitle => '親しい友達リストの人のみ';

  @override
  String get storyAudienceFriendsSubtitle => '承認された友達のみ閲覧可能';

  @override
  String get releaseToRemove => '離して削除';

  @override
  String get dragHereToDelete => 'ここにドラッグして削除';

  @override
  String get done => '完了';

  @override
  String get typeSomething => '入力してください...';

  @override
  String get stickers => 'スタンプ';

  @override
  String get mentionSomeone => 'ユーザーをメンション';

  @override
  String get mentionHint => '@ユーザー名';

  @override
  String get locations => '場所';

  @override
  String get customLocation => 'カスタム...';

  @override
  String get addLocation => '場所を追加';

  @override
  String get cityOrVenueHint => '都市またはスポット';

  @override
  String get statusAndVibes => 'ステータス & 気分';

  @override
  String get emojis => '絵文字';

  @override
  String get discardPostTitle => '投稿を破棄しますか？';

  @override
  String get discardPostMessage => '今戻ると、投稿の下書きと添付ファイルが失われます。';

  @override
  String failedToPickImages(String error) {
    return '画像の選択に失敗しました: $error';
  }

  @override
  String failedToCapturePhoto(String error) {
    return '写真の撮影に失敗しました: $error';
  }

  @override
  String get postUpdatedSuccess => '投稿を更新しました！';

  @override
  String get postSharedSuccess => '投稿を共有しました！';

  @override
  String get postAction => '投稿';

  @override
  String get isFeeling => '気分:';

  @override
  String get atLocation => '場所:';

  @override
  String itemsSelected(int count) {
    return '$count個のアイテムを選択中';
  }

  @override
  String get addMore => 'さらに追加';

  @override
  String get uploadingMediaAndPublishing => 'メディアをアップロードして投稿中...';

  @override
  String get savingChanges => '変更を保存中...';

  @override
  String get publishingPost => '投稿を公開中...';

  @override
  String get addToYourPost => '投稿に追加';

  @override
  String get photoVideoTooltip => '写真 / 動画';

  @override
  String get feelingActivityTooltip => '気分 / アクティビティ';

  @override
  String get locationTooltip => '位置情報';

  @override
  String get backgroundColorTooltip => '背景色';

  @override
  String get postAudience => '投稿の公開範囲';

  @override
  String get postAudiencePublicSubtitle => 'Lotus Connectの内外を問わず誰でもこの投稿を閲覧可能';

  @override
  String get postAudienceFriendsSubtitle => '承認された友達リストの人のみ';

  @override
  String get postAudiencePrivateSubtitle => 'タイムライン上であなただけがこの投稿を閲覧可能';

  @override
  String get howAreYouFeeling => 'どんな気分ですか？';

  @override
  String get searchFeelings => '気分を検索...';

  @override
  String get whereAreYou => '今どこにいますか？';

  @override
  String useLocation(String location) {
    return '「$location」を使用';
  }

  @override
  String get replySent => '返信を送信しました！';

  @override
  String get sendMessageHint => 'メッセージを送信...';

  @override
  String get send => '送信';

  @override
  String get justNow => 'たった今';

  @override
  String get goLive => 'ライブ配信';

  @override
  String get filterAll => 'すべて';

  @override
  String get liveNow => 'ライブ中';

  @override
  String get endedReplays => '終了した配信';

  @override
  String get noLiveStreams => '現在配信中のライブはありません';

  @override
  String get noLiveStreamsPrompt => '最初の配信者になって友達とつながりましょう！';

  @override
  String get startStreamingNow => '今すぐ配信を開始';

  @override
  String get streamEnded => '終了';

  @override
  String get pleaseEnterStreamTitle => 'ライブ配信のタイトルを入力してください';

  @override
  String get failedToStartLiveStream => 'ライブ配信を開始できませんでした';

  @override
  String failedToGoLive(String error) {
    return '配信開始に失敗しました: $error';
  }

  @override
  String get cameraInitializing => 'カメラを初期化中...';

  @override
  String get flipCamera => 'カメラを反転';

  @override
  String get streamTitleHint => '視聴者を惹きつけるタイトルを追加...';

  @override
  String get privacyLabel => '公開範囲:';

  @override
  String get privacyPrivate => '非公開';

  @override
  String get rtmpIngestTip => 'スマホカメラおよびPC OBS/Streamlabs RTMP配信に対応';

  @override
  String get goLiveNow => '今すぐ配信開始';

  @override
  String get liveStreamEndedTitle => 'ライブ配信が終了しました';

  @override
  String get streamDuration => '配信時間';

  @override
  String get peakViewers => '最高視聴者数';

  @override
  String get totalLikes => '総いいね数';

  @override
  String get totalViews => '総視聴回数';

  @override
  String get follow => 'フォロー';

  @override
  String get streamLinkCopied => '配信リンクをクリップボードにコピーしました！';

  @override
  String get endLiveStreamTitle => 'ライブ配信を終了しますか？';

  @override
  String get endLiveStreamConfirm => 'このライブ配信を終了してもよろしいですか？';

  @override
  String get endStream => '配信終了';
}
