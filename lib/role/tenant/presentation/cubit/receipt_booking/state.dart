import 'package:rentverse/features/bookings/domain/entity/res/booking_response_entity.dart';
import 'package:rentverse/features/midtrans/domain/entity/midtrans_entity.dart';

class ReceiptBookingState {
  final BookingResponseEntity response;
  final bool isPaying;
  final String? error;
  final MidtransPaymentEntity? payment;

  const ReceiptBookingState({
    required this.response,
    this.isPaying = false,
    this.error,
    this.payment,
  });

  ReceiptBookingState copyWith({
    BookingResponseEntity? response,
    bool? isPaying,
    String? error,
    MidtransPaymentEntity? payment,
    bool resetError = false,
  }) {
    return ReceiptBookingState(
      response: response ?? this.response,
      isPaying: isPaying ?? this.isPaying,
      error: resetError ? null : error ?? this.error,
      payment: payment ?? this.payment,
    );
  }
}
