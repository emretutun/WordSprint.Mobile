class ForgotPasswordCodeRequest {
  final String email;

  ForgotPasswordCodeRequest({required this.email});

  Map<String, dynamic> toJson() => {
    "email": email,
  };
}
