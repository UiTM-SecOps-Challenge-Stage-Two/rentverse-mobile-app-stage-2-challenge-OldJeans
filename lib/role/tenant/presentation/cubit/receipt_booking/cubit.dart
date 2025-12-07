import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:rentverse/features/bookings/domain/entity/res/booking_response_entity.dart';
import 'package:rentverse/features/midtrans/domain/usecase/pay_invoice_usecase.dart';
import 'package:rentverse/role/tenant/presentation/cubit/receipt_booking/state.dart';

class ReceiptBookingCubit extends Cubit<ReceiptBookingState> {
  ReceiptBookingCubit(this._payInvoiceUseCase, BookingResponseEntity response)
    : super(ReceiptBookingState(response: response));

  final PayInvoiceUseCase _payInvoiceUseCase;

  Future<void> payNow() async {
    emit(state.copyWith(isPaying: true, resetError: true));
    try {
      final res = await _payInvoiceUseCase(param: state.response.invoiceId);
      Logger().i(
        'Pay Now success -> token=${res.token}, redirect=${res.redirectUrl}',
      );
      emit(state.copyWith(isPaying: false, payment: res));
    } catch (e) {
      Logger().e('Pay Now failed', error: e);
      emit(state.copyWith(isPaying: false, error: e.toString()));
    }
  }
}
