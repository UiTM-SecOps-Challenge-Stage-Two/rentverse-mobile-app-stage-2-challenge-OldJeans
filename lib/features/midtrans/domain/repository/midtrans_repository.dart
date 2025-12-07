import 'package:rentverse/features/midtrans/domain/entity/midtrans_entity.dart';

abstract class MidtransRepository {
  Future<MidtransPaymentEntity> payInvoice(String invoiceId);
}
