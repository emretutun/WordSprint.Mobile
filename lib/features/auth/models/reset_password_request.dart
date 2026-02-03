class ResetPasswordRequest {
  final String userId;
  final String token;
  final String newPassword;

  ResetPasswordRequest({
    required this.userId,
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "token": token,
        "newPassword": newPassword,
      };
}
