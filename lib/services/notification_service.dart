import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) async {
    final notificationRef = _firestore.collection('notifications').doc();

    await notificationRef.set({
      'notificationId': notificationRef.id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserNotifications(
    String userId,
  ) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  static Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }
}
