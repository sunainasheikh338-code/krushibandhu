import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TractorRentalScreen extends StatefulWidget {
  const TractorRentalScreen({super.key});

  @override
  State<TractorRentalScreen> createState() =>
      _TractorRentalScreenState();
}

class _TractorRentalScreenState
    extends State<TractorRentalScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = '';
  String _selectedType = 'All';

  final List<String> _tractorTypes = [
    'All',
    'Mini Tractor',
    '2WD Tractor',
    '4WD Tractor',
    'Power Tiller',
    'Other',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  bool _matchesSearch(
    Map<String, dynamic> tractor,
  ) {
    final search =
        _searchText.trim().toLowerCase();

    if (search.isEmpty) {
      return true;
    }

    final tractorName =
        tractor['tractorName']
                ?.toString()
                .toLowerCase() ??
            '';

    final tractorType =
        tractor['tractorType']
                ?.toString()
                .toLowerCase() ??
            '';

    final ownerName =
        tractor['ownerName']
                ?.toString()
                .toLowerCase() ??
            '';

    final village =
        tractor['village']
                ?.toString()
                .toLowerCase() ??
            '';

    final brand =
        tractor['brand']
                ?.toString()
                .toLowerCase() ??
            '';

    return tractorName.contains(search) ||
        tractorType.contains(search) ||
        ownerName.contains(search) ||
        village.contains(search) ||
        brand.contains(search);
  }

  bool _matchesType(
    Map<String, dynamic> tractor,
  ) {
    if (_selectedType == 'All') {
      return true;
    }

    return tractor['tractorType']?.toString() ==
        _selectedType;
  }

  void _showMessage(
    String message,
    Color color,
  ) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  void _showComingSoon(String title) {
    _showMessage(
      '$title will be available in the next step.',
      Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7F5),

      appBar: AppBar(
        title: const Text(
          'Tractor Rental',
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          _buildHeader(),

          _buildSearchBox(),

          _buildFilter(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('tractor_listings')
                  .orderBy(
                    'createdAt',
                    descending: true,
                  )
                  .snapshots(),

              builder: (
                context,
                snapshot,
              ) {
                if (snapshot.hasError) {
                  return _errorView(
                    snapshot.error.toString(),
                  );
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.green,
                    ),
                  );
                }

                final documents =
                    snapshot.data?.docs ?? [];

                final tractors =
                    documents.map((document) {
                  final data =
                      document.data()
                          as Map<String, dynamic>;

                  return {
                    ...data,
                    'documentId':
                        document.id,
                  };
                }).where((tractor) {
                  return _matchesSearch(tractor) &&
                      _matchesType(tractor);
                }).toList();

                if (tractors.isEmpty) {
                  return _emptyView();
                }

                return RefreshIndicator(
                  color: Colors.green,

                  onRefresh: () async {
                    setState(() {});
                    await Future.delayed(
                      const Duration(
                        milliseconds: 500,
                      ),
                    );
                  },

                  child: ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(
                      16,
                      10,
                      16,
                      30,
                    ),

                    itemCount:
                        tractors.length,

                    itemBuilder:
                        (context, index) {
                      return _tractorCard(
                        tractors[index],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        24,
      ),

      decoration: const BoxDecoration(
        color: Colors.green,

        borderRadius: BorderRadius.only(
          bottomLeft:
              Radius.circular(24),
          bottomRight:
              Radius.circular(24),
        ),
      ),

      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            'Rent a Tractor',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 7),

          Text(
            'Find tractors available near you and rent them for your farm work.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8,
      ),

      child: TextField(
        controller: _searchController,

        onChanged: (value) {
          setState(() {
            _searchText = value;
          });
        },

        decoration: InputDecoration(
          hintText:
              'Search tractor, brand, owner or village',

          prefixIcon: const Icon(
            Icons.search,
            color: Colors.green,
          ),

          suffixIcon:
              _searchText.isNotEmpty
                  ? IconButton(
                      icon:
                          const Icon(Icons.clear),

                      onPressed: () {
                        _searchController.clear();

                        setState(() {
                          _searchText = '';
                        });
                      },
                    )
                  : null,

          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide:
                const BorderSide(
              color: Colors.green,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilter() {
    return SizedBox(
      height: 52,

      child: ListView.separated(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
        ),

        scrollDirection:
            Axis.horizontal,

        itemCount:
            _tractorTypes.length,

        separatorBuilder:
            (_, __) =>
                const SizedBox(width: 8),

        itemBuilder:
            (context, index) {
          final type =
              _tractorTypes[index];

          final selected =
              _selectedType == type;

          return ChoiceChip(
            label: Text(type),

            selected: selected,

            selectedColor:
                Colors.green.shade100,

            backgroundColor:
                Colors.white,

            labelStyle: TextStyle(
              color: selected
                  ? Colors.green.shade800
                  : Colors.black87,

              fontWeight: selected
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),

            onSelected: (_) {
              setState(() {
                _selectedType = type;
              });
            },
          );
        },
      ),
    );
  }

  Widget _tractorCard(
    Map<String, dynamic> tractor,
  ) {
    final tractorName =
        tractor['tractorName']
                ?.toString() ??
            'Tractor';

    final tractorType =
        tractor['tractorType']
                ?.toString() ??
            'Tractor';

    final brand =
        tractor['brand']
                ?.toString() ??
            '';

    final ownerName =
        tractor['ownerName']
                ?.toString() ??
            'Owner';

    final village =
        tractor['village']
                ?.toString() ??
            'Location unavailable';

    final imageUrl =
        tractor['imageUrl']
                ?.toString() ??
            '';

    final pricePerHour =
        _toDouble(
      tractor['pricePerHour'],
    );

    final pricePerDay =
        _toDouble(
      tractor['pricePerDay'],
    );

    final labourAvailable =
        tractor['labourAvailable'] ==
            true;

    final isAvailable =
        tractor['isAvailable'] != false;

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 15,
      ),

      elevation: 2,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(14),

        child: Column(
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                _tractorImage(
                  imageUrl,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Expanded(
                            child: Text(
                              tractorName,
                              style:
                                  const TextStyle(
                                fontSize: 19,
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
                        style:
                            TextStyle(
                          color:
                              Colors.green.shade700,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      if (brand.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Brand: $brand',
                          style:
                              const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),

                      _infoRow(
                        Icons.person_outline,
                        ownerName,
                      ),

                      const SizedBox(height: 5),

                      _infoRow(
                        Icons.location_on_outlined,
                        village,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _priceBox(
                    icon:
                        Icons.access_time,
                    title: 'Per Hour',
                    price:
                        '₹${pricePerHour.toStringAsFixed(0)}',
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _priceBox(
                    icon:
                        Icons.calendar_today,
                    title: 'Per Day',
                    price:
                        '₹${pricePerDay.toStringAsFixed(0)}',
                  ),
                ),
              ],
            ),

            if (labourAvailable) ...[
              const SizedBox(height: 10),

              Container(
                width:
                    double.infinity,

                padding:
                    const EdgeInsets.all(9),

                decoration:
                    BoxDecoration(
                  color:
                      Colors.blue.shade50,
                  borderRadius:
                      BorderRadius.circular(9),
                ),

                child: const Row(
                  children: [
                    Icon(
                      Icons.groups,
                      size: 18,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'Labour available',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 48,

              child: ElevatedButton.icon(
                onPressed: isAvailable
                    ? () {
                        _showComingSoon(
                          'Tractor booking',
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
                        BorderRadius.circular(11),
                  ),
                ),

                icon: const Icon(
                  Icons.calendar_month,
                ),

                label: Text(
                  isAvailable
                      ? 'View & Book Tractor'
                      : 'Currently Unavailable',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tractorImage(
    String imageUrl,
  ) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(14),

      child: SizedBox(
        width: 105,
        height: 115,

        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,

                errorBuilder:
                    (_, __, ___) {
                  return _imagePlaceholder();
                },
              )
            : _imagePlaceholder(),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color:
          Colors.green.shade50,

      child: const Center(
        child: Icon(
          Icons.agriculture,
          size: 50,
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
        horizontal: 8,
        vertical: 5,
      ),

      decoration:
          BoxDecoration(
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
          fontSize: 10,

          fontWeight:
              FontWeight.bold,

          color: available
              ? Colors.green.shade700
              : Colors.red.shade700,
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey,
        ),

        const SizedBox(width: 5),

        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,

            style:
                const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _priceBox({
    required IconData icon,
    required String title,
    required String price,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(10),

      decoration:
          BoxDecoration(
        color:
            Colors.green.shade50,

        borderRadius:
            BorderRadius.circular(10),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.green,
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  price,
                  style:
                      const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyView() {
    final filtered =
        _searchText.isNotEmpty ||
            _selectedType != 'All';

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Icon(
              Icons.agriculture_outlined,
              size: 75,
              color:
                  Colors.green.shade300,
            ),

            const SizedBox(height: 15),

            Text(
              filtered
                  ? 'No matching tractors'
                  : 'No tractors available',
              style:
                  const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              filtered
                  ? 'Try another search or tractor type.'
                  : 'Tractor listings will appear here when owners add them.',
              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView(
    String error,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(25),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            const Icon(
              Icons.cloud_off,
              size: 60,
              color: Colors.red,
            ),

            const SizedBox(height: 15),

            const Text(
              'Unable to load tractors',
              style:
                  TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              error,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              child:
                  const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}