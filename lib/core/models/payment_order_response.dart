/// Model for Payment Order Response from API
/// 
/// API Response Structure:
/// {
///   "success": true,
///   "message": "Payment order created successfully",
///   "data": {
///     "order": {...},
///     "payu_redirect": {...}
///   }
/// }
class PaymentOrderResponse {
  final bool success;
  final String message;
  final PaymentOrderData data;

  PaymentOrderResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PaymentOrderResponse.fromJson(Map<String, dynamic> json) {
    return PaymentOrderResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? PaymentOrderData.fromJson(json['data'] as Map<String, dynamic>)
          : throw Exception('Missing "data" field in payment order response'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

/// Payment Order Data containing order and PayU redirect info
class PaymentOrderData {
  final PaymentOrder order;
  final PayURedirect? payuRedirect;

  PaymentOrderData({
    required this.order,
    this.payuRedirect,
  });

  factory PaymentOrderData.fromJson(Map<String, dynamic> json) {
    // Handle two response formats:
    // 1. POST response: { "order": {...}, "payu_redirect": {...} }
    // 2. GET response: { "id": ..., "order_id": ..., "status": ..., ... } (order fields directly in data)
    PaymentOrder order;
    if (json['order'] != null) {
      // POST response format - order is nested
      order = PaymentOrder.fromJson(json['order'] as Map<String, dynamic>);
    } else {
      // GET response format - order fields are directly in data
      order = PaymentOrder.fromJson(json);
    }

    return PaymentOrderData(
      order: order,
      payuRedirect: json['payu_redirect'] != null
          ? PayURedirect.fromJson(json['payu_redirect'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order.toJson(),
      if (payuRedirect != null) 'payu_redirect': payuRedirect!.toJson(),
    };
  }
}

/// Payment Order details
class PaymentOrder {
  final int id;
  final String orderId;
  final int eventId;
  final String amount;
  final String currency;
  final String status;

  PaymentOrder({
    required this.id,
    required this.orderId,
    required this.eventId,
    required this.amount,
    required this.currency,
    required this.status,
  });

  factory PaymentOrder.fromJson(Map<String, dynamic> json) {
    return PaymentOrder(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      orderId: json['order_id'] as String? ?? '',
      eventId: json['event_id'] is int 
          ? json['event_id'] as int 
          : int.parse(json['event_id'].toString()),
      amount: json['amount']?.toString() ?? '0',
      currency: json['currency'] as String? ?? 'INR',
      status: json['status'] as String? ?? 'created',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'event_id': eventId,
      'amount': amount,
      'currency': currency,
      'status': status,
    };
  }
}

/// PayU Redirect information for payment gateway
class PayURedirect {
  final String payuUrl;
  final PayUPayload payload;

  PayURedirect({
    required this.payuUrl,
    required this.payload,
  });

  factory PayURedirect.fromJson(Map<String, dynamic> json) {
    return PayURedirect(
      payuUrl: json['payu_url'] as String? ?? '',
      payload: json['payload'] != null
          ? PayUPayload.fromJson(json['payload'] as Map<String, dynamic>)
          : throw Exception('Missing "payload" field in payu_redirect'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payu_url': payuUrl,
      'payload': payload.toJson(),
    };
  }
}

/// PayU Payment Payload for redirect
class PayUPayload {
  final String key;
  final String txnid;
  final String amount;
  final String productinfo;
  final String firstname;
  final String email;
  final String phone;
  final String surl; // Success URL
  final String furl; // Failure URL
  final String hash;

  PayUPayload({
    required this.key,
    required this.txnid,
    required this.amount,
    required this.productinfo,
    required this.firstname,
    required this.email,
    required this.phone,
    required this.surl,
    required this.furl,
    required this.hash,
  });

  factory PayUPayload.fromJson(Map<String, dynamic> json) {
    return PayUPayload(
      key: json['key'] as String? ?? '',
      txnid: json['txnid'] as String? ?? '',
      amount: json['amount']?.toString() ?? '0',
      productinfo: json['productinfo'] as String? ?? '',
      firstname: json['firstname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      surl: json['surl'] as String? ?? '',
      furl: json['furl'] as String? ?? '',
      hash: json['hash'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'txnid': txnid,
      'amount': amount,
      'productinfo': productinfo,
      'firstname': firstname,
      'email': email,
      'phone': phone,
      'surl': surl,
      'furl': furl,
      'hash': hash,
    };
  }

  /// Convert payload to form data map for POST request
  Map<String, String> toFormData() {
    return {
      'key': key,
      'txnid': txnid,
      'amount': amount,
      'productinfo': productinfo,
      'firstname': firstname,
      'email': email,
      'phone': phone,
      'surl': surl,
      'furl': furl,
      'hash': hash,
    };
  }
}

