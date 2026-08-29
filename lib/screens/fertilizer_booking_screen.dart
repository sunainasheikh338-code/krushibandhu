import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/payment_service.dart';
import 'order_status_screen.dart';

class FertilizerBookingScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const FertilizerBookingScreen({
    super.key,
    required this.user,
  });

  @override
  State<FertilizerBookingScreen> createState() =>
      _FertilizerBookingScreenState();
}

class _FertilizerBookingScreenState
    extends State<FertilizerBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  final PaymentService _paymentService =
      PaymentService.instance;

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController farmerNameController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController villageController =
      TextEditingController();

  final TextEditingController acresController =
      TextEditingController();

  final TextEditingController quantityController =
      TextEditingController(text: "1");

  // ============================================================
  // BOOKING VARIABLES
  // ============================================================

  Map<String, dynamic>? selectedFertilizer;

  String bookingType = "Pickup";

  String paymentMethod = "Cash on Delivery";

  String currentPaymentStatus = "Pending";

  String currentPaymentId = "";

  String currentPaymentMessage = "";

  DateTime? selectedDate;

  TimeOfDay? selectedTime;

  bool isLoading = false;

  double totalPrice = 0;

  // ============================================================
  // LOGGED-IN MOBILE
  // ============================================================

  String get loggedInMobile {
    return widget.user["mobile"]?.toString().trim() ?? "";
  }

  // ============================================================
  // FERTILIZERS
  // ============================================================

  final List<Map<String, dynamic>> fertilizers = [
    {
      "name": "Urea",
      "price": 266,
      "stock": 500,
      "icon": Icons.grass,
      "color": Colors.green,
    },
    {
      "name": "DAP",
      "price": 1350,
      "stock": 250,
      "icon": Icons.agriculture,
      "color": Colors.orange,
    },
    {
      "name": "NPK 10:26:26",
      "price": 1475,
      "stock": 150,
      "icon": Icons.eco,
      "color": Colors.blue,
    },
    {
      "name": "Potash",
      "price": 950,
      "stock": 120,
      "icon": Icons.spa,
      "color": Colors.purple,
    },
    {
      "name": "Organic Compost",
      "price": 450,
      "stock": 300,
      "icon": Icons.energy_savings_leaf,
      "color": Colors.brown,
    },
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    phoneController.text = loggedInMobile;

    if (widget.user["name"] != null) {
      farmerNameController.text =
          widget.user["name"].toString();
    }

    if (widget.user["village"] != null) {
      villageController.text =
          widget.user["village"].toString();
    }

    if (widget.user["land"] != null) {
      acresController.text =
          widget.user["land"].toString();
    }
  }

  // ============================================================
  // CALCULATE PRICE
  // ============================================================

  void calculatePrice() {
    if (selectedFertilizer == null) {
      totalPrice = 0;
      return;
    }

    final int quantity =
        int.tryParse(quantityController.text) ?? 1;

    final double price =
        (selectedFertilizer!["price"] as num).toDouble();

    totalPrice = quantity * price;
  }

  // ============================================================
  // DATE
  // ============================================================

  Future<void> selectDate() async {
    final DateTime today = DateTime.now();

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(
        const Duration(days: 30),
      ),
    );

    if (date != null && mounted) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  // ============================================================
  // TIME
  // ============================================================

  Future<void> selectTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null && mounted) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    farmerNameController.dispose();
    phoneController.dispose();
    villageController.dispose();
    acresController.dispose();
    quantityController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    calculatePrice();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          "Fertilizer Booking",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ==================================================
              // FARMER DETAILS
              // ==================================================

              const Text(
                "Farmer Details",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: farmerNameController,
                decoration: const InputDecoration(
                  labelText: "Farmer Name",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return "Enter Farmer Name";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                readOnly: true,

                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: Icon(Icons.phone),
                  suffixIcon: Icon(
                    Icons.verified,
                    color: Colors.green,
                  ),
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      value.length != 10) {
                    return "Invalid logged-in phone number";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 8),

              const Text(
                "Mobile number is linked to your login account.",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: villageController,
                decoration: const InputDecoration(
                  labelText: "Village",
                  prefixIcon:
                      Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return "Enter Village";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: acresController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Land Area (Acres)",
                  prefixIcon:
                      Icon(Icons.landscape),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return "Enter Land Area";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 25),

              // ==================================================
              // FERTILIZER
              // ==================================================

              const Text(
                "Available Fertilizers",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),

                itemCount: fertilizers.length,

                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),

                itemBuilder: (context, index) {
                  final item = fertilizers[index];

                  final bool selected =
                      selectedFertilizer == item;

                  return InkWell(
                    borderRadius:
                        BorderRadius.circular(18),

                    onTap: isLoading
                        ? null
                        : () {
                            setState(() {
                              selectedFertilizer =
                                  item;
                              calculatePrice();
                            });
                          },

                    child: AnimatedContainer(
                      duration:
                          const Duration(
                        milliseconds: 250,
                      ),

                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.green.shade100
                            : Colors.white,

                        borderRadius:
                            BorderRadius.circular(18),

                        border: Border.all(
                          color: selected
                              ? Colors.green
                              : Colors.grey.shade300,
                          width: 2,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.grey.shade200,
                            blurRadius: 8,
                            offset:
                                const Offset(0, 3),
                          ),
                        ],
                      ),

                      child: Padding(
                        padding:
                            const EdgeInsets.all(12),

                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [
                            Icon(
                              item["icon"] as IconData,
                              size: 45,
                              color:
                                  item["color"]
                                      as Color,
                            ),

                            const SizedBox(height: 10),

                            Text(
                              item["name"].toString(),
                              textAlign:
                                  TextAlign.center,
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "₹${item["price"]}",
                              style:
                                  const TextStyle(
                                color: Colors.green,
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "Stock : ${item["stock"]}",
                              style:
                                  const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              // ==================================================
              // BOOKING DETAILS
              // ==================================================

              const Text(
                "Booking Details",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,

                decoration:
                    const InputDecoration(
                  labelText: "Quantity (Bags)",
                  prefixIcon:
                      Icon(Icons.shopping_bag),
                  border: OutlineInputBorder(),
                ),

                onChanged: (value) {
                  setState(() {
                    calculatePrice();
                  });
                },

                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return "Enter Quantity";
                  }

                  final int? quantity =
                      int.tryParse(value);

                  if (quantity == null ||
                      quantity <= 0) {
                    return "Invalid Quantity";
                  }

                  if (selectedFertilizer != null &&
                      quantity >
                          (selectedFertilizer!["stock"]
                              as int)) {
                    return "Quantity exceeds available stock";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                initialValue: bookingType,

                decoration:
                    const InputDecoration(
                  labelText:
                      "Pickup / Delivery",
                  prefixIcon:
                      Icon(Icons.local_shipping),
                  border:
                      OutlineInputBorder(),
                ),

                items: const [
                  DropdownMenuItem(
                    value: "Pickup",
                    child: Text("Pickup"),
                  ),
                  DropdownMenuItem(
                    value: "Delivery",
                    child: Text("Delivery"),
                  ),
                ],

                onChanged: isLoading
                    ? null
                    : (value) {
                        if (value == null) return;

                        setState(() {
                          bookingType = value;
                        });
                      },
              ),

              const SizedBox(height: 25),

              // ==================================================
              // PAYMENT METHOD
              // ==================================================

              const Text(
                "Payment Method",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),

                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: "Cash on Delivery",
                      groupValue: paymentMethod,
                      activeColor: Colors.green,

                      title: const Text(
                        "Cash on Delivery",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      subtitle: const Text(
                        "Pay when fertilizer is delivered or picked up",
                      ),

                      secondary: const Icon(
                        Icons.money,
                        color: Colors.green,
                      ),

                      onChanged: isLoading
                          ? null
                          : (value) {
                              if (value == null) {
                                return;
                              }

                              setState(() {
                                paymentMethod =
                                    value;
                                currentPaymentStatus =
                                    "Pending";
                                currentPaymentId =
                                    "";
                                currentPaymentMessage =
                                    "";
                              });
                            },
                    ),

                    const Divider(height: 1),

                    RadioListTile<String>(
                      value: "Online Payment",
                      groupValue: paymentMethod,
                      activeColor: Colors.green,

                      title: const Text(
                        "Online Payment",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      subtitle: const Text(
                        "Safe simulated UPI / Card / Net Banking",
                      ),

                      secondary: const Icon(
                        Icons.payment,
                        color: Colors.blue,
                      ),

                      onChanged: isLoading
                          ? null
                          : (value) {
                              if (value == null) {
                                return;
                              }

                              setState(() {
                                paymentMethod =
                                    value;
                                currentPaymentStatus =
                                    "Pending";
                                currentPaymentId =
                                    "";
                                currentPaymentMessage =
                                    "";
                              });
                            },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              if (paymentMethod ==
                  "Online Payment")
                Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius:
                        BorderRadius.circular(10),
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
                          "Demo Mode: No real money will be deducted.",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // ==================================================
              // DATE AND TIME
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child:
                        ElevatedButton.icon(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green,
                        foregroundColor:
                            Colors.white,
                        minimumSize:
                            const Size.fromHeight(
                          55,
                        ),
                      ),

                      onPressed: isLoading
                          ? null
                          : selectDate,

                      icon: const Icon(
                        Icons.calendar_today,
                      ),

                      label: Text(
                        selectedDate == null
                            ? "Select Date"
                            : DateFormat(
                                "dd/MM/yyyy",
                              ).format(
                                selectedDate!,
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child:
                        ElevatedButton.icon(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.orange,
                        foregroundColor:
                            Colors.white,
                        minimumSize:
                            const Size.fromHeight(
                          55,
                        ),
                      ),

                      onPressed: isLoading
                          ? null
                          : selectTime,

                      icon: const Icon(
                        Icons.access_time,
                      ),

                      label: Text(
                        selectedTime == null
                            ? "Select Time"
                            : selectedTime!
                                .format(context),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ==================================================
              // SUMMARY
              // ==================================================

              const Text(
                "Booking Summary",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Card(
                elevation: 4,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),

                child: Padding(
                  padding:
                      const EdgeInsets.all(16),

                  child: Column(
                    children: [
                      _summaryItem(
                        Icons.eco,
                        Colors.green,
                        "Selected Fertilizer",
                        selectedFertilizer ==
                                null
                            ? "-"
                            : selectedFertilizer![
                                "name"],
                      ),

                      _summaryDivider(),

                      _summaryItem(
                        Icons.shopping_bag,
                        Colors.orange,
                        "Quantity",
                        quantityController.text
                                .isEmpty
                            ? "0"
                            : "${quantityController.text} bags",
                      ),

                      _summaryDivider(),

                      _summaryItem(
                        Icons.local_shipping,
                        Colors.blue,
                        "Booking Type",
                        bookingType,
                      ),

                      _summaryDivider(),

                      _summaryItem(
                        Icons.calendar_today,
                        Colors.teal,
                        "Booking Date",
                        selectedDate == null
                            ? "-"
                            : DateFormat(
                                "dd/MM/yyyy",
                              ).format(
                                selectedDate!,
                              ),
                      ),

                      _summaryDivider(),

                      _summaryItem(
                        Icons.access_time,
                        Colors.deepOrange,
                        "Booking Time",
                        selectedTime == null
                            ? "-"
                            : selectedTime!
                                .format(context),
                      ),

                      _summaryDivider(),

                      _summaryItem(
                        Icons.phone,
                        Colors.green,
                        "Farmer Mobile",
                        loggedInMobile.isEmpty
                            ? "-"
                            : loggedInMobile,
                      ),

                      _summaryDivider(),

                      _summaryItem(
                        paymentMethod ==
                                "Cash on Delivery"
                            ? Icons.money
                            : Icons.payment,
                        Colors.green,
                        "Payment Method",
                        paymentMethod,
                      ),

                      _summaryDivider(),

                      _summaryItem(
                        currentPaymentStatus ==
                                "Paid"
                            ? Icons.check_circle
                            : Icons
                                .account_balance_wallet,
                        currentPaymentStatus ==
                                "Paid"
                            ? Colors.green
                            : Colors.orange,
                        "Payment Status",
                        currentPaymentStatus,
                      ),

                      if (currentPaymentId
                          .isNotEmpty) ...[
                        _summaryDivider(),

                        _summaryItem(
                          Icons.receipt_long,
                          Colors.blue,
                          "Payment ID",
                          currentPaymentId,
                        ),
                      ],

                      _summaryDivider(),

                      _summaryItem(
                        Icons.currency_rupee,
                        Colors.green,
                        "Total Amount",
                        "₹${totalPrice.toStringAsFixed(0)}",
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // BOOK NOW
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 55,

                child:
                    ElevatedButton.icon(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green,
                    foregroundColor:
                        Colors.white,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),

                  onPressed: isLoading
                      ? null
                      : bookFertilizer,

                  icon: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.check_circle,
                        ),

                  label: Text(
                    isLoading
                        ? "Processing..."
                        : "Book Now",

                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY ITEM
  // ============================================================

  Widget _summaryItem(
    IconData icon,
    Color color,
    String title,
    String value, {
    bool bold = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: Icon(
        icon,
        color: color,
      ),

      title: Text(
        title,
        style: TextStyle(
          fontWeight:
              bold ? FontWeight.bold : null,
        ),
      ),

      trailing: SizedBox(
        width: 150,

        child: Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(
            fontWeight:
                bold ? FontWeight.bold : null,
            color: bold
                ? Colors.green
                : null,
            fontSize: bold ? 20 : 14,
          ),
        ),
      ),
    );
  }

  Widget _summaryDivider() {
    return const Divider();
  }

  // ============================================================
  // BOOK FERTILIZER
  // ============================================================

  Future<void> bookFertilizer() async {
    // ----------------------------------------------------------
    // VALIDATE FORM
    // ----------------------------------------------------------

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ----------------------------------------------------------
    // MOBILE
    // ----------------------------------------------------------

    if (loggedInMobile.isEmpty ||
        loggedInMobile.length != 10) {
      _showMessage(
        "Logged-in mobile number is missing or invalid.",
        Colors.red,
      );

      return;
    }

    // ----------------------------------------------------------
    // FERTILIZER
    // ----------------------------------------------------------

    if (selectedFertilizer == null) {
      _showMessage(
        "Please select a fertilizer.",
        Colors.red,
      );

      return;
    }

    // ----------------------------------------------------------
    // DATE AND TIME
    // ----------------------------------------------------------

    if (selectedDate == null ||
        selectedTime == null) {
      _showMessage(
        "Please select booking date and time.",
        Colors.red,
      );

      return;
    }

    // ----------------------------------------------------------
    // QUANTITY
    // ----------------------------------------------------------

    final int? quantity =
        int.tryParse(quantityController.text);

    if (quantity == null || quantity <= 0) {
      _showMessage(
        "Please enter a valid quantity.",
        Colors.red,
      );

      return;
    }

    // ----------------------------------------------------------
    // CALCULATE TOTAL
    // ----------------------------------------------------------

    calculatePrice();

    // ----------------------------------------------------------
    // START LOADING
    // ----------------------------------------------------------

    setState(() {
      isLoading = true;
    });

    try {
      // --------------------------------------------------------
      // CREATE BOOKING ID
      // --------------------------------------------------------

      final String bookingId =
          "FB${DateTime.now().millisecondsSinceEpoch}";

      // ========================================================
      // PAYMENT PROCESSING
      // ========================================================

      PaymentResult? paymentResult;

      // --------------------------------------------------------
      // CASH ON DELIVERY
      // --------------------------------------------------------

      if (paymentMethod ==
          "Cash on Delivery") {
        paymentResult =
            await _paymentService.processPayment(
          context: context,
          method: PaymentMethod.cashOnDelivery,
          amount: totalPrice,
          orderId: bookingId,
          farmerName:
              farmerNameController.text.trim(),
          farmerPhone: loggedInMobile,
        );
      }

      // --------------------------------------------------------
      // SIMULATED ONLINE PAYMENT
      // --------------------------------------------------------

      else {
        paymentResult =
            await _paymentService.processPayment(
          context: context,
          method: PaymentMethod.onlinePayment,
          amount: totalPrice,
          orderId: bookingId,
          farmerName:
              farmerNameController.text.trim(),
          farmerPhone: loggedInMobile,
        );
      }

      // --------------------------------------------------------
      // PAYMENT RESULT WAS NULL
      // --------------------------------------------------------

      if (paymentResult == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        _showMessage(
          "Payment was not completed.",
          Colors.orange,
        );

        return;
      }

      // --------------------------------------------------------
      // UPDATE PAYMENT UI
      // --------------------------------------------------------

      if (mounted) {
        setState(() {
          currentPaymentStatus =
              _paymentStatusText(
            paymentResult!.status,
          );

          currentPaymentId =
              paymentResult.paymentId;

          currentPaymentMessage =
              paymentResult.message;
        });
      }

      // --------------------------------------------------------
      // PAYMENT FAILED / CANCELLED
      //
      // DO NOT CREATE THE BOOKING.
      // --------------------------------------------------------

      if (!paymentResult.success) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        await _showPaymentResultDialog(
          paymentResult,
        );

        return;
      }

      // ========================================================
      // PAYMENT SUCCESS
      // ========================================================

      String orderStatus = "Pending";

      // COD remains pending because farmer pays later.
      if (paymentResult.method ==
          PaymentMethod.cashOnDelivery) {
        orderStatus = "Pending";
      }

      // Online simulated payment is already paid.
      if (paymentResult.method ==
              PaymentMethod.onlinePayment &&
          paymentResult.status ==
              PaymentStatus.paid) {
        orderStatus = "Pending";
      }

      // --------------------------------------------------------
      // SAVE BOOKING TO FIRESTORE
      // --------------------------------------------------------

      await firestore
          .collection("fertilizer_bookings")
          .doc(bookingId)
          .set({
        "bookingId": bookingId,

        // ======================================================
        // FARMER
        // ======================================================

        "farmerName":
            farmerNameController.text.trim(),

        "phone": loggedInMobile,

        "farmerMobile": loggedInMobile,

        "village":
            villageController.text.trim(),

        "landArea":
            acresController.text.trim(),

        // ======================================================
        // FERTILIZER
        // ======================================================

        "fertilizer":
            selectedFertilizer!["name"],

        "pricePerBag":
            selectedFertilizer!["price"],

        "quantity": quantity,

        "totalPrice": totalPrice,

        // ======================================================
        // BOOKING
        // ======================================================

        "bookingType": bookingType,

        "bookingDate":
            DateFormat("dd/MM/yyyy")
                .format(selectedDate!),

        "bookingTime":
            selectedTime!.format(context),

        // ======================================================
        // ORDER STATUS
        // ======================================================

        "status": orderStatus,

        // ======================================================
        // PAYMENT
        // ======================================================

        "paymentMethod":
            paymentResult.method.name,

        "paymentStatus":
            paymentResult.status.name,

        "paymentId":
            paymentResult.paymentId,

        "paymentMessage":
            paymentResult.message,

        // ======================================================
        // CANCELLATION
        // ======================================================

        "cancelledAt": null,

        "cancellationReason": null,

        "cancelledBy": null,

        // ======================================================
        // REFUND
        // ======================================================

        "refundStatus":
            paymentResult.method ==
                    PaymentMethod.onlinePayment
                ? "Not Applicable"
                : "Not Applicable",

        // ======================================================
        // CREATED TIME
        // ======================================================

        "createdAt":
            FieldValue.serverTimestamp(),
      });

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      await _showBookingSuccessDialog(
        bookingId: bookingId,
        quantity: quantity,
        paymentResult: paymentResult,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(
        "Booking Failed\n$e",
        Colors.red,
      );
    }
  }

  // ============================================================
  // PAYMENT STATUS TEXT
  // ============================================================

  String _paymentStatusText(
    PaymentStatus status,
  ) {
    switch (status) {
      case PaymentStatus.pending:
        return "Pending";

      case PaymentStatus.paid:
        return "Paid";

      case PaymentStatus.failed:
        return "Failed";

      case PaymentStatus.cancelled:
        return "Cancelled";
    }
  }

  // ============================================================
  // PAYMENT RESULT DIALOG
  // ============================================================

  Future<void> _showPaymentResultDialog(
    PaymentResult result,
  ) async {
    if (!mounted) return;

    final bool success = result.success;

    await showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),

          title: Row(
            children: [
              Icon(
                success
                    ? Icons.check_circle
                    : Icons.cancel,
                color: success
                    ? Colors.green
                    : Colors.red,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  success
                      ? "Payment Successful"
                      : "Payment Not Completed",
                ),
              ),
            ],
          ),

          content: Text(
            result.message,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },

              child: const Text(
                "OK",
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  Future<void> _showBookingSuccessDialog({
    required String bookingId,
    required int quantity,
    required PaymentResult paymentResult,
  }) async {
    if (!mounted) return;

    await showDialog(
      context: context,

      barrierDismissible: false,

      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),

          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 30,
              ),

              SizedBox(width: 10),

              Expanded(
                child: Text(
                  "Booking Successful",
                ),
              ),
            ],
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                const Icon(
                  Icons.verified,
                  color: Colors.green,
                  size: 70,
                ),

                const SizedBox(height: 15),

                Text(
                  "Booking ID\n$bookingId",
                  textAlign:
                      TextAlign.center,

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Farmer Mobile : "
                  "$loggedInMobile",
                ),

                const SizedBox(height: 4),

                Text(
                  "Fertilizer : "
                  "${selectedFertilizer!["name"]}",
                ),

                const SizedBox(height: 4),

                Text(
                  "Quantity : $quantity bags",
                ),

                const SizedBox(height: 4),

                Text(
                  "Amount : "
                  "₹${totalPrice.toStringAsFixed(0)}",
                ),

                const SizedBox(height: 8),

                Text(
                  "Payment : "
                  "${paymentResult.method == PaymentMethod.cashOnDelivery ? "Cash on Delivery" : "Online Payment"}",
                  textAlign:
                      TextAlign.center,

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "Payment Status : "
                  "${_paymentStatusText(paymentResult.status)}",

                  style: TextStyle(
                    color:
                        paymentResult.status ==
                                PaymentStatus.paid
                            ? Colors.green
                            : Colors.orange,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                if (paymentResult.paymentId
                    .isNotEmpty)
                  Text(
                    "Payment ID : "
                    "${paymentResult.paymentId}",
                    textAlign:
                        TextAlign.center,

                    style:
                        const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                const SizedBox(height: 8),

                const Text(
                  "Status : Pending",
                  style:
                      TextStyle(
                    color: Colors.orange,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          actions: [
            ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.green,
                foregroundColor:
                    Colors.white,
              ),

              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        OrderStatusScreen(
                      bookingId:
                          bookingId,
                    ),
                  ),
                );
              },

              icon: const Icon(
                Icons.track_changes,
              ),

              label: const Text(
                "View Order Status",
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                clearForm();
              },

              child:
                  const Text("Done"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
    Color color,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  // ============================================================
  // CLEAR FORM
  // ============================================================

  void clearForm() {
    farmerNameController.clear();

    phoneController.text =
        loggedInMobile;

    villageController.clear();

    acresController.clear();

    quantityController.text = "1";

    setState(() {
      selectedFertilizer = null;

      selectedDate = null;

      selectedTime = null;

      bookingType = "Pickup";

      paymentMethod =
          "Cash on Delivery";

      currentPaymentStatus =
          "Pending";

      currentPaymentId = "";

      currentPaymentMessage = "";

      totalPrice = 0;
    });
  }
}