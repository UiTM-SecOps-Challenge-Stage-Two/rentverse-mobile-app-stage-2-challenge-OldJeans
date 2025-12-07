class MidtransPaymentEntity {
  final String token;
  final String redirectUrl;
  final String status;
  final String? message;

  const MidtransPaymentEntity({
    required this.token,
    required this.redirectUrl,
    required this.status,
    this.message,
  });
}
