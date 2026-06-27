import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final int colorIndex;
  final String userId;
  final DateTime createdAt;
  final bool isPinned;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.colorIndex,
    required this.userId,
    required this.createdAt,
    this.isPinned = false,
  });

  factory Note.fromMap(Map<String, dynamic> data, String documentId) {
    final createdAtRaw = data['createdAt'];

    DateTime createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is DateTime) {
      createdAt = createdAtRaw;
    } else if (createdAtRaw is String) {
      createdAt =
          DateTime.tryParse(createdAtRaw) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    } else {
      createdAt = DateTime.fromMillisecondsSinceEpoch(0);
    }

    return Note(
      id: documentId,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      colorIndex: (data['colorIndex'] is int)
          ? data['colorIndex'] as int
          : int.tryParse('${data['colorIndex']}') ?? 0,
      userId: data['userId'] ?? '',
      createdAt: createdAt,
      isPinned: data['isPinned'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'colorIndex': colorIndex,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPinned': isPinned,
    };
  }
}
