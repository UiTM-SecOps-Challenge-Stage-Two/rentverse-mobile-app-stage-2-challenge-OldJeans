import 'package:rentverse/core/usecase/usecase.dart';
import 'package:rentverse/features/midtrans/domain/entity/midtrans_entity.dart';
import 'package:rentverse/features/midtrans/domain/repository/midtrans_repository.dart';

class PayInvoiceUseCase implements UseCase<MidtransPaymentEntity, String> {
  PayInvoiceUseCase(this._repository);

  final MidtransRepository _repository;

  @override
  Future<MidtransPaymentEntity> call({String? param}) {
    if (param == null || param.isEmpty) {
      throw ArgumentError('invoiceId is required');
    }
    return _repository.payInvoice(param);
  }
}
