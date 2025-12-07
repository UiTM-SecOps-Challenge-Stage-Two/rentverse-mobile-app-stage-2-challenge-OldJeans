import 'package:logger/logger.dart';
import 'package:rentverse/core/network/dio_client.dart';
import 'package:rentverse/features/midtrans/data/models/midtrans_payment_model.dart';

abstract class MidtransApiService {
  Future<MidtransPaymentModel> payInvoice(String invoiceId);
}

class MidtransApiServiceImpl implements MidtransApiService {
  MidtransApiServiceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<MidtransPaymentModel> payInvoice(String invoiceId) async {
    try {
      final response = await _dioClient.post('/payments/pay/$invoiceId');
      Logger().i('Pay invoice success -> ${response.data}');
      return MidtransPaymentModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      Logger().e('Pay invoice failed', error: e);
      rethrow;
    }
  }
}
