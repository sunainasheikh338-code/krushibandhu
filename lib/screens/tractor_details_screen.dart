import 'package:flutter/material.dart';

class TractorDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> tractor;

  const TractorDetailsScreen({
    super.key,
    required this.tractor,
  });

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String _value(
    String key, [
    String defaultValue = 'Not available',
  ]) {
    final value = tractor[key]?.toString().trim() ?? '';

    if (value.isEmpty) {
      return defaultValue;
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    final tractorName = _value(
      'tractorName',
      'Tractor',
    );

    final tractorType = _value('tractorType');

    final brand = _value('brand');

    final model = _value('model');

    final ownerName = _value(
      'ownerName',
      'Owner',
    );

    final mobile = _value('mobile');

    final village = _value('village');

    final description = _value(
      'description',
      'No additional description available.',
    );

    final imageUrl = _value(
      'imageUrl',
      '',
    );

    final pricePerHour = _toDouble(
      tractor['pricePerHour'],
    );

    final pricePerDay = _toDouble(
      tractor['pricePerDay'],
    );

    final labourAvailable =
        tractor['labourAvailable'] == true;

    final labourCharge = _toDouble(
      tractor['labourCharge'],
    );

    final isAvailable =
        tractor['isAvailable'] != false;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text(
          'Tractor Details',
        ),
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
            _buildImage(imageUrl),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: Text(
                    tractorName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                _availabilityChip(
                  isAvailable,
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              tractorType,
              style: TextStyle(
                fontSize: 16,
                color: Colors.green.shade700,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle(
              'Tractor Information',
              Icons.agriculture,
            ),

            const SizedBox(height: 12),

            _infoCard(
              children: [
                _infoRow(
                  Icons.business,
                  'Brand',
                  brand,
                ),
                const Divider(),
                _infoRow(
                  Icons.precision_manufacturing,
                  'Model',
                  model,
                ),
                const Divider(),
                _infoRow(
                  Icons.category,
                  'Tractor Type',
                  tractorType,
                ),
              ],
            ),

            const SizedBox(height: 22),

            _sectionTitle(
              'Rental Pricing',
              Icons.currency_rupee,
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _priceCard(
                    icon: Icons.access_time,
                    title: 'Per Hour',
                    price:
                        '₹${pricePerHour.toStringAsFixed(0)}',
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _priceCard(
                    icon:
                        Icons.calendar_today,
                    title: 'Per Day',
                    price:
                        '₹${pricePerDay.toStringAsFixed(0)}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            _sectionTitle(
              'Owner Details',
              Icons.person,
            ),

            const SizedBox(height: 12),

            _infoCard(
              children: [
                _infoRow(
                  Icons.person_outline,
                  'Owner',
                  ownerName,
                ),
                const Divider(),
                _infoRow(
                  Icons.phone,
                  'Mobile',
                  mobile,
                ),
                const Divider(),
                _infoRow(
                  Icons.location_on,
                  'Village',
                  village,
                ),
              ],
            ),

            const SizedBox(height: 22),

            _sectionTitle(
              'Labour Option',
              Icons.groups,
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: labourAvailable
                    ? Colors.blue.shade50
                    : Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: labourAvailable
                      ? Colors.blue.shade200
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.groups,
                    color: labourAvailable
                        ? Colors.blue
                        : Colors.grey,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          labourAvailable
                              ? 'Labour Available'
                              : 'Labour Not Available',
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        if (labourAvailable) ...[
                          const SizedBox(height: 4),
                          Text(
                            '₹${labourCharge.toStringAsFixed(0)} per day',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            _sectionTitle(
              'Description',
              Icons.description,
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isAvailable
                    ? () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Booking screen will be connected next.',
                            ),
                            backgroundColor:
                                Colors.green,
                          ),
                        );
                      }
                    : null,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                  foregroundColor:
                      Colors.white,
                  disabledBackgroundColor:
                      Colors.grey.shade300,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.calendar_month,
                ),
                label: Text(
                  isAvailable
                      ? 'Book This Tractor'
                      : 'Currently Unavailable',
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(
    String imageUrl,
  ) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(18),
      child: SizedBox(
        width: double.infinity,
        height: 230,
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) =>
                        _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.green.shade50,
      child: const Center(
        child: Icon(
          Icons.agriculture,
          size: 100,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _availabilityChip(
    bool available,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: available
            ? Colors.green.shade50
            : Colors.red.shade50,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        available
            ? 'Available'
            : 'Unavailable',
        style: TextStyle(
          color: available
              ? Colors.green.shade700
              : Colors.red.shade700,
          fontSize: 12,
          fontWeight: FontWeight.bold,
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
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _infoCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.green,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _priceCard({
    required IconData icon,
    required String title,
    required String price,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: Colors.green.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}