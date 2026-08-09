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

  @override
  String get voiceCall => '语音通话';

  @override
  String get videoCall => '视频通话';

  @override
  String get privateConversation => '私密对话';

  @override
  String get contactsAndFriends => '联系人与好友';

  @override
  String get startChatWithUserUuid => '与用户(UUID)开始聊天';

  @override
  String get viewContactsAndFriends => '查看联系人与好友';

  @override
  String get addFriend => '添加好友';

  @override
  String get enterUsernameToSendRequest => '输入要发送好友请求的用户的用户名：';

  @override
  String get cancel => '取消';

  @override
  String get sendRequest => '发送请求';

  @override
  String get contacts => '联系人';

  @override
  String get refreshContacts => '刷新联系人';

  @override
  String get viewMore => '查看更多';

  @override
  String get add => '添加';

  @override
  String get friendRequests => '好友请求';

  @override
  String get accept => '接受';

  @override
  String get reject => '拒绝';

  @override
  String get decline => '谢绝';

  @override
  String get chat => '聊天';

  @override
  String get deleteMessage => '删除消息';

  @override
  String get deleteMessageConfirm => '您确定要删除这条消息吗？';

  @override
  String get editMessage => '编辑消息';

  @override
  String get save => '保存';

  @override
  String get pleaseEnterRecipientPeerId => '请输入接收方的 Peer ID';

  @override
  String get signalingEventLogs => '信令事件日志';

  @override
  String get noEventsLoggedYet => '暂无已记录的信令事件。开始通话以追踪信令流量。';

  @override
  String get clearLogs => '清除日志';

  @override
  String get close => '关闭';

  @override
  String get startNewCall => '开始新通话';

  @override
  String get enterUserAddressToPlaceCall => '输入用户地址/UUID 以进行 WebRTC 通话：';

  @override
  String get voice => '语音';

  @override
  String get video => '视频';

  @override
  String get viewSignalingLogs => '查看信令日志';

  @override
  String get refreshHistory => '刷新历史记录';

  @override
  String get friends => '好友';

  @override
  String get history => '历史记录';

  @override
  String get searchFriendsOrCalls => '搜索好友或通话...';

  @override
  String get noFriendsFound => '未找到好友';

  @override
  String get noCallHistoryLogs => '暂无通话历史记录';

  @override
  String get incomingCall => '呼入通话';

  @override
  String get outgoingCall => '呼出通话';

  @override
  String get calling => '正在呼叫...';

  @override
  String get ringing => '正在响铃...';

  @override
  String get connected => '已连接';

  @override
  String get callEnded => '通话已结束';

  @override
  String get missedCall => '未接来电';

  @override
  String get speaker => '扬声器';

  @override
  String get mute => '静音';

  @override
  String get unmute => '取消静音';

  @override
  String get videoOn => '开启视频';

  @override
  String get videoOff => '关闭视频';

  @override
  String get endCall => '挂断通话';

  @override
  String get screenSharingSimulation => '已启动屏幕共享模拟';

  @override
  String get chatScreenOverlayOpened => '聊天浮窗已打开';

  @override
  String get moreWithOptionsOpened => '通话更多选项已打开';

  @override
  String get yesterday => '昨天';

  @override
  String get older => '更早';

  @override
  String get missed => '未接';

  @override
  String get remindMe => '提醒我';

  @override
  String get message => '短信';

  @override
  String get voiceConnected => '语音已连接';

  @override
  String get endToEndEncrypted => '端到端加密';

  @override
  String get you => '你';
}
