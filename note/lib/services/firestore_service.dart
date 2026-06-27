import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addNote(Note note) async {
    await _db.collection('notes').add(note.toMap());
  }

  Stream<List<Note>> getNotes(String userId) {
    return _db
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final notes = snapshot.docs
              .map((doc) => Note.fromMap(doc.data(), doc.id))
              .toList();
          // Sort by createdAt descending (avoids needing a composite Firestore index)
          notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return notes;
        });
  }

  Future<void> setPinned({
    required String noteId,
    required bool isPinned,
  }) async {
    await _db.collection('notes').doc(noteId).update({'isPinned': isPinned});
  }

  Future<void> deleteNote(String noteId) async {
    await _db.collection('notes').doc(noteId).delete();
  }

  Future<void> updateNote(Note note) async {
    await _db.collection('notes').doc(note.id).update({
      'title': note.title,
      'content': note.content,
      'colorIndex': note.colorIndex,
    });
  }
}
