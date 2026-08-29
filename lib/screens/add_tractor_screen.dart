import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddTractorScreen extends StatefulWidget {
  const AddTractorScreen({super.key});

  @override
  State<AddTractorScreen> createState() => _AddTractorScreenState();
}

class _AddTractorScreenState extends State<AddTractorScreen> {
  final _formKey = GlobalKey<FormState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _tractorNameController =
      TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _ownerNameController =
      TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _pricePerHourController =
      TextEditingController();
  final TextEditingController _pricePerDayController =
      TextEditingController();
  final TextEditingController _labourChargeController =
      TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();
  final TextEditingController _imageUrlController =
      TextEditingController();

  String _tractorType = '2WD Tractor';
  bool _labourAvailable = false;
  bool _isAvailable = true;
  bool _isSaving = false;

  final List<String> _tractorTypes = [
    'Mini Tractor',
    '2WD Tractor',
    '4WD Tractor',
    'Power Tiller',
    'Other',
  ];

  @override
  void dispose() {
    _tractorNameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _ownerNameController.dispose();
    _mobileController.dispose();
    _villageController.dispose();
    _pricePerHourController.dispose();
    _pricePerDayController.dispose();
    _labourChargeController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  double _toDouble(String value) {
    return double.tryParse(value.trim()) ?? 0;
  }

  Future<void> _addTractor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_labourAvailable &&
        _toDouble(_labourChargeController.text) <= 0) {
      _showMessage(
        'Please enter a valid labour charge.',
        Colors.red,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final document = _firestore.collection('tractor_listings').doc();

      final tractorData = <String, dynamic>{
        'tractorId': document.id,
        'tractorName': _tractorNameController.text.trim(),
        'brand': _brandController.text.trim(),
        'model': _modelController.text.trim(),
        'tractorType': _tractorType,

        'ownerId': '',
        'ownerName': _ownerNameController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'village': _villageController.text.trim(),

        'pricePerHour': _toDouble(
          _pricePerHourController.text,
        ),
        'pricePerDay': _toDouble(
          _pricePerDayController.text,
        ),

        'labourAvailable': _labourAvailable,
        'labourCharge': _labourAvailable
            ? _toDouble(_labourChargeController.text)
            : 0,

        'description': _descriptionController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),

        'isAvailable': _isAvailable,
        'totalBookings': 0,

        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await document.set(tractorData);

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'Failed to add tractor: $e',
        Colors.red,
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
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
              Text('Tractor Added'),
            ],
          ),
          content: const Text(
            'Your tractor has been successfully added to the Tractor Rental marketplace.',
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

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffixText,
      prefixIcon: Icon(
        icon,
        color: Colors.green,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.green,
          width: 2,
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.green,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool requiredField = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isSaving,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator ??
          (value) {
            if (requiredField &&
                (value == null || value.trim().isEmpty)) {
              return '$label is required';
            }
            return null;
          },
      decoration: _inputDecoration(
        label: label,
        icon: icon,
        hint: hint,
      ),
    );
  }

  Widget _priceField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isSaving,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      validator: (value) {
        final amount = double.tryParse(value?.trim() ?? '');

        if (amount == null || amount <= 0) {
          return 'Enter a valid amount';
        }

        return null;
      },
      decoration: _inputDecoration(
        label: label,
        icon: Icons.currency_rupee,
        suffixText: '₹',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('List Your Tractor'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(
                'Tractor Information',
                Icons.agriculture,
              ),
              const SizedBox(height: 14),

              _textField(
                controller: _tractorNameController,
                label: 'Tractor Name',
                icon: Icons.agriculture,
                hint: 'Example: Mahindra 575 DI',
              ),
              const SizedBox(height: 14),

              _textField(
                controller: _brandController,
                label: 'Brand',
                icon: Icons.business,
                hint: 'Example: Mahindra',
              ),
              const SizedBox(height: 14),

              _textField(
                controller: _modelController,
                label: 'Model',
                icon: Icons.precision_manufacturing,
                hint: 'Example: 575 DI',
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                value: _tractorType,
                decoration: _inputDecoration(
                  label: 'Tractor Type',
                  icon: Icons.category,
                ),
                items: _tractorTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value == null) return;

                        setState(() {
                          _tractorType = value;
                        });
                      },
              ),

              const SizedBox(height: 28),

              _sectionTitle(
                'Owner Details',
                Icons.person,
              ),
              const SizedBox(height: 14),

              _textField(
                controller: _ownerNameController,
                label: 'Owner Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 14),

              _textField(
                controller: _mobileController,
                label: 'Mobile Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  final mobile = value?.trim() ?? '';

                  if (!RegExp(r'^[0-9]{10}$')
                      .hasMatch(mobile)) {
                    return 'Enter a valid 10 digit mobile number';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),

              _textField(
                controller: _villageController,
                label: 'Village / Location',
                icon: Icons.location_on,
              ),

              const SizedBox(height: 28),

              _sectionTitle(
                'Rental Pricing',
                Icons.currency_rupee,
              ),
              const SizedBox(height: 14),

              _priceField(
                controller: _pricePerHourController,
                label: 'Price Per Hour',
              ),
              const SizedBox(height: 14),

              _priceField(
                controller: _pricePerDayController,
                label: 'Price Per Day',
              ),

              const SizedBox(height: 28),

              _sectionTitle(
                'Labour Option',
                Icons.groups,
              ),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Labour Available'),
                subtitle: const Text(
                  'Enable if labour can also be provided.',
                ),
                value: _labourAvailable,
                activeColor: Colors.green,
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _labourAvailable = value;
                        });
                      },
              ),

              if (_labourAvailable) ...[
                const SizedBox(height: 10),
                _priceField(
                  controller: _labourChargeController,
                  label: 'Labour Charge Per Day',
                ),
              ],

              const SizedBox(height: 28),

              _sectionTitle(
                'Additional Details',
                Icons.description,
              ),
              const SizedBox(height: 14),

              _textField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.notes,
                hint: 'Tractor condition or additional details',
                maxLines: 4,
                requiredField: false,
              ),
              const SizedBox(height: 14),

              _textField(
                controller: _imageUrlController,
                label: 'Image URL',
                icon: Icons.image,
                hint: 'Optional tractor image link',
                requiredField: false,
              ),

              const SizedBox(height: 20),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Available for Rental',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                value: _isAvailable,
                activeColor: Colors.green,
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _isAvailable = value;
                        });
                      },
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isSaving ? null : _addTractor,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.add_circle),
                  label: Text(
                    _isSaving
                        ? 'Adding Tractor...'
                        : 'Add Tractor',
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
}