import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/core/services/service_locator.dart';
import 'package:rentverse/features/bookings/domain/entity/res/booking_response_entity.dart';
import 'package:rentverse/role/tenant/presentation/cubit/receipt_booking/cubit.dart';
import 'package:rentverse/role/tenant/presentation/cubit/receipt_booking/state.dart';
import 'package:rentverse/role/tenant/presentation/pages/property/midtrans_payment_page.dart';

class ReceiptBookingPage extends StatelessWidget {
  const ReceiptBookingPage({super.key, required this.response});

  final BookingResponseEntity response;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReceiptBookingCubit(sl(), response),
      child: Scaffold(
        appBar: AppBar(title: const Text('Receipt Booking'), centerTitle: true),
        body: BlocConsumer<ReceiptBookingCubit, ReceiptBookingState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error!)));
            }
            if (state.payment != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MidtransPaymentPage(
                    redirectUrl: state.payment!.redirectUrl,
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            final res = state.response;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Row(label: 'Booking ID', value: res.bookingId),
                    _Row(label: 'Invoice ID', value: res.invoiceId),
                    _Row(label: 'Status', value: res.status),
                    _Row(
                      label: 'Amount',
                      value: '${res.amount} ${res.currency}',
                    ),
                    _Row(label: 'Message', value: res.message ?? '-'),
                    const SizedBox(height: 12),
                    _Row(label: 'Check In', value: _fmtDate(res.checkIn)),
                    _Row(label: 'Check Out', value: _fmtDate(res.checkOut)),
                    _Row(
                      label: 'Payment Deadline',
                      value: _fmtDate(res.paymentDeadline),
                    ),
                    const SizedBox(height: 12),
                    if (res.billingPeriod != null) ...[
                      _Row(
                        label: 'Billing Period',
                        value: res.billingPeriod!.label,
                      ),
                      _Row(
                        label: 'Duration (months)',
                        value: res.billingPeriod!.durationMonths.toString(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (res.property != null) ...[
                      _Row(label: 'Property Title', value: res.property!.title),
                      _Row(
                        label: 'Property Address',
                        value: res.property!.address,
                      ),
                      _Row(label: 'Property ID', value: res.property!.id),
                      _Row(
                        label: 'Primary Image',
                        value: res.property!.imageUrl,
                      ),
                    ],
                    if (state.payment != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Payment Token',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(state.payment!.token),
                      const SizedBox(height: 6),
                      _Row(
                        label: 'Redirect URL',
                        value: state.payment!.redirectUrl,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar:
            BlocBuilder<ReceiptBookingCubit, ReceiptBookingState>(
              builder: (context, state) {
                final res = state.response;
                final amountLabel = '${res.amount} ${res.currency}'.trim();
                return SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Total Price',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                amountLabel,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: state.isPaying
                              ? null
                              : () => context
                                    .read<ReceiptBookingCubit>()
                                    .payNow(),
                          child: state.isPaying
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Pay Now'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}

String _fmtDate(DateTime? date) {
  if (date == null) return '-';
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
