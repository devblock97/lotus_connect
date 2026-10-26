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
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeSepia => '复古';

  @override
  String get general => '通用设置';

  @override
  String get notificationSettings => '通知设置';

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

  @override
  String get signInSubtitle => '登录以继续您的安全对话。';

  @override
  String get joinSubtitle => '加入安全通信的未来。';

  @override
  String get fullNameLabel => '全名';

  @override
  String get enterFullNameHint => '输入您的全名';

  @override
  String get fullNameRequired => '请输入全名';

  @override
  String get usernameLabel => '用户名';

  @override
  String get chooseUsernameHint => '选择唯一的用户名';

  @override
  String get usernameRequired => '请输入用户名';

  @override
  String get usernameMinLength => '用户名至少需要 3 个字符';

  @override
  String get usernameAlphanumericOnly => '仅限字母、数字与下划线';

  @override
  String get emailAddressLabel => '电子邮箱';

  @override
  String get emailHint => 'name@company.com';

  @override
  String get invalidEmail => '无效的电子邮箱地址';

  @override
  String get passwordLabel => '密码';

  @override
  String get loginPasswordHint => '•••••••••';

  @override
  String get createPasswordHint => '创建强密码';

  @override
  String get passwordMinLength => '密码至少需要 6 个字符';

  @override
  String get confirmPasswordLabel => '确认密码';

  @override
  String get repeatPasswordHint => '再次输入您的密码';

  @override
  String get confirmPasswordRequired => '请确认密码';

  @override
  String get passwordsDoNotMatch => '两次输入的密码不一致';

  @override
  String get agreeToTermsPrefix => '我同意 ';

  @override
  String get termsOfService => '服务条款';

  @override
  String get andWord => ' 与 ';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get mustAgreeTerms => '您必须同意服务条款与隐私政策。';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get logInButton => '登录';

  @override
  String get createAccountButton => '创建账户';

  @override
  String get orContinueWith => '或通过以下方式继续';

  @override
  String get dontHaveAccount => '还没有账户？';

  @override
  String get alreadyHaveAccount => '已有账户？';

  @override
  String get registerAction => '注册';

  @override
  String get registrationSuccess => '注册成功！请登录。';

  @override
  String get authenticationFailed => '身份验证失败';

  @override
  String get configureServerHost => '配置服务器主机';

  @override
  String get enterBackendBaseUrl =>
      '输入后端基础 URL (例: http://10.0.2.2:8080/api/v1):';

  @override
  String get pending => '待处理';

  @override
  String get egUsernameHint => '例: johndoe';

  @override
  String friendRequestSentTo(String username) {
    return '已向 @$username 发送好友申请';
  }

  @override
  String get failedToSendRequest => '发送请求失败';

  @override
  String get searchFriends => '搜索好友...';

  @override
  String get myFriends => '我的好友';

  @override
  String get allFriends => '所有好友';

  @override
  String get globalSearchAddFriends => '全局搜索 / 添加好友';

  @override
  String get requested => '已申请';

  @override
  String get friendRequestAccepted => '已接受好友申请！';

  @override
  String get failedToAcceptRequest => '接受请求失败';

  @override
  String get friendRequestRejected => '已拒绝好友申请！';

  @override
  String get failedToRejectRequest => '拒绝请求失败';

  @override
  String get noContactsFound => '未找到联系人';

  @override
  String get noMatchingResults => '没有匹配的搜索结果。';

  @override
  String get sendFriendRequestsPrompt => '发送好友申请以开始聊天和通话。';

  @override
  String get noPendingRequests => '暂无待处理申请';

  @override
  String get online => '在线';

  @override
  String get unknownUser => '未知用户';

  @override
  String get unfriend => '解除好友';

  @override
  String get unfriendConfirmation => '确定要解除此好友关系吗？';

  @override
  String get friendRemoved => '已成功解除好友关系';

  @override
  String get failedToRemoveFriend => '解除好友关系失败';

  @override
  String get commentsTitle => '评论';

  @override
  String get topComments => '热门评论';

  @override
  String get newestFirst => '最新优先';

  @override
  String get oldestFirst => '最早优先';

  @override
  String get noCommentsYet => '暂无评论';

  @override
  String get startConversationPrompt => '开始讨论并分享你的想法！';

  @override
  String get saySomethingNice => '说点好听的吧...';

  @override
  String get addCommentHint => '添加评论...';

  @override
  String replyToUserHint(String username) {
    return '回复 @$username...';
  }

  @override
  String get replyingTo => '回复 ';

  @override
  String get replyAction => '回复';

  @override
  String get likeAction => '赞';

  @override
  String get loveAction => '爱心';

  @override
  String get hahaAction => '哈哈';

  @override
  String get fireAction => '火热';

  @override
  String get wowAction => '哇';

  @override
  String get sadAction => '伤心';

  @override
  String get editedTag => '已编辑';

  @override
  String get authorBadge => '作者';

  @override
  String get pinnedBadge => '已置顶';

  @override
  String get pinnedByCreator => '由创作者置顶';

  @override
  String get pinComment => '置顶评论';

  @override
  String get unpinComment => '取消置顶评论';

  @override
  String get editComment => '编辑评论';

  @override
  String get editCommentHint => '编辑你的评论...';

  @override
  String get deleteComment => '删除评论';

  @override
  String get deleteCommentConfirmTitle => '删除评论？';

  @override
  String get deleteCommentConfirmMessage => '确定要删除这条评论吗？此操作无法撤销。';

  @override
  String get copyText => '复制文本';

  @override
  String get commentCopied => '评论已复制到剪贴板';

  @override
  String get reportComment => '举报评论';

  @override
  String get reportSubmitted => '举报已提交';

  @override
  String get seeMore => '展开';

  @override
  String get seeLess => '收起';

  @override
  String get viewOneReply => '查看 1 条回复';

  @override
  String viewReplies(int count) {
    return '查看 $count 条回复';
  }

  @override
  String get viewMoreReplies => '查看更多回复...';

  @override
  String get hideReplies => '隐藏回复';

  @override
  String viewAllComments(int count) {
    return '查看全部 $count 条评论';
  }

  @override
  String reactionsCount(int count) {
    return '互动 ($count)';
  }

  @override
  String allReactionsCount(int count) {
    return '全部 ($count)';
  }

  @override
  String get noReactionsInCategory => '该分类下暂无互动';

  @override
  String replyToUserAction(String username) {
    return '回复 @$username';
  }

  @override
  String get likeCountSingular => '1 次赞';

  @override
  String likeCountPlural(int count) {
    return '$count 次赞';
  }

  @override
  String get tabHome => '首页';

  @override
  String get liveStreams => '直播';

  @override
  String get createPost => '发布帖子';

  @override
  String get noPostsYet => '暂无帖子';

  @override
  String get postDeletedSuccess => '帖子已成功删除。';

  @override
  String get postDeleteFailed => '删除帖子失败。';

  @override
  String get yourStory => '你的快拍';

  @override
  String whatsOnYourMind(String firstName) {
    return '$firstName，在想些什么呢？';
  }

  @override
  String get photo => '照片';

  @override
  String get camera => '相机';

  @override
  String get feeling => '感受';

  @override
  String get beTheFirstToLike => '成为第一个点赞的人';

  @override
  String get likedBy => '赞了: ';

  @override
  String othersCount(String count) {
    return '其他 $count 人';
  }

  @override
  String get seeMoreInline => '...更多';

  @override
  String get postOptions => '帖子选项';

  @override
  String photosOrVideosCount(int count) {
    return '$count 个照片/视频';
  }

  @override
  String get editPost => '编辑帖子';

  @override
  String editAudience(String visibility) {
    return '编辑受众 ($visibility)';
  }

  @override
  String get deletePost => '删除帖子';

  @override
  String get deletePostConfirmTitle => '删除帖子？';

  @override
  String get deletePostConfirmMessage => '确定要删除这条帖子吗？此操作无法撤销。';

  @override
  String get deleteAction => '删除';

  @override
  String get savePost => '保存帖子';

  @override
  String get postSavedToCollection => '帖子已保存到收藏夹';

  @override
  String get hidePost => '隐藏帖子';

  @override
  String get postHiddenFromFeed => '已从动态中隐藏帖子';

  @override
  String get reportPost => '举报帖子';

  @override
  String get thankYouForReporting => '感谢你的举报';

  @override
  String get copyLinkToPost => '复制帖子链接';

  @override
  String get linkCopiedToClipboard => '链接已复制到剪贴板';

  @override
  String get visibilityPublic => '公开';

  @override
  String get visibilityFriends => '好友';

  @override
  String get visibilityPrivate => '仅自己';

  @override
  String failedToPickImage(String error) {
    return '选择图片失败: $error';
  }

  @override
  String failedToPickVideo(String error) {
    return '选择视频失败: $error';
  }

  @override
  String filterApplied(String filterName) {
    return '滤镜: $filterName';
  }

  @override
  String get sharedToCloseFriends => '已分享至密友！⭐️';

  @override
  String get sharedToYourStory => '已分享至你的快拍！✨';

  @override
  String get failedToShareStory => '分享快拍失败，请重试。';

  @override
  String get discardStoryTitle => '放弃快拍？';

  @override
  String get discardStoryMessage => '如果现在返回，你所做的编辑将会丢失。';

  @override
  String get keepEditing => '继续编辑';

  @override
  String get discard => '放弃';

  @override
  String get textToolTooltip => '文字';

  @override
  String get backgroundGradientTooltip => '背景渐变';

  @override
  String get photoFilterTooltip => '照片滤镜';

  @override
  String get stickersTooltip => '贴纸';

  @override
  String get sharingStory => '正在分享快拍...';

  @override
  String get tapToType => '点击输入';

  @override
  String get modeCreate => '创建';

  @override
  String get modeGallery => '图库';

  @override
  String get modeCamera => '相机';

  @override
  String get pickPhoto => '选择照片';

  @override
  String get pickVideo => '选择视频';

  @override
  String get closeFriends => '密友';

  @override
  String get storyAudience => '快拍受众';

  @override
  String get storyAudiencePublicSubtitle => 'Lotus Connect 上的任何人均可查看';

  @override
  String get storyAudienceCloseFriendsSubtitle => '仅限密友列表中的人';

  @override
  String get storyAudienceFriendsSubtitle => '仅好友可见';

  @override
  String get releaseToRemove => '松开即可删除';

  @override
  String get dragHereToDelete => '拖动到此处删除';

  @override
  String get done => '完成';

  @override
  String get typeSomething => '输入内容...';

  @override
  String get stickers => '贴纸';

  @override
  String get mentionSomeone => '提及某人';

  @override
  String get mentionHint => '@用户名';

  @override
  String get locations => '位置';

  @override
  String get customLocation => '自定义...';

  @override
  String get addLocation => '添加位置';

  @override
  String get cityOrVenueHint => '城市或地点';

  @override
  String get statusAndVibes => '状态 & 氛围';

  @override
  String get emojis => '表情符号';

  @override
  String get discardPostTitle => '放弃帖子？';

  @override
  String get discardPostMessage => '如果现在返回，当前的帖子草稿和附件将会丢失。';

  @override
  String failedToPickImages(String error) {
    return '选择图片失败: $error';
  }

  @override
  String failedToCapturePhoto(String error) {
    return '拍照失败: $error';
  }

  @override
  String get postUpdatedSuccess => '帖子更新成功！';

  @override
  String get postSharedSuccess => '帖子发布成功！';

  @override
  String get postAction => '发布';

  @override
  String get isFeeling => '觉得';

  @override
  String get atLocation => '在';

  @override
  String itemsSelected(int count) {
    return '已选择 $count 项';
  }

  @override
  String get addMore => '添加更多';

  @override
  String get uploadingMediaAndPublishing => '正在上传媒体并发布...';

  @override
  String get savingChanges => '正在保存更改...';

  @override
  String get publishingPost => '正在发布帖子...';

  @override
  String get addToYourPost => '添加到你的帖子';

  @override
  String get photoVideoTooltip => '照片 / 视频';

  @override
  String get feelingActivityTooltip => '感受 / 活动';

  @override
  String get locationTooltip => '位置';

  @override
  String get backgroundColorTooltip => '背景颜色';

  @override
  String get postAudience => '帖子受众';

  @override
  String get postAudiencePublicSubtitle => 'Lotus Connect 内外的任何人都可以看到此帖子';

  @override
  String get postAudienceFriendsSubtitle => '仅限已接受的好友列表中的人';

  @override
  String get postAudiencePrivateSubtitle => '只有你可以在时间线上看到此帖子';

  @override
  String get howAreYouFeeling => '你感觉怎么样？';

  @override
  String get searchFeelings => '搜索感受...';

  @override
  String get whereAreYou => '你在哪里？';

  @override
  String useLocation(String location) {
    return '使用 \"$location\"';
  }

  @override
  String get replySent => '回复已发送！';

  @override
  String get sendMessageHint => '发送消息...';

  @override
  String get send => '发送';

  @override
  String get justNow => '刚刚';

  @override
  String get goLive => '发起直播';

  @override
  String get filterAll => '全部';

  @override
  String get liveNow => '正在直播';

  @override
  String get endedReplays => '已结束回放';

  @override
  String get noLiveStreams => '暂无正在进行的直播';

  @override
  String get noLiveStreamsPrompt => '成为第一个开播并与好友互动的人吧！';

  @override
  String get startStreamingNow => '立即开播';

  @override
  String get streamEnded => '已结束';

  @override
  String get pleaseEnterStreamTitle => '请输入直播标题';

  @override
  String get failedToStartLiveStream => '开启直播失败';

  @override
  String failedToGoLive(String error) {
    return '发起直播失败: $error';
  }

  @override
  String get cameraInitializing => '相机正在初始化...';

  @override
  String get flipCamera => '翻转相机';

  @override
  String get streamTitleHint => '添加一个吸引观众的标题...';

  @override
  String get privacyLabel => '隐私设置:';

  @override
  String get privacyPrivate => '私密';

  @override
  String get rtmpIngestTip => '支持手机摄像头及桌面端 OBS/Streamlabs RTMP 推流';

  @override
  String get goLiveNow => '立即开播';

  @override
  String get liveStreamEndedTitle => '直播已结束';

  @override
  String get streamDuration => '时长';

  @override
  String get peakViewers => '最高观众数';

  @override
  String get totalLikes => '总点赞数';

  @override
  String get totalViews => '总观看次数';

  @override
  String get follow => '关注';

  @override
  String get streamLinkCopied => '直播链接已复制到剪贴板！';

  @override
  String get endLiveStreamTitle => '结束直播？';

  @override
  String get endLiveStreamConfirm => '确定要结束这场直播吗？';

  @override
  String get endStream => '结束直播';
}
