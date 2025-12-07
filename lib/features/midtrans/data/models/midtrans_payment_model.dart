import 'package:logger/logger.dart';
import 'package:rentverse/features/midtrans/domain/entity/midtrans_entity.dart';

class MidtransPaymentModel {
  final String token;
  final String redirectUrl;
  final String status;
  final String? message;

  const MidtransPaymentModel({
    required this.token,
    required this.redirectUrl,
    required this.status,
    this.message,
  });

  factory MidtransPaymentModel.fromJson(Map<String, dynamic> json) {
    Logger().i('Parsing midtrans payment response -> $json');
    final data = _asMap(json['data']);
    return MidtransPaymentModel(
      token: data['token']?.toString() ?? '',
      redirectUrl:
          data['redirect_url']?.toString() ??
          data['redirectUrl']?.toString() ??
          '',
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString(),
    );
  }

  MidtransPaymentEntity toEntity() {
    return MidtransPaymentEntity(
      token: token,
      redirectUrl: redirectUrl,
      status: status,
      message: message,
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}
