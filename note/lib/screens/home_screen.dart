import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'add_note_screen.dart';
import 'circular_loading.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/note_model.dart';
import 'logout_profile_action.dart';
import '../widgets/custom_notification.dart';

enum _HomeCategory { all, recent, pinned, shared }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  _HomeCategory _selectedCategory = _HomeCategory.all;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName;
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName;
    }

    final email = user?.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'Profile';
  }

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.lightBackground, // Light bluish-white background
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                "assets/images/notelogo.png",
                height: 60,
                width: 60,
              ),
            ),
          ],
        ),
        actions: [LogoutProfileAction(authService: _authService)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 20),
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Categories
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip(
                      'All',
                      _selectedCategory == _HomeCategory.all,
                      _HomeCategory.all,
                    ),
                    _buildCategoryChip(
                      'Recent',
                      _selectedCategory == _HomeCategory.recent,
                      _HomeCategory.recent,
                    ),
                    _buildCategoryChip(
                      'Pinned',
                      _selectedCategory == _HomeCategory.pinned,
                      _HomeCategory.pinned,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Notes Grid
              Expanded(
                child: StreamBuilder<List<Note>>(
                  stream: FirebaseAuth.instance.currentUser != null
                      ? _firestoreService.getNotes(
                          FirebaseAuth.instance.currentUser!.uid,
                        )
                      : const Stream.empty(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularLoadingIndicator();
                    }
                    if (snapshot.hasError) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        CustomNotification.show(
                          context,
                          message: 'Failed to load notes: ${snapshot.error}',
                          isError: true,
                        );
                      });
                      return const Center(child: Text('Error loading notes'));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No notes yet. Create one!',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    }

                    final notes = snapshot.data!;

                    final filteredNotes = notes.where((note) {
                      // Category
                      if (_selectedCategory == _HomeCategory.pinned &&
                          !note.isPinned) {
                        return false;
                      }
                      if (_selectedCategory == _HomeCategory.recent) {
                        final now = DateTime.now();
                        final diff = now.difference(note.createdAt);
                        if (diff.inDays > 7) return false;
                      }

                      // Search
                      if (_searchQuery.isNotEmpty) {
                        final q = _searchQuery.toLowerCase();
                        final titleMatch = note.title.toLowerCase().contains(q);
                        final contentMatch = note.content
                            .toLowerCase()
                            .contains(q);
                        if (!titleMatch && !contentMatch) return false;
                      }

                      // Shared not implemented (no field in model)
                      if (_selectedCategory == _HomeCategory.shared) {
                        return false;
                      }

                      return true;
                    }).toList();

                    if (filteredNotes.isEmpty) {
                      return const Center(
                        child: Text(
                          'No matching notes',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    }

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = filteredNotes[index];

                        final List<Color> bgColors = [
                          Colors.white,
                          Colors.amber.shade100,
                          Colors.teal.shade100,
                          Colors.blue.shade100,
                          Colors.purple.shade100,
                          Colors.pink.shade100,
                        ];
                        final List<Color> iconColors = [
                          Colors.grey.shade400,
                          Colors.amber,
                          Colors.teal,
                          Colors.blue,
                          Colors.purple,
                          Colors.pink,
                        ];

                        final colorIndex = note.colorIndex.clamp(0, 5);
                        final timeString = DateFormat(
                          'dd MMM • HH:mm',
                        ).format(note.createdAt);

                        return GestureDetector(
                          onTap: () {
                            _showNoteDetailsDialog(
                              note: note,
                              index: index + 1,
                            );
                          },
                          onLongPress: () {
                            _showNoteOptions(
                              context: context,
                              note: note,
                              index: index + 1,
                            );
                          },
                          child: _buildNoteCard(
                            noteId: note.id,
                            title: note.title.isEmpty ? 'Untitled' : note.title,
                            content: note.content,
                            time: timeString,
                            iconData: Icons.note,
                            iconBgColor: bgColors[colorIndex],
                            iconColor: iconColors[colorIndex],
                            isPinned: note.isPinned,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoteScreen()),
          );
        },
        backgroundColor: AppColors.blue,
        elevation: 4,

        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }

  /// Shows a dialog with full note details and Edit / Delete.
  void _showNoteDetailsDialog({required Note note, required int index}) {
    final title = note.title.isEmpty ? 'Untitled' : note.title;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.darkSurface,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Note #$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: note.isPinned ? Colors.blueAccent : Colors.white54,
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  note.content.isEmpty ? 'No content' : note.content,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  'Created: ${DateFormat('dd MMM yyyy • HH:mm').format(note.createdAt)}',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _showEditDialog(note);
              },
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
              label: const Text(
                'Edit',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _confirmDelete(note, index);
              },
              icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
              label: const Text(
                'Delete',
                style: TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows a small toast-style popup with Edit / Delete for the held note.
  void _showNoteOptions({
    required BuildContext context,
    required Note note,
    required int index,
  }) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RenderBox? cardBox = context.findRenderObject() as RenderBox?;
    final Offset cardPosition =
        cardBox?.localToGlobal(Offset.zero, ancestor: overlay) ??
        const Offset(100, 300);
    final Size cardSize = cardBox?.size ?? const Size(160, 200);

    showMenu<String>(
      context: context,
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 12,
      position: RelativeRect.fromLTRB(
        cardPosition.dx,
        cardPosition.dy + cardSize.height * 0.4,
        cardPosition.dx + cardSize.width,
        cardPosition.dy + cardSize.height,
      ),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          height: 32,
          child: Text(
            'Note #$index',
            style: const TextStyle(
              color: AppColors.blue,
              fontSize: 11,

              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'edit',
          height: 44,
          child: Row(
            children: const [
              Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
              SizedBox(width: 10),
              Text(
                'Edit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          height: 44,
          child: Row(
            children: const [
              Icon(Icons.delete_outline, color: Color(0xFFFF6B6B), size: 18),
              SizedBox(width: 10),
              Text(
                'Delete',
                style: TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) async {
      if (!mounted) return;
      if (value == 'edit') {
        _showEditDialog(note);
      } else if (value == 'delete') {
        _confirmDelete(note, index);
      }
    });
  }

  /// Inline edit bottom sheet.
  void _showEditDialog(Note note) {
    final titleCtrl = TextEditingController(text: note.title);
    final contentCtrl = TextEditingController(text: note.content);
    int selectedColor = note.colorIndex;

    final List<Color> noteColors = [
      Colors.white,
      Colors.amber.shade300,
      Colors.teal.shade300,
      Colors.blue.shade300,
      Colors.purple.shade300,
      Colors.pink.shade300,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Edit Note',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title field
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Content field
                  TextField(
                    controller: contentCtrl,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Content',
                      hintStyle: TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Color picker
                  Row(
                    children: List.generate(noteColors.length, (i) {
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedColor = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(right: 10),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: noteColors[i],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColor == i
                                  ? Colors.blueAccent
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: selectedColor == i
                              ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color: noteColors[i] == Colors.white
                                      ? Colors.blueAccent
                                      : Colors.white,
                                )
                              : null,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final updated = Note(
                          id: note.id,
                          title: titleCtrl.text.trim(),
                          content: contentCtrl.text.trim(),
                          colorIndex: selectedColor,
                          userId: note.userId,
                          createdAt: note.createdAt,
                          isPinned: note.isPinned,
                        );
                        Navigator.pop(ctx);
                        try {
                          await _firestoreService.updateNote(updated);
                          if (!mounted) return;
                          CustomNotification.show(
                            context,
                            message: 'Note updated',
                            isError: false,
                          );
                        } catch (e) {
                          if (!mounted) return;
                          CustomNotification.show(
                            context,
                            message: 'Failed to update: $e',
                            isError: true,
                          );
                        }
                      },
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Confirm then delete a note.
  void _confirmDelete(Note note, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Note #$index?',
          style: const TextStyle(color: Colors.white, fontSize: 17),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _firestoreService.deleteNote(note.id);
                if (!mounted) return;
                CustomNotification.show(
                  context,
                  message: 'Note #$index deleted',
                  isError: false,
                );
              } catch (e) {
                if (!mounted) return;
                CustomNotification.show(
                  context,
                  message: 'Failed to delete: $e',
                  isError: true,
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Color(0xFFFF6B6B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    String label,
    bool isSelected,
    _HomeCategory value,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = value;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.blue : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard({
    required String noteId,
    required String title,
    required String content,
    required String time,
    required IconData iconData,
    required Color iconBgColor,
    required Color iconColor,
    required bool isPinned,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Note type icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
              // Tappable pin icon
              GestureDetector(
                onTap: () async {
                  try {
                    await _firestoreService.setPinned(
                      noteId: noteId,
                      isPinned: !isPinned,
                    );
                  } catch (e) {
                    if (mounted) {
                      CustomNotification.show(
                        context,
                        message: 'Could not update pin: $e',
                        isError: true,
                      );
                    }
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isPinned
                        ? AppColors.blue.withValues(alpha: 0.12)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 20,
                    color: isPinned ? AppColors.blue : Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primaryText,
            ),

            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
