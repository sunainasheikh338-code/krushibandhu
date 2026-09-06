import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/payment_service.dart';

class TractorBookingScreen extends StatefulWidget {
  final Map<String, dynamic> tractor;
  final Map<String, dynamic> user;

  const TractorBookingScreen({
    super.key,
    required this.tractor,
    required this.user,
  });

  @override
  State<TractorBookingScreen> createState() =>
      _TractorBookingScreenState();
}

class _TractorBookingScreenState extends State<TractorBookingScreen> {
  final TextEditingController durationController =
      TextEditingController();

  final TextEditingController addressController =
      TextEditingController();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String durationType = 'Per Hour';
  bool withLabour = false;
  String paymentMethod = 'Cash on Delivery';

  Map<String, dynamic>? selectedEquipment;
  String? selectedEquipmentId;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool isBooking = false;

  @override
  void dispose() {
    durationController.dispose();
    addressController.dispose();
    super.dispose();
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String get tractorId {
    return widget.tractor['documentId']?.toString() ??
        widget.tractor['tractorId']?.toString() ??
        '';
  }

  String get tractorName {
    return widget.tractor['tractorName']?.toString() ??
        'Tractor';
  }

  String get tractorType {
    return widget.tractor['tractorType']?.toString() ??
        'Tractor';
  }

  String get ownerName {
    return widget.tractor['ownerName']?.toString() ??
        'Owner';
  }

  String get ownerMobile {
    return widget.tractor['mobile']?.toString() ??
        widget.tractor['ownerPhone']?.toString() ??
        '';
  }

  String get village {
    return widget.tractor['village']?.toString() ??
        'Location not available';
  }

  String get imageUrl {
    return widget.tractor['imageUrl']?.toString() ?? '';
  }

  double get pricePerHour {
    return _toDouble(widget.tractor['pricePerHour']);
  }

  double get pricePerDay {
    return _toDouble(widget.tractor['pricePerDay']);
  }

  bool get labourAvailable {
    return widget.tractor['labourAvailable'] == true;
  }

  double get labourCharge {
    return _toDouble(widget.tractor['labourCharge']);
  }

  String get farmerName {
    return widget.user['name']?.toString() ??
        widget.user['farmerName']?.toString() ??
        widget.user['fullName']?.toString() ??
        'Farmer';
  }

  String get farmerMobile {
    return widget.user['mobile']?.toString() ??
        widget.user['phone']?.toString() ??
        '';
  }

  String get farmerId {
    return widget.user['id']?.toString() ??
        widget.user['userId']?.toString() ??
        '';
  }

  double get duration {
    return double.tryParse(
          durationController.text.trim(),
        ) ??
        0;
  }

  double get tractorAmount {
    if (duration <= 0) return 0;

    if (durationType == 'Per Hour') {
      return duration * pricePerHour;
    }

    return duration * pricePerDay;
  }

  double get totalLabourCharge {
    if (!withLabour) return 0;

    if (durationType == 'Per Day') {
      return duration * labourCharge;
    }

    return (duration / 8) * labourCharge;
  }

  double get equipmentPrice {
    if (selectedEquipment == null) return 0;

    final price = selectedEquipment!['price'];

    if (price is num) {
      return price.toDouble();
    }

    return double.tryParse(price?.toString() ?? '') ?? 0;
  }

  double get totalAmount {
    return tractorAmount + totalLabourCharge + equipmentPrice;
  }

  String _generateBookingId() {
    return 'TRB-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _selectDate() async {
    final today = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? today,
      firstDate: DateTime(
        today.year,
        today.month,
        today.day,
      ),
      lastDate: DateTime(today.year + 1),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _bookTractor() async {
    if (duration <= 0) {
      _showMessage(
        'Please enter a valid rental duration.',
        Colors.red,
      );
      return;
    }

    if (selectedDate == null) {
      _showMessage(
        'Please select booking date.',
        Colors.red,
      );
      return;
    }

    if (selectedTime == null) {
      _showMessage(
        'Please select booking time.',
        Colors.red,
      );
      return;
    }

    if (addressController.text.trim().isEmpty) {
      _showMessage(
        'Please enter work location.',
        Colors.red,
      );
      return;
    }

    if (tractorId.isEmpty) {
      _showMessage(
        'Invalid tractor listing.',
        Colors.red,
      );
      return;
    }

    if (totalAmount <= 0) {
      _showMessage(
        'Unable to calculate booking amount.',
        Colors.red,
      );
      return;
    }

    setState(() {
      isBooking = true;
    });

    try {
      final bookingId = _generateBookingId();

      // final PaymentResult paymentResult;

      PaymentResult? paymentResult;

      if (paymentMethod == 'Cash on Delivery') {
        paymentResult =
            await PaymentService.instance.processPayment(
          context: context,
          method: PaymentMethod.cashOnDelivery,
          amount: totalAmount,
          orderId: bookingId,
          farmerName: farmerName,
          farmerPhone: farmerMobile,
        );
      } else {
        paymentResult =
            await PaymentService.instance.processPayment(
          context: context,
          method: PaymentMethod.onlinePayment,
          amount: totalAmount,
          orderId: bookingId,
          farmerName: farmerName,
          farmerPhone: farmerMobile,
        );
      }

      if (paymentResult == null) {
        if (!mounted) return;

        setState(() {
          isBooking = false;
        });

        _showMessage(
          'Payment was not completed.',
          Colors.orange,
        );

        return;
      }

      if (!paymentResult.success) {
        if (!mounted) return;

        setState(() {
          isBooking = false;
        });

        _showMessage(
          paymentResult.message,
          Colors.red,
        );
        return;
      }

      final bookingDate =
          '${selectedDate!.day.toString().padLeft(2, '0')}/'
          '${selectedDate!.month.toString().padLeft(2, '0')}/'
          '${selectedDate!.year}';

      final bookingTime = selectedTime!.format(context);

      final bookingDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final bookingData = <String, dynamic>{
        'bookingId': bookingId,
        'status': 'Pending',

        'equipmentId': selectedEquipment?['documentId'],
        'equipmentName': selectedEquipment?['name'],
        'equipmentPrice': equipmentPrice,

        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),

        'farmerId': farmerId,
        'farmerName': farmerName,
        'farmerPhone': farmerMobile,

        'workLocation': addressController.text.trim(),

        'tractorId': tractorId,
        'tractorName': tractorName,
        'tractorType': tractorType,
        'tractorImageUrl': imageUrl,

        'ownerId':
            widget.tractor['ownerId']?.toString() ?? '',

        'ownerName': ownerName,
        'ownerPhone': ownerMobile,
        'ownerVillage': village,

        'duration': duration,
        'durationType': durationType,

        'rentalOption': withLabour
            ? 'Tractor with Labour'
            : 'Tractor Only',

        'labourIncluded': withLabour,
        'labourAvailable': labourAvailable,
        'labourChargePerDay': labourCharge,

        'tractorPricePerHour': pricePerHour,
        'tractorPricePerDay': pricePerDay,

        'tractorAmount': tractorAmount,
        'labourAmount': totalLabourCharge,
        'totalAmount': totalAmount,

        'bookingDate': bookingDate,
        'bookingTime': bookingTime,

        'bookingDateTime': Timestamp.fromDate(
          bookingDateTime,
        ),

        'paymentMethod': paymentResult.method.name,
        'paymentStatus': paymentResult.status.name,
        'paymentId': paymentResult.paymentId,
        'paymentMessage': paymentResult.message,
      };

      await _firestore
          .collection('tractor_bookings')
          .doc(bookingId)
          .set(bookingData);

      await _firestore
          .collection('tractor_listings')
          .doc(tractorId)
          .update({
        'isAvailable': false,
        'currentBookingId': bookingId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      try {
        await _firestore
            .collection('tractor_listings')
            .doc(tractorId)
            .update({
          'totalBookings': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        isBooking = false;
      });

      await _showSuccessDialog(
        bookingId,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isBooking = false;
      });

      _showMessage(
        'Failed to create booking: $e',
        Colors.red,
      );
    }
  }

  Future<void> _showSuccessDialog(
    String bookingId,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              SizedBox(width: 10),
              Text('Booking Successful'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Your tractor booking has been submitted successfully.',
              ),
              const SizedBox(height: 15),
              Text(
                'Booking ID: $bookingId',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 8),
              const Text(
                'Status: Pending',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context, true);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(
    String message,
    Color color,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('Book Tractor'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _tractorInformation(),

            const SizedBox(height: 22),

            const Text(
              'Booking Schedule',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _dateTimeButton(
                    icon: Icons.calendar_today,
                    title: selectedDate == null
                        ? 'Select Date'
                        : _formatDate(selectedDate!),
                    onTap:
                        isBooking ? null : _selectDate,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _dateTimeButton(
                    icon: Icons.access_time,
                    title: selectedTime == null
                        ? 'Select Time'
                        : selectedTime!.format(context),
                    onTap:
                        isBooking ? null : _selectTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Text(
              'Rental Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _durationOption(
                    title: 'Per Hour',
                    subtitle:
                        '₹${pricePerHour.toStringAsFixed(0)}/hour',
                    icon: Icons.access_time,
                    value: 'Per Hour',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _durationOption(
                    title: 'Per Day',
                    subtitle:
                        '₹${pricePerDay.toStringAsFixed(0)}/day',
                    icon: Icons.calendar_today,
                    value: 'Per Day',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            TextField(
              controller: durationController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              enabled: !isBooking,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: durationType == 'Per Hour'
                    ? 'Number of Hours'
                    : 'Number of Days',
                prefixIcon: Icon(
                  durationType == 'Per Hour'
                      ? Icons.access_time
                      : Icons.calendar_today,
                ),
                suffixText: durationType == 'Per Hour'
                    ? 'Hours'
                    : 'Days',
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 22),

            const SizedBox(height: 22),

            const Text(
              'Equipment / Attachment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('equipment')
                  .where('isAvailable', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Text(
                    'Unable to load equipment.',
                    style: TextStyle(color: Colors.red),
                  );
                }

                final equipmentList = snapshot.data?.docs
                    .map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return {
                    ...data,
                    'documentId': doc.id,
                  };
                })
                    .where(
                      (equipment) =>
                  equipment['compatibleTractorType'] ==
                      tractorType,
                )
                    .toList() ??
                    [];

                if (equipmentList.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'No compatible equipment available.',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  value: selectedEquipmentId,
                  decoration: const InputDecoration(
                    labelText: 'Select Equipment',
                    prefixIcon: Icon(Icons.construction),
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('No equipment selected'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('No Equipment'),
                    ),
                    ...equipmentList.map(
                          (equipment) {
                        return DropdownMenuItem<String>(
                          value: equipment['documentId'].toString(),
                          child: Text(
                            equipment['name']?.toString() ??
                                'Equipment',
                          ),
                        );
                      },
                    ),
                  ],
                  onChanged: isBooking
                      ? null
                      : (value) {
                    setState(() {
                      selectedEquipmentId = value;

                      if (value == null || value.isEmpty) {
                        selectedEquipment = null;
                      } else {
                        selectedEquipment = equipmentList.firstWhere(
                              (equipment) =>
                          equipment['documentId'].toString() ==
                              value,
                        );
                      }
                    });
                  },
                );
              },
            ),

            const Text(
              'Rental Option',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _rentalOption(
              title: 'Tractor Only',
              subtitle: 'Book tractor without labour',
              icon: Icons.agriculture,
              value: false,
            ),

            if (labourAvailable) ...[
              const SizedBox(height: 10),
              _rentalOption(
                title: 'Tractor + Labour',
                subtitle:
                    'Labour: ₹${labourCharge.toStringAsFixed(0)} / day',
                icon: Icons.groups,
                value: true,
              ),
            ],

            const SizedBox(height: 22),

            const Text(
              'Work Location',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: addressController,
              enabled: !isBooking,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Farm / Work Location',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _paymentOption(
              title: 'Cash on Delivery',
              subtitle: 'Pay when service is completed',
              icon: Icons.payments,
              value: 'Cash on Delivery',
            ),

            const SizedBox(height: 10),

            _paymentOption(
              title: 'Online Payment',
              subtitle: 'UPI / Card / Net Banking',
              icon: Icons.account_balance_wallet,
              value: 'Online Payment',
            ),

            const SizedBox(height: 22),

            _priceSummary(),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed:
                    isBooking ? null : _bookTractor,
                icon: isBooking
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.check_circle,
                      ),
                label: Text(
                  isBooking
                      ? 'Processing...'
                      : 'Confirm Tractor Booking',
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _tractorInformation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              tractorName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Type: $tractorType'),
            const SizedBox(height: 6),
            Text('Owner: $ownerName'),
            const SizedBox(height: 6),
            Text('Village: $village'),
            const SizedBox(height: 6),
            Text(
              '₹${pricePerHour.toStringAsFixed(0)} / hour',
            ),
            Text(
              '₹${pricePerDay.toStringAsFixed(0)} / day',
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTimeButton({
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius:
              BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.green,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _durationOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final selected = durationType == value;

    return InkWell(
      onTap: () {
        if (isBooking) return;

        setState(() {
          durationType = value;
          durationController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? Colors.green.shade50
              : Colors.white,
          border: Border.all(
            color: selected
                ? Colors.green
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius:
              BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected
                  ? Colors.green
                  : Colors.grey,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rentalOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
  }) {
    final selected = withLabour == value;

    return InkWell(
      onTap: () {
        if (isBooking) return;

        setState(() {
          withLabour = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? Colors.green.shade50
              : Colors.white,
          border: Border.all(
            color: selected
                ? Colors.green
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius:
              BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? Colors.green
                  : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected
                  ? Colors.green
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final selected = paymentMethod == value;

    return InkWell(
      onTap: () {
        if (isBooking) return;

        setState(() {
          paymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? Colors.green.shade50
              : Colors.white,
          border: Border.all(
            color: selected
                ? Colors.green
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius:
              BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? Colors.green
                  : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: paymentMethod,
              activeColor: Colors.green,
              onChanged: (value) {
                if (value == null || isBooking) return;

                setState(() {
                  paymentMethod = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _priceRow(
            'Tractor',
            '₹${tractorAmount.toStringAsFixed(2)}',
          ),
          if (withLabour)
            _priceRow(
              'Labour',
              '₹${totalLabourCharge.toStringAsFixed(2)}',
            ),
          if (selectedEquipment != null)
            _priceRow(
              selectedEquipment!['name']?.toString() ?? 'Equipment',
              '₹${equipmentPrice.toStringAsFixed(2)}',
            ),
          const Divider(),
          _priceRow(
            'Total Amount',
            '₹${totalAmount.toStringAsFixed(2)}',
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _priceRow(
    String title,
    String amount, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: bold
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color:
                  bold ? Colors.green : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: bold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}