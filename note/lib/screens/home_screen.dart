import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'add_note_screen.dart';
import 'circular_loading.dart';
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
      backgroundColor: const Color(0xFFF8F9FE), // Light bluish-white background
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.note_alt, color: Colors.white, size: 24),
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
                'My Notes',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
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
                // child: TextField(
                //   controller: _searchController,
                //   decoration: InputDecoration(
                //     hintText: 'Search notes...',
                //     hintStyle: TextStyle(color: Colors.grey.shade500),
                //     prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                //     border: InputBorder.none,
                //     contentPadding: const EdgeInsets.symmetric(vertical: 15),
                //   ),
                // ),
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
                    _buildCategoryChip(
                      'Shared',
                      _selectedCategory == _HomeCategory.shared,
                      _HomeCategory.shared,
                    ),

                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Icon(
                        Icons.tune,
                        size: 20,
                        color: Colors.black54,
                      ),
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

                        return _buildNoteCard(
                          noteId: note.id,
                          title: note.title.isEmpty ? 'Untitled' : note.title,
                          content: note.content,
                          time: timeString,
                          iconData: Icons.note,
                          iconBgColor: bgColors[colorIndex],
                          iconColor: iconColors[colorIndex],
                          isPinned: note.isPinned,
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
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
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
                        ? Colors.blueAccent.withValues(alpha: 0.12)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 20,
                    color: isPinned
                        ? Colors.blueAccent
                        : Colors.grey.shade400,
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
              color: Color(0xFF0F172A),
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
