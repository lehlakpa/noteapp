import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'circular_loading.dart';
import '../services/firestore_service.dart';
import '../models/note_model.dart';
import '../widgets/custom_notification.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isSaving = false;

  int _selectedColorIndex = 0;

  final List<Color> _noteColors = [
    Colors.white,
    Colors.amber.shade300,
    Colors.teal.shade300,
    Colors.blue.shade300,
    Colors.purple.shade300,
    Colors.pink.shade300,
  ];

  void _saveNote() async {
    if (_titleController.text.trim().isEmpty &&
        _contentController.text.trim().isEmpty) {
      Navigator.pop(context);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final loading = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const CircularLoadingPage(
            delay: Duration(seconds: 1),
            message: 'Saving note...',
            autoSuccess: true,
          ),
        ),
      );

      if (loading == false) {
        if (!mounted) return;
        CustomNotification.show(
          context,
          message: 'Save cancelled',
          isError: true,
        );
        return;
      }

      final note = Note(
        id: '', // Firestore auto-generates ID
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        colorIndex: _selectedColorIndex,
        userId: user.uid,
        createdAt: DateTime.now(),
      );

      await _firestoreService.addNote(note);

      if (!mounted) return;
      CustomNotification.show(
        context,
        message: 'Note added successfully',
        isError: false,
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      CustomNotification.show(
        context,
        message: 'Failed to add note: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Matches Home background
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: _isSaving ? null : _saveNote,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Header Text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'New Note',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Note Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.05),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Note title...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 18,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Note Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _noteColors[_selectedColorIndex],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.05),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: 'Start writing your note...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Color Picker Row
            Padding(
              padding: const EdgeInsets.only(
                bottom: 30.0,
                left: 20.0,
                right: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_noteColors.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColorIndex = index;
                      });
                    },
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: _noteColors[index],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedColorIndex == index
                              ? Colors.blueAccent
                              : (_noteColors[index] == Colors.white
                                    ? Colors.grey.shade300
                                    : Colors.transparent),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _selectedColorIndex == index
                          ? Icon(
                              Icons.check,
                              color: _noteColors[index] == Colors.white
                                  ? Colors.blueAccent
                                  : Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
