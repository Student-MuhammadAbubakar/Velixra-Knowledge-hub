/// Central place for your backend's base URL and endpoint paths.
/// Change ONLY this file when moving from local testing to a deployed server.
class ApiConstants {
  ApiConstants._();

  // Android emulator uses 10.0.2.2 to reach your machine's localhost.
  // Use your machine's real local IP (e.g. 192.168.x.x) if testing on a
  // physical device connected to the same Wi-Fi as your backend.
  static const baseUrl = "http://127.0.0.1:8000";

  static const String login = "/auth/login";
  static const String forgotPassword = "/auth/forgot-password";
  static const String verifyOtp = "/auth/verify-otp";
  static const String resetPassword = "/auth/reset-password";

  static const String documents = "/documents";
  static const String uploadDocument = "/documents/upload";

  static const String chatAsk = "/chat/ask";
  static const String chatSessions = "/chat/sessions";

  static const String analytics = "/analytics";

  static const String inviteManager = "/team/invite-manager";
  static const String inviteEmployee = "/team/invite-employee";
  static const String acceptInvitation = "/team/accept-invitation";
}