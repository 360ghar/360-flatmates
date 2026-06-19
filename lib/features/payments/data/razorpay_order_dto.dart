/// DTO + serialization for Razorpay checkout order creation and verification.
///
/// Mirrors `app/schemas/payment.py::RazorpayOrderRequest`,
/// `RazorpayOrderResponse`, and `RazorpayVerifyRequest`. We treat the order
/// payload as opaque on the client — the client only consumes the order id,
/// amount, currency, and the hosted checkout URL — and forwards the
/// Razorpay-issued identifiers back to the backend for signature
/// verification.
class RazorpayOrderDto {
  const RazorpayOrderDto({
    required this.bookingId,
  });

  final int bookingId;

  Map<String, dynamic> toJson() => {'booking_id': bookingId};
}

class RazorpayOrderResponseDto {
  const RazorpayOrderResponseDto({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.bookingId,
    this.keyId,
    this.notes = const <String, String>{},
    this.raw = const <String, dynamic>{},
  });

  final String orderId;
  final num amount;
  final String currency;
  final int bookingId;
  final String? keyId;
  final Map<String, String> notes;
  final Map<String, dynamic> raw;

  factory RazorpayOrderResponseDto.fromJson(Map<String, dynamic> json) {
    final rawNotes = json['notes'];
    return RazorpayOrderResponseDto(
      orderId: json['order_id']?.toString() ?? '',
      amount: (json['amount'] as num?) ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      bookingId: (json['booking_id'] as num?)?.toInt() ?? 0,
      keyId: json['key_id'] as String?,
      notes: rawNotes is Map
          ? Map<String, String>.from(rawNotes)
          : const <String, String>{},
      raw: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'amount': amount,
        'currency': currency,
        'booking_id': bookingId,
        if (keyId != null) 'key_id': keyId,
        'notes': notes,
      };
}

class RazorpayVerifyDto {
  const RazorpayVerifyDto({
    required this.bookingId,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });

  final int bookingId;
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;

  Map<String, dynamic> toJson() => {
        'booking_id': bookingId,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      };
}
