class VerifyResetCodeRequest {
  final String email;
  final String code;

  VerifyResetCodeRequest({required this.email, required this.code});

  Map<String, dynamic> toJson() => {
    "email": email,
    "code": code,
  };
}
