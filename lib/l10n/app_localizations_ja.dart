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
}
