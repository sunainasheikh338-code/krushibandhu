import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const NotificationsScreen({super.key, required this.user});

  String _getUserId() {
    return user['id']?.toString() ?? user['userId']?.toString() ?? '';
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return '';
    }

    final date = timestamp.toDate();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final userId = _getUserId();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: userId.isEmpty
          ? const Center(child: Text('User information not found'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: NotificationService.getUserNotifications(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Unable to load notifications.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final documents = snapshot.data?.docs ?? [];

                if (documents.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 70,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final sortedDocuments = [...documents];

                sortedDocuments.sort((a, b) {
                  final aTime = a.data()['createdAt'] as Timestamp?;
                  final bTime = b.data()['createdAt'] as Timestamp?;

                  if (aTime == null && bTime == null) {
                    return 0;
                  }

                  if (aTime == null) {
                    return 1;
                  }

                  if (bTime == null) {
                    return -1;
                  }

                  return bTime.compareTo(aTime);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: sortedDocuments.length,
                  itemBuilder: (context, index) {
                    final document = sortedDocuments[index];
                    final data = document.data();

                    final title = data['title']?.toString() ?? 'Notification';

                    final message = data['message']?.toString() ?? '';

                    final type = data['type']?.toString() ?? 'general';

                    final isRead = data['isRead'] == true;

                    final timestamp = data['createdAt'] as Timestamp?;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: isRead
                              ? Colors.grey.shade200
                              : Colors.green.shade100,
                          child: Icon(
                            type == 'booking'
                                ? Icons.receipt_long
                                : Icons.notifications,
                            color: isRead ? Colors.grey : Colors.green,
                          ),
                        ),
                        title: Text(
                          title,
                          style: TextStyle(
                            fontWeight: isRead
                                ? FontWeight.w500
                                : FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(message),
                              if (timestamp != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  _formatDate(timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        trailing: isRead
                            ? null
                            : const Icon(
                                Icons.circle,
                                size: 10,
                                color: Colors.green,
                              ),
                        onTap: () async {
                          if (!isRead) {
                            await NotificationService.markAsRead(document.id);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
