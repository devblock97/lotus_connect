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
  String get googleGeminiLive => 'Google Gemini (Trực tiếp)';

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
}
