import 'package:call_log/call_log.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class CallLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sync({required String userId}) async {
    if (userId.isEmpty) {
      throw Exception('User ID is missing');
    }

    final permission = await Permission.phone.request();

    if (!permission.isGranted) {
      throw Exception('Permission denied');
    }

    final DateTime now = DateTime.now();
    final DateTime threeDaysAgo = now.subtract(const Duration(days: 3));

    final Iterable<CallLogEntry> entries = await CallLog.query(
      dateFrom: threeDaysAgo.millisecondsSinceEpoch,
      dateTo: now.millisecondsSinceEpoch,
    );

    final callsCollection = _firestore
        .collection('users')
        .doc(userId)
        .collection('dummy');

    for (final call in entries) {
      final timestamp = call.timestamp;

      if (timestamp == null) {
        continue;
      }

      final callId = '${call.number}_${timestamp}_${call.duration ?? 0}';

      String type;

      switch (call.callType) {
        case CallType.incoming:
          type = 'IN';
          break;

        case CallType.outgoing:
          type = 'OUT';
          break;

        case CallType.missed:
          type = 'MIS';
          break;

        case CallType.rejected:
          type = 'REJ';
          break;

        case CallType.blocked:
          type = 'BLO';
          break;

        default:
          type = 'UN';
      }

      await callsCollection.doc(callId).set({
        'userId': userId,
        'type': type,
        'number': call.number,
        'name': call.name,
        'time': Timestamp.fromMillisecondsSinceEpoch(timestamp),
        'duration': call.duration ?? 0,
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}
