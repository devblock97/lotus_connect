// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get tabAi => 'AI 助手';

  @override
  String get tabChats => '聊天';

  @override
  String get tabCalls => '通话';

  @override
  String get tabAlerts => '提醒';

  @override
  String get tabProfile => '个人资料';

  @override
  String get activeSession => '活跃会话';

  @override
  String get searchConversations => '搜索会话...';

  @override
  String get messageInputHint => '给 AI 发送消息...';

  @override
  String get projectGoals => '项目目标: 优化延迟100ms & 保证离线缓存';

  @override
  String get today => '今天';

  @override
  String get profileSettings => '个人资料与设置';

  @override
  String get editProfile => '编辑资料';

  @override
  String get aiEngineSettings => 'AI 引擎设置';

  @override
  String get activeAiEngine => '活跃 AI 引擎';

  @override
  String get googleGeminiLive => 'Google Gemini';

  @override
  String get localLlmOllama => '本地 LLM (Ollama)';

  @override
  String get neuralAiMock => '模拟 AI (Mock)';

  @override
  String get geminiApiKey => 'Google AI Studio API 密钥';

  @override
  String get pasteApiKey => '粘贴 API 密钥';

  @override
  String get localEndpoint => '本地 LLM 终结点 (Ollama / LM Studio)';

  @override
  String get storedNotice => '安全保存在本地 SQLite 数据库中';

  @override
  String get ollamaRunningNotice => '已保存至本地数据库。请确保 Ollama 或 LM Studio 正在运行。';

  @override
  String get appearance => '外观';

  @override
  String get themeSelection => '主题选择';

  @override
  String get general => '通用设置';

  @override
  String get language => '语言';

  @override
  String get information => '信息';

  @override
  String get about => '关于 LotusConnect';

  @override
  String get logOut => '退出登录';

  @override
  String get keySaved => 'Gemini API 密钥已成功保存！';

  @override
  String get noConfigRequired => '模拟模式无需配置任何终结点。';
}
