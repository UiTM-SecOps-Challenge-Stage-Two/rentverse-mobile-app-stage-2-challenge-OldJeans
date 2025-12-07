import 'package:rentverse/features/midtrans/data/source/midtrans_api_service.dart';
import 'package:rentverse/features/midtrans/domain/entity/midtrans_entity.dart';
import 'package:rentverse/features/midtrans/domain/repository/midtrans_repository.dart';

class MidtransRepositoryImpl implements MidtransRepository {
  MidtransRepositoryImpl(this._apiService);

  final MidtransApiService _apiService;

  @override
  Future<MidtransPaymentEntity> payInvoice(String invoiceId) async {
    final result = await _apiService.payInvoice(invoiceId);
    return result.toEntity();
  }
}
