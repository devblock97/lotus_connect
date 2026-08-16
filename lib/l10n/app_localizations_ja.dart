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
  String get general => '一般設定';

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
  String get video => 'ビデオ通話';

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
}
