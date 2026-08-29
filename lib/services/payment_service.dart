import 'dart:math';

import 'package:flutter/material.dart';

/// ============================================================
/// PAYMENT METHOD
/// ============================================================

enum PaymentMethod {
  cashOnDelivery,
  onlinePayment,
}

/// ============================================================
/// PAYMENT STATUS
/// ============================================================

enum PaymentStatus {
  pending,
  paid,
  failed,
  cancelled,
}

/// ============================================================
/// PAYMENT RESULT
/// ============================================================

class PaymentResult {
  final bool success;
  final PaymentMethod method;
  final PaymentStatus status;
  final String paymentId;
  final String message;
  final double amount;

  const PaymentResult({
    required this.success,
    required this.method,
    required this.status,
    required this.paymentId,
    required this.message,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'paymentMethod': method.name,
      'paymentStatus': status.name,
      'paymentId': paymentId,
      'paymentMessage': message,
      'amount': amount,
    };
  }
}

/// ============================================================
/// PAYMENT SERVICE
/// ============================================================

class PaymentService {
  PaymentService._();

  static final PaymentService instance = PaymentService._();

  final Random _random = Random();

  /// ==========================================================
  /// CASH ON DELIVERY
  /// ==========================================================

  Future<PaymentResult> processCashOnDelivery({
    required double amount,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    return PaymentResult(
      success: true,
      method: PaymentMethod.cashOnDelivery,
      status: PaymentStatus.pending,
      paymentId: 'COD-${_generateId()}',
      message:
          'Cash on Delivery selected. Payment will be collected when the order is delivered or picked up.',
      amount: amount,
    );
  }

  /// ==========================================================
  /// ONLINE PAYMENT
  /// ==========================================================

  Future<PaymentResult?> processOnlinePayment({
    required BuildContext context,
    required double amount,
    required String orderId,
    required String farmerName,
    required String farmerPhone,
  }) async {
    final bool? paymentSuccessful = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _SimulatedPaymentDialog(
          amount: amount,
          orderId: orderId,
          farmerName: farmerName,
          farmerPhone: farmerPhone,
        );
      },
    );

    /// User cancelled/closed payment
    if (paymentSuccessful == null) {
      return PaymentResult(
        success: false,
        method: PaymentMethod.onlinePayment,
        status: PaymentStatus.cancelled,
        paymentId: '',
        message: 'Online payment was cancelled.',
        amount: amount,
      );
    }

    /// ========================================================
    /// PAYMENT SUCCESS
    /// ========================================================

    if (paymentSuccessful) {
      return PaymentResult(
        success: true,
        method: PaymentMethod.onlinePayment,

        // VERY IMPORTANT
        status: PaymentStatus.paid,

        paymentId: 'ONLINE-${_generateId()}',

        message:
            'Online payment successful.',

        amount: amount,
      );
    }

    /// ========================================================
    /// PAYMENT FAILURE
    /// ========================================================

    return PaymentResult(
      success: false,
      method: PaymentMethod.onlinePayment,
      status: PaymentStatus.failed,
      paymentId: 'FAILED-${_generateId()}',
      message: 'Online payment failed.',
      amount: amount,
    );
  }

  /// ==========================================================
  /// COMMON PAYMENT PROCESSOR
  /// ==========================================================

  Future<PaymentResult?> processPayment({
    required BuildContext context,
    required PaymentMethod method,
    required double amount,
    required String orderId,
    required String farmerName,
    required String farmerPhone,
  }) async {
    switch (method) {
      case PaymentMethod.cashOnDelivery:
        return processCashOnDelivery(
          amount: amount,
        );

      case PaymentMethod.onlinePayment:
        return processOnlinePayment(
          context: context,
          amount: amount,
          orderId: orderId,
          farmerName: farmerName,
          farmerPhone: farmerPhone,
        );
    }
  }

  /// ==========================================================
  /// PAYMENT ID
  /// ==========================================================

  String _generateId() {
    final timestamp =
        DateTime.now().millisecondsSinceEpoch;

    final randomNumber =
        _random.nextInt(999999);

    return '$timestamp$randomNumber';
  }
}

/// ============================================================
/// SIMULATED PAYMENT DIALOG
/// ============================================================

class _SimulatedPaymentDialog extends StatefulWidget {
  final double amount;
  final String orderId;
  final String farmerName;
  final String farmerPhone;

  const _SimulatedPaymentDialog({
    required this.amount,
    required this.orderId,
    required this.farmerName,
    required this.farmerPhone,
  });

  @override
  State<_SimulatedPaymentDialog> createState() =>
      _SimulatedPaymentDialogState();
}

class _SimulatedPaymentDialogState
    extends State<_SimulatedPaymentDialog> {
  String selectedMethod = 'UPI';

  bool processing = false;

  /// ==========================================================
  /// SIMULATE PAYMENT
  /// ==========================================================

  Future<void> simulatePayment(bool success) async {
    setState(() {
      processing = true;
    });

    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    Navigator.pop(
      context,
      success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      title: const Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: Colors.green,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Online Payment',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      content: SizedBox(
        width: double.maxFinite,

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              /// =================================================
              /// DEMO WARNING
              /// =================================================

              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        Colors.orange.shade200,
                  ),
                ),

                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Icon(
                      Icons.science,
                      color: Colors.orange,
                    ),

                    SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'SIMULATED PAYMENT\n'
                        'No real money will be deducted.',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// =================================================
              /// AMOUNT
              /// =================================================

              Center(
                child: Column(
                  children: [
                    const Text(
                      'Amount to Pay',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '₹${widget.amount.toStringAsFixed(2)}',
                      style:
                          const TextStyle(
                        fontSize: 30,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Order ID: ${widget.orderId}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Choose Payment Method',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 10),

              _paymentOption(
                title: 'UPI',
                subtitle:
                    'Google Pay / PhonePe / Paytm',
                icon: Icons.qr_code_2,
                value: 'UPI',
              ),

              _paymentOption(
                title: 'Debit / Credit Card',
                subtitle:
                    'Visa / Mastercard / RuPay',
                icon: Icons.credit_card,
                value: 'Card',
              ),

              _paymentOption(
                title: 'Net Banking',
                subtitle:
                    'Pay using your bank account',
                icon:
                    Icons.account_balance,
                value: 'Net Banking',
              ),

              const SizedBox(height: 10),

              const Text(
                'This is a project demonstration payment. '
                'No bank account, card or UPI account will be charged.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),

      actions: [
        /// CANCEL
        TextButton(
          onPressed: processing
              ? null
              : () {
                  Navigator.pop(
                    context,
                    false,
                  );
                },

          child:
              const Text('Cancel'),
        ),

        /// FAILURE
        OutlinedButton(
          onPressed: processing
              ? null
              : () {
                  simulatePayment(false);
                },

          child:
              const Text('Simulate Failure'),
        ),

        /// PAY
        ElevatedButton(
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                Colors.green,
            foregroundColor:
                Colors.white,
          ),

          onPressed: processing
              ? null
              : () {
                  simulatePayment(true);
                },

          child: processing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Pay Now',
                ),
        ),
      ],
    );
  }

  /// ==========================================================
  /// PAYMENT OPTION
  /// ==========================================================

  Widget _paymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final bool selected =
        selectedMethod == value;

    return InkWell(
      borderRadius:
          BorderRadius.circular(12),

      onTap: processing
          ? null
          : () {
              setState(() {
                selectedMethod =
                    value;
              });
            },

      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 8,
        ),

        padding:
            const EdgeInsets.all(10),

        decoration: BoxDecoration(
          color: selected
              ? Colors.green.shade50
              : Colors.white,

          borderRadius:
              BorderRadius.circular(12),

          border: Border.all(
            color: selected
                ? Colors.green
                : Colors.grey.shade300,
            width:
                selected ? 2 : 1,
          ),
        ),

        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? Colors.green
                  : Colors.grey,
              size: 30,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            Radio<String>(
              value: value,
              groupValue:
                  selectedMethod,
              activeColor:
                  Colors.green,

              onChanged:
                  processing
                      ? null
                      : (newValue) {
                          if (newValue ==
                              null) {
                            return;
                          }

                          setState(() {
                            selectedMethod =
                                newValue;
                          });
                        },
            ),
          ],
        ),
      ),
    );
  }
}