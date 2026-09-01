// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get tabAi => 'Trí tuệ Nhân tạo';

  @override
  String get tabChats => 'Trò chuyện';

  @override
  String get tabCalls => 'Cuộc gọi';

  @override
  String get tabAlerts => 'Thông báo';

  @override
  String get tabProfile => 'Cá nhân';

  @override
  String get activeSession => 'PHIÊN HOẠT ĐỘNG';

  @override
  String get searchConversations => 'Tìm kiếm hội thoại...';

  @override
  String get messageInputHint => 'Gửi tin nhắn cho AI...';

  @override
  String get projectGoals =>
      'Mục tiêu: Tối ưu độ trễ 100ms & đảm bảo bộ nhớ đệm ngoại tuyến';

  @override
  String get today => 'HÔM NAY';

  @override
  String get profileSettings => 'Cá nhân & Cài đặt';

  @override
  String get editProfile => 'Chỉnh sửa cá nhân';

  @override
  String get aiEngineSettings => 'CÀI ĐẶT CÔNG CỤ AI';

  @override
  String get activeAiEngine => 'Công cụ AI kích hoạt';

  @override
  String get googleGeminiLive => 'Google Gemini';

  @override
  String get localLlmOllama => 'LLM Nội bộ (Ollama)';

  @override
  String get neuralAiMock => 'AI Mô phỏng (Mock)';

  @override
  String get geminiApiKey => 'Google AI Studio API Key';

  @override
  String get pasteApiKey => 'Dán API Key từ AI Studio';

  @override
  String get localEndpoint => 'Điểm cuối LLM nội bộ (Ollama / LM Studio)';

  @override
  String get storedNotice =>
      'Lưu trữ bảo mật trong cơ sở dữ liệu SQLite cục bộ';

  @override
  String get ollamaRunningNotice =>
      'Đã lưu cục bộ. Vui lòng bật Ollama/LM Studio.';

  @override
  String get appearance => 'GIAO DIỆN';

  @override
  String get themeSelection => 'Lựa chọn chủ đề';

  @override
  String get general => 'CÀI ĐẶT CHUNG';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get information => 'THÔNG TIN CHUNG';

  @override
  String get about => 'Giới thiệu LotusConnect';

  @override
  String get logOut => 'Đăng xuất';

  @override
  String get keySaved => 'Đã lưu Gemini API Key vào cơ sở dữ liệu!';

  @override
  String get noConfigRequired => 'Chế độ mô phỏng không yêu cầu cấu hình mạng.';

  @override
  String get voiceCall => 'Cuộc gọi thoại';

  @override
  String get videoCall => 'Cuộc gọi video';

  @override
  String get privateConversation => 'Trò chuyện riêng tư';

  @override
  String get contactsAndFriends => 'Danh bạ & Bạn bè';

  @override
  String get startChatWithUserUuid => 'Bắt đầu trò chuyện bằng UUID';

  @override
  String get viewContactsAndFriends => 'Xem Danh bạ & Bạn bè';

  @override
  String get addFriend => 'Thêm bạn bè';

  @override
  String get enterUsernameToSendRequest =>
      'Nhập tên đăng nhập của người dùng để gửi lời mời kết bạn:';

  @override
  String get cancel => 'Hủy';

  @override
  String get sendRequest => 'Gửi yêu cầu';

  @override
  String get contacts => 'Danh bạ';

  @override
  String get refreshContacts => 'Làm mới danh bạ';

  @override
  String get viewMore => 'Xem thêm';

  @override
  String get add => 'Thêm';

  @override
  String get friendRequests => 'Lời mời kết bạn';

  @override
  String get accept => 'Chấp nhận';

  @override
  String get reject => 'Từ chối';

  @override
  String get decline => 'Từ chối';

  @override
  String get chat => 'Trò chuyện';

  @override
  String get deleteMessage => 'Xóa tin nhắn';

  @override
  String get deleteMessageConfirm =>
      'Bạn có chắc chắn muốn xóa tin nhắn này không?';

  @override
  String get editMessage => 'Sửa tin nhắn';

  @override
  String get save => 'Lưu';

  @override
  String get pleaseEnterRecipientPeerId =>
      'Vui lòng nhập Peer ID của người nhận';

  @override
  String get signalingEventLogs => 'Nhật ký sự kiện báo hiệu';

  @override
  String get noEventsLoggedYet =>
      'Chưa có sự kiện nào được ghi nhận. Hãy bắt đầu một cuộc gọi để theo dõi lưu lượng báo hiệu.';

  @override
  String get clearLogs => 'Xóa nhật ký';

  @override
  String get close => 'Đóng';

  @override
  String get startNewCall => 'Bắt đầu cuộc gọi mới';

  @override
  String get enterUserAddressToPlaceCall =>
      'Nhập địa chỉ/UUID người dùng để thực hiện cuộc gọi WebRTC:';

  @override
  String get voice => 'Thoại';

  @override
  String get video => 'Video';

  @override
  String get viewSignalingLogs => 'Xem nhật ký báo hiệu';

  @override
  String get refreshHistory => 'Làm mới lịch sử';

  @override
  String get friends => 'Bạn bè';

  @override
  String get history => 'Lịch sử';

  @override
  String get searchFriendsOrCalls => 'Tìm bạn bè hoặc cuộc gọi...';

  @override
  String get noFriendsFound => 'Không tìm thấy bạn bè nào';

  @override
  String get noCallHistoryLogs => 'Không có lịch sử cuộc gọi';

  @override
  String get incomingCall => 'Cuộc gọi đến';

  @override
  String get outgoingCall => 'Cuộc gọi đi';

  @override
  String get calling => 'Đang gọi...';

  @override
  String get ringing => 'Đang đổ chuông...';

  @override
  String get connected => 'Đã kết nối';

  @override
  String get callEnded => 'Cuộc gọi đã kết thúc';

  @override
  String get missedCall => 'Cuộc gọi nhỡ';

  @override
  String get speaker => 'Loa ngoài';

  @override
  String get mute => 'Tắt tiếng';

  @override
  String get unmute => 'Bật tiếng';

  @override
  String get videoOn => 'Bật video';

  @override
  String get videoOff => 'Tắt video';

  @override
  String get endCall => 'Gác máy';

  @override
  String get screenSharingSimulation => 'Mô phỏng chia sẻ màn hình đã bắt đầu';

  @override
  String get chatScreenOverlayOpened => 'Trình bao phủ trò chuyện đã mở';

  @override
  String get moreWithOptionsOpened => 'Tùy chọn cuộc gọi mở rộng đã mở';

  @override
  String get yesterday => 'HÔM QUA';

  @override
  String get older => 'CŨ HƠN';

  @override
  String get missed => 'Nhỡ';

  @override
  String get remindMe => 'Nhắc tôi';

  @override
  String get message => 'Tin nhắn';

  @override
  String get voiceConnected => 'Cuộc gọi thoại đã kết nối';

  @override
  String get endToEndEncrypted => 'MÃ HÓA ĐẦU CUỐI';

  @override
  String get you => 'BẠN';

  @override
  String get signInSubtitle =>
      'Đăng nhập để tiếp tục các cuộc trò chuyện bảo mật của bạn.';

  @override
  String get joinSubtitle => 'Tham gia tương lai truyền thông bảo mật.';

  @override
  String get fullNameLabel => 'HỌ VÀ TÊN';

  @override
  String get enterFullNameHint => 'Nhập họ và tên của bạn';

  @override
  String get fullNameRequired => 'Vui lòng nhập họ và tên';

  @override
  String get usernameLabel => 'TÊN ĐĂNG NHẬP';

  @override
  String get chooseUsernameHint => 'Chọn tên đăng nhập duy nhất';

  @override
  String get usernameRequired => 'Vui lòng nhập tên đăng nhập';

  @override
  String get usernameMinLength => 'Tên đăng nhập phải có ít nhất 3 ký tự';

  @override
  String get usernameAlphanumericOnly =>
      'Chỉ chấp nhận chữ cái, chữ số và dấu gạch dưới';

  @override
  String get emailAddressLabel => 'ĐỊA CHỈ EMAIL';

  @override
  String get emailHint => 'ten@congty.com';

  @override
  String get invalidEmail => 'Địa chỉ email không hợp lệ';

  @override
  String get passwordLabel => 'MẬT KHẨU';

  @override
  String get loginPasswordHint => '•••••••••';

  @override
  String get createPasswordHint => 'Tạo mật khẩu mạnh';

  @override
  String get passwordMinLength => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get confirmPasswordLabel => 'XÁC NHẬN MẬT KHẨU';

  @override
  String get repeatPasswordHint => 'Nhập lại mật khẩu của bạn';

  @override
  String get confirmPasswordRequired => 'Vui lòng xác nhận mật khẩu';

  @override
  String get passwordsDoNotMatch => 'Mật khẩu xác nhận không khớp';

  @override
  String get agreeToTermsPrefix => 'Tôi đồng ý với ';

  @override
  String get termsOfService => 'Điều khoản dịch vụ';

  @override
  String get andWord => ' và ';

  @override
  String get privacyPolicy => 'Chính sách bảo mật';

  @override
  String get mustAgreeTerms =>
      'Bạn phải đồng ý với Điều khoản dịch vụ & Chính sách bảo mật.';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String get logInButton => 'Đăng nhập';

  @override
  String get createAccountButton => 'Tạo tài khoản';

  @override
  String get orContinueWith => 'HOẶC TIẾP TỤC VỚI';

  @override
  String get dontHaveAccount => 'Chưa có tài khoản? ';

  @override
  String get alreadyHaveAccount => 'Đã có tài khoản? ';

  @override
  String get registerAction => 'Đăng ký';

  @override
  String get registrationSuccess => 'Đăng ký thành công! Vui lòng đăng nhập.';

  @override
  String get authenticationFailed => 'Xác thực thất bại';

  @override
  String get configureServerHost => 'Cấu hình Máy chủ';

  @override
  String get enterBackendBaseUrl =>
      'Nhập URL gốc của máy chủ (vd: http://10.0.2.2:8080/api/v1):';

  @override
  String get pending => 'Chờ duyệt';

  @override
  String get egUsernameHint => 'vd: johndoe';

  @override
  String friendRequestSentTo(String username) {
    return 'Đã gửi lời mời kết bạn đến @$username';
  }

  @override
  String get failedToSendRequest => 'Gửi yêu cầu thất bại';

  @override
  String get searchFriends => 'Tìm kiếm bạn bè...';

  @override
  String get myFriends => 'BẠN BÈ CỦA TÔI';

  @override
  String get allFriends => 'TẤT CẢ BẠN BÈ';

  @override
  String get globalSearchAddFriends => 'TÌM KIẾM TOÀN CẦU / THÊM BẠN';

  @override
  String get requested => 'Đã gửi yêu cầu';

  @override
  String get friendRequestAccepted => 'Đã chấp nhận lời mời kết bạn!';

  @override
  String get failedToAcceptRequest => 'Chấp nhận yêu cầu thất bại';

  @override
  String get friendRequestRejected => 'Đã từ chối lời mời kết bạn!';

  @override
  String get failedToRejectRequest => 'Từ chối yêu cầu thất bại';

  @override
  String get noContactsFound => 'Không tìm thấy danh bạ';

  @override
  String get noMatchingResults =>
      'Không có kết quả phù hợp cho tìm kiếm của bạn.';

  @override
  String get sendFriendRequestsPrompt =>
      'Gửi lời mời kết bạn để bắt đầu trò chuyện và gọi điện.';

  @override
  String get noPendingRequests => 'Không có yêu cầu nào đang chờ';

  @override
  String get online => 'Trực tuyến';

  @override
  String get unknownUser => 'Người dùng không xác định';

  @override
  String get unfriend => 'Hủy kết bạn';

  @override
  String get unfriendConfirmation =>
      'Bạn có chắc muốn hủy kết bạn với người này?';

  @override
  String get friendRemoved => 'Đã xóa bạn thành công';

  @override
  String get failedToRemoveFriend => 'Không thể xóa bạn bè';
}
