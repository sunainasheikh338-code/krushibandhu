import 'package:cloud_firestore/cloud_firestore.dart';

class TractorRentalService {
  TractorRentalService._();

  static final TractorRentalService instance =
      TractorRentalService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
      get _tractorListings =>
          _firestore.collection(
            'tractor_listings',
          );

  CollectionReference<Map<String, dynamic>>
      get _tractorBookings =>
          _firestore.collection(
            'tractor_bookings',
          );

  // ============================================================
  // ADD TRACTOR LISTING
  // ============================================================

  Future<String> addTractor(
    Map<String, dynamic> tractorData,
  ) async {
    final document =
        _tractorListings.doc();

    final data =
        Map<String, dynamic>.from(
      tractorData,
    );

    data['documentId'] =
        document.id;

    data['tractorId'] =
        data['tractorId'] ??
            document.id;

    data['status'] =
        data['status'] ??
            'Available';

    data['isAvailable'] =
        data['isAvailable'] ??
            true;

    data['totalBookings'] =
        data['totalBookings'] ??
            0;

    data['createdAt'] =
        FieldValue.serverTimestamp();

    data['updatedAt'] =
        FieldValue.serverTimestamp();

    await document.set(data);

    return document.id;
  }

  // ============================================================
  // GET ALL TRACTORS
  // ============================================================

  Stream<List<Map<String, dynamic>>>
      getAllTractors() {
    return _tractorListings
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        final data = document.data();

        data['documentId'] =
            document.id;

        return data;
      }).toList();
    });
  }

  // ============================================================
  // GET AVAILABLE TRACTORS
  // ============================================================

  Stream<List<Map<String, dynamic>>>
      getAvailableTractors() {
    return _tractorListings
        .where(
          'isAvailable',
          isEqualTo: true,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        final data = document.data();

        data['documentId'] =
            document.id;

        return data;
      }).toList();
    });
  }

  // ============================================================
  // GET OWNER TRACTORS
  // ============================================================

  Stream<List<Map<String, dynamic>>>
      getOwnerTractors(
    String ownerId,
  ) {
    return _tractorListings
        .where(
          'ownerId',
          isEqualTo: ownerId,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        final data = document.data();

        data['documentId'] =
            document.id;

        return data;
      }).toList();
    });
  }

  // ============================================================
  // GET SINGLE TRACTOR
  // ============================================================

  Future<Map<String, dynamic>?>
      getTractor(
    String tractorId,
  ) async {
    final document =
        await _tractorListings
            .doc(tractorId)
            .get();

    if (!document.exists) {
      return null;
    }

    final data =
        document.data();

    if (data == null) {
      return null;
    }

    data['documentId'] =
        document.id;

    return data;
  }

  // ============================================================
  // UPDATE TRACTOR
  // ============================================================

  Future<void> updateTractor(
    String tractorId,
    Map<String, dynamic> tractorData,
  ) async {
    final data =
        Map<String, dynamic>.from(
      tractorData,
    );

    data.remove('documentId');

    data['updatedAt'] =
        FieldValue.serverTimestamp();

    await _tractorListings
        .doc(tractorId)
        .update(data);
  }

  // ============================================================
  // DELETE TRACTOR
  // ============================================================

  Future<void> deleteTractor(
    String tractorId,
  ) async {
    await _tractorListings
        .doc(tractorId)
        .delete();
  }

  // ============================================================
  // CHANGE TRACTOR AVAILABILITY
  // ============================================================

  Future<void> updateTractorAvailability(
    String tractorId,
    bool isAvailable,
  ) async {
    await _tractorListings
        .doc(tractorId)
        .update({
      'isAvailable': isAvailable,

      'status': isAvailable
          ? 'Available'
          : 'Unavailable',

      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // CREATE BOOKING
  // ============================================================

  Future<String> createBooking(
    Map<String, dynamic> bookingData,
  ) async {
    final document =
        _tractorBookings.doc();

    final data =
        Map<String, dynamic>.from(
      bookingData,
    );

    data['documentId'] =
        document.id;

    data['bookingId'] =
        data['bookingId'] ??
            document.id;

    data['status'] =
        data['status'] ??
            'Pending';

    data['createdAt'] =
        FieldValue.serverTimestamp();

    data['updatedAt'] =
        FieldValue.serverTimestamp();

    await document.set(data);

    return document.id;
  }

  // ============================================================
  // GET ALL BOOKINGS
  // ============================================================

  Stream<List<Map<String, dynamic>>>
      getAllBookings() {
    return _tractorBookings
        .snapshots()
        .map((snapshot) {
      final bookings =
          snapshot.docs.map((document) {
        final data = document.data();

        data['documentId'] =
            document.id;

        return data;
      }).toList();

      bookings.sort(
        (a, b) {
          final aTime =
              a['createdAt'];

          final bTime =
              b['createdAt'];

          if (aTime is Timestamp &&
              bTime is Timestamp) {
            return bTime.compareTo(
              aTime,
            );
          }

          return 0;
        },
      );

      return bookings;
    });
  }

  // ============================================================
  // GET FARMER BOOKINGS
  // ============================================================

  Stream<List<Map<String, dynamic>>>
      getFarmerBookings(
    String farmerId,
  ) {
    return _tractorBookings
        .where(
          'farmerId',
          isEqualTo: farmerId,
        )
        .snapshots()
        .map((snapshot) {
      final bookings =
          snapshot.docs.map((document) {
        final data = document.data();

        data['documentId'] =
            document.id;

        return data;
      }).toList();

      bookings.sort(
        (a, b) {
          final aTime =
              a['bookingDateTime'];

          final bTime =
              b['bookingDateTime'];

          if (aTime is Timestamp &&
              bTime is Timestamp) {
            return bTime.compareTo(
              aTime,
            );
          }

          return 0;
        },
      );

      return bookings;
    });
  }

  // ============================================================
  // GET OWNER BOOKINGS
  // ============================================================

  Stream<List<Map<String, dynamic>>>
      getOwnerBookings(
    String ownerId,
  ) {
    return _tractorBookings
        .where(
          'ownerId',
          isEqualTo: ownerId,
        )
        .snapshots()
        .map((snapshot) {
      final bookings =
          snapshot.docs.map((document) {
        final data = document.data();

        data['documentId'] =
            document.id;

        return data;
      }).toList();

      bookings.sort(
        (a, b) {
          final aTime =
              a['bookingDateTime'];

          final bTime =
              b['bookingDateTime'];

          if (aTime is Timestamp &&
              bTime is Timestamp) {
            return bTime.compareTo(
              aTime,
            );
          }

          return 0;
        },
      );

      return bookings;
    });
  }

  // ============================================================
  // GET TRACTOR BOOKINGS
  // ============================================================

  Stream<List<Map<String, dynamic>>>
      getTractorBookings(
    String tractorId,
  ) {
    return _tractorBookings
        .where(
          'tractorId',
          isEqualTo: tractorId,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        final data = document.data();

        data['documentId'] =
            document.id;

        return data;
      }).toList();
    });
  }

  // ============================================================
  // GET SINGLE BOOKING
  // ============================================================

  Future<Map<String, dynamic>?>
      getBooking(
    String bookingId,
  ) async {
    final document =
        await _tractorBookings
            .doc(bookingId)
            .get();

    if (!document.exists) {
      return null;
    }

    final data =
        document.data();

    if (data == null) {
      return null;
    }

    data['documentId'] =
        document.id;

    return data;
  }

  // ============================================================
  // UPDATE BOOKING STATUS
  // ============================================================

  Future<void> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    final updateData =
        <String, dynamic>{
      'status': status,

      'updatedAt':
          FieldValue.serverTimestamp(),
    };

    if (status.toLowerCase() ==
        'confirmed') {
      updateData['confirmedAt'] =
          FieldValue.serverTimestamp();
    }

    if (status.toLowerCase() ==
        'completed') {
      updateData['completedAt'] =
          FieldValue.serverTimestamp();
    }

    if (status.toLowerCase() ==
        'cancelled') {
      updateData['cancelledAt'] =
          FieldValue.serverTimestamp();
    }

    await _tractorBookings
        .doc(bookingId)
        .update(updateData);
  }

  // ============================================================
  // CANCEL BOOKING
  // ============================================================

  Future<void> cancelBooking(
    String bookingId, {
    String cancelledBy = 'Farmer',
  }) async {
    await _tractorBookings
        .doc(bookingId)
        .update({
      'status': 'Cancelled',

      'cancelledBy': cancelledBy,

      'cancelledAt':
          FieldValue.serverTimestamp(),

      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // UPDATE PAYMENT STATUS
  // ============================================================

  Future<void> updatePaymentStatus(
    String bookingId, {
    required String paymentStatus,
    String? paymentId,
    String? paymentMessage,
  }) async {
    final data =
        <String, dynamic>{
      'paymentStatus':
          paymentStatus,

      'updatedAt':
          FieldValue.serverTimestamp(),
    };

    if (paymentId != null) {
      data['paymentId'] =
          paymentId;
    }

    if (paymentMessage != null) {
      data['paymentMessage'] =
          paymentMessage;
    }

    await _tractorBookings
        .doc(bookingId)
        .update(data);
  }

  // ============================================================
  // INCREMENT TRACTOR BOOKING COUNT
  // ============================================================

  Future<void> incrementBookingCount(
    String tractorId,
  ) async {
    await _tractorListings
        .doc(tractorId)
        .update({
      'totalBookings':
          FieldValue.increment(1),

      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // DECREMENT TRACTOR BOOKING COUNT
  // ============================================================

  Future<void> decrementBookingCount(
    String tractorId,
  ) async {
    await _firestore.runTransaction(
      (transaction) async {
        final reference =
            _tractorListings.doc(
          tractorId,
        );

        final snapshot =
            await transaction.get(
          reference,
        );

        if (!snapshot.exists) {
          return;
        }

        final currentValue =
            snapshot.data()?[
                    'totalBookings']
                as num? ??
                0;

        final newValue =
            currentValue > 0
                ? currentValue - 1
                : 0;

        transaction.update(
          reference,
          {
            'totalBookings': newValue,
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }
}