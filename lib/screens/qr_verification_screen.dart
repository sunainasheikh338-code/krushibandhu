import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRVerificationScreen extends StatefulWidget {
  const QRVerificationScreen({super.key});

  @override
  State<QRVerificationScreen> createState() =>
      _QRVerificationScreenState();
}

class _QRVerificationScreenState extends State<QRVerificationScreen> {
  final MobileScannerController _scannerController =
      MobileScannerController();

  final ImagePicker _imagePicker = ImagePicker();

  bool _processing = false;
  String _qrResult = '';

  Map<String, dynamic>? _fertilizerData;

  // ============================================================
  // SCAN QR FROM CAMERA
  // ============================================================

  Future<void> _handleCameraScan(BarcodeCapture capture) async {
    if (_processing) return;

    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;

    final String? rawValue = barcode.rawValue;

    if (rawValue == null || rawValue.trim().isEmpty) {
      return;
    }

    await _processQRCode(rawValue);
  }

  // ============================================================
  // SCAN QR FROM GALLERY
  // ============================================================

  Future<void> _scanFromGallery() async {
    if (_processing) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) {
        return;
      }

      setState(() {
        _processing = true;
      });

      final BarcodeCapture? capture =
          await _scannerController.analyzeImage(image.path);

      if (!mounted) return;

      if (capture == null || capture.barcodes.isEmpty) {
        setState(() {
          _processing = false;
          _qrResult = '';
          _fertilizerData = null;
        });

        _showMessage(
          'No QR code found in this image.',
          Colors.orange,
        );

        return;
      }

      final barcode = capture.barcodes.first;

      final String? rawValue = barcode.rawValue;

      if (rawValue == null || rawValue.trim().isEmpty) {
        setState(() {
          _processing = false;
          _qrResult = '';
          _fertilizerData = null;
        });

        _showMessage(
          'QR code was detected, but it contains no readable data.',
          Colors.orange,
        );

        return;
      }

      await _processQRCode(rawValue);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _processing = false;
      });

      _showMessage(
        'Unable to scan the selected image.\n$e',
        Colors.red,
      );
    }
  }

  // ============================================================
  // PROCESS ANY QR CODE
  // ============================================================

  Future<void> _processQRCode(String rawValue) async {
    if (_processing) return;

    setState(() {
      _processing = true;
      _qrResult = rawValue.trim();
      _fertilizerData = null;
    });

    try {
      await _checkFertilizerDatabase(rawValue.trim());
    } catch (e) {
      debugPrint('QR verification error: $e');
    }

    if (!mounted) return;

    setState(() {
      _processing = false;
    });

    _showVerificationDialog();
  }

  // ============================================================
  // CHECK KRUSHIBANDHU FERTILIZER DATABASE
  // ============================================================

  Future<void> _checkFertilizerDatabase(String qrValue) async {
    final collection =
        FirebaseFirestore.instance.collection('fertilizer_products');

    // ------------------------------------------------------------
    // 1. DIRECT DOCUMENT ID CHECK
    //
    // Example:
    // QR = UREA001
    // Firestore document = fertilizer_products/UREA001
    // ------------------------------------------------------------

    final directDocument = await collection.doc(qrValue).get();

    if (directDocument.exists && directDocument.data() != null) {
      final data = directDocument.data()!;

      if (data['isValid'] == true) {
        _fertilizerData = data;
        return;
      }
    }

    // ------------------------------------------------------------
    // 2. PRODUCT ID CHECK
    //
    // This supports:
    // productId = UREA001
    // ------------------------------------------------------------

    final productQuery = await collection
        .where('productId', isEqualTo: qrValue)
        .limit(1)
        .get();

    if (productQuery.docs.isNotEmpty) {
      final data = productQuery.docs.first.data();

      if (data['isValid'] == true) {
        _fertilizerData = data;
        return;
      }
    }

    // ------------------------------------------------------------
    // 3. TRY JSON QR DATA
    //
    // Some fertilizer QR codes may contain:
    //
    // {"productId":"UREA001"}
    //
    // ------------------------------------------------------------

    try {
      final decoded = jsonDecode(qrValue);

      if (decoded is Map<String, dynamic>) {
        final possibleProductId =
            decoded['productId']?.toString();

        if (possibleProductId != null &&
            possibleProductId.isNotEmpty) {
          final jsonQuery = await collection
              .where(
                'productId',
                isEqualTo: possibleProductId,
              )
              .limit(1)
              .get();

          if (jsonQuery.docs.isNotEmpty) {
            final data = jsonQuery.docs.first.data();

            if (data['isValid'] == true) {
              _fertilizerData = data;
              return;
            }
          }
        }
      }
    } catch (_) {
      // QR isn't JSON.
      // That's completely fine.
    }

    // ------------------------------------------------------------
    // IMPORTANT:
    //
    // We DO NOT mark outside QR codes as invalid.
    //
    // _fertilizerData remains null.
    // The screen will show:
    // "External / Unregistered QR"
    // ------------------------------------------------------------
  }

  // ============================================================
  // VERIFICATION DIALOG
  // ============================================================

  void _showVerificationDialog() {
    if (!mounted) return;

    final bool registered = _fertilizerData != null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                registered
                    ? Icons.verified
                    : Icons.qr_code_2,
                color: registered
                    ? Colors.green
                    : Colors.blue,
                size: 32,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  registered
                      ? 'Fertilizer Verified'
                      : 'QR Code Detected',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: registered
                ? _registeredFertilizerContent()
                : _externalQRCodeContent(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  _qrResult = '';
                  _fertilizerData = null;
                });
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan Again'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // REGISTERED FERTILIZER CONTENT
  // ============================================================

  Widget _registeredFertilizerContent() {
    final data = _fertilizerData!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 28,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Registered in KrushiBandhu',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _detailRow(
          'Product',
          _getValue(
            data,
            'productName',
            fallbackKey: 'productname',
          ),
        ),

        _detailRow(
          'Product ID',
          _getValue(
            data,
            'productId',
            fallbackKey: 'productID',
          ),
        ),

        _detailRow(
          'Company',
          _getValue(data, 'company'),
        ),

        _detailRow(
          'Batch Number',
          _getValue(data, 'batchNumber'),
        ),

        _detailRow(
          'Quantity',
          _getValue(data, 'quantity'),
        ),

        _detailRow(
          'Manufacturing Date',
          _getValue(data, 'manufacturingDate'),
        ),

        _detailRow(
          'Expiry Date',
          _getValue(data, 'expiryDate'),
        ),

        const SizedBox(height: 12),

        _qrDataBox(),
      ],
    );
  }

  // ============================================================
  // EXTERNAL QR CONTENT
  // ============================================================

  Widget _externalQRCodeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: 28,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'This QR code is readable, but it is not registered in KrushiBandhu.',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'QR Data',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 8),

        _qrDataBox(),

        const SizedBox(height: 14),

        const Text(
          'Note: A readable QR code does not by itself prove that a fertilizer product is genuine. Authenticity should be confirmed through the manufacturer or an authorized verification service.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QR DATA BOX
  // ============================================================

  Widget _qrDataBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: SelectableText(
        _qrResult,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAFE FIRESTORE VALUE
  // ============================================================

  String _getValue(
    Map<String, dynamic> data,
    String key, {
    String? fallbackKey,
  }) {
    final value = data[key];

    if (value != null &&
        value.toString().trim().isNotEmpty) {
      return value.toString();
    }

    if (fallbackKey != null) {
      final fallbackValue = data[fallbackKey];

      if (fallbackValue != null &&
          fallbackValue.toString().trim().isNotEmpty) {
        return fallbackValue.toString();
      }
    }

    return '-';
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
    Color color,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // RESET SCANNER
  // ============================================================

  void _resetScanner() {
    setState(() {
      _processing = false;
      _qrResult = '';
      _fertilizerData = null;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR Fertilizer Verification',
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Flash',
            icon: const Icon(
              Icons.flash_on,
            ),
            onPressed: () {
              _scannerController.toggleTorch();
            },
          ),
          IconButton(
            tooltip: 'Switch Camera',
            icon: const Icon(
              Icons.flip_camera_android,
            ),
            onPressed: () {
              _scannerController.switchCamera();
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // ======================================================
          // CAMERA SCANNER
          // ======================================================

          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _handleCameraScan,
                ),

                // Scanner border
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ),
                ),

                // Instructions
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Container(
                    padding:
                        const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black
                          .withOpacity(0.65),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Place any fertilizer QR code inside the frame',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                if (_processing)
                  Container(
                    color: Colors.black
                        .withOpacity(0.45),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ======================================================
          // BOTTOM SECTION
          // ======================================================

          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    size: 42,
                    color: Colors.green,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _qrResult.isEmpty
                        ? 'Scan a fertilizer QR code'
                        : 'QR code detected',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // GALLERY BUTTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green,
                        foregroundColor:
                            Colors.white,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),
                      onPressed:
                          _processing
                              ? null
                              : _scanFromGallery,
                      icon: const Icon(
                        Icons.photo_library,
                      ),
                      label: const Text(
                        'Scan QR from Gallery',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (_qrResult.isNotEmpty)
                    TextButton.icon(
                      onPressed: _resetScanner,
                      icon: const Icon(
                        Icons.refresh,
                      ),
                      label: const Text(
                        'Clear Result',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
}