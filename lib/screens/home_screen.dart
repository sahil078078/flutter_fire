import 'package:flutter/material.dart';
import '../models/user_details.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'add_edit_user_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showDeleteConfirmation(BuildContext context, String docId, String name) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.redAccent.withOpacity(0.2), width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              const SizedBox(width: 10),
              const Text("Delete Contact", style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(
            "Are you sure you want to delete the details for $name? This action cannot be undone.",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await FirestoreService.deleteUserDetails(docId);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final String displayName = user?.displayName ?? 'User';
    final String email = user?.email ?? 'No email';
    final String? photoUrl = user?.photoURL;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Premium AMOLED dark slate
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            // Elegant Mini User Profile Avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF1E293B),
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, $displayName",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white54,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.amber),
            tooltip: 'Sign Out',
            onPressed: () async {
              await AuthService.signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Screen Section Title
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "My Contacts Directory",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Firestore Realtime stream of user details
              Expanded(
                child: StreamBuilder<List<UserDetails>>(
                  stream: FirestoreService.getUserDetailsStream(user?.uid ?? ''),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error loading data: ${snapshot.error}",
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      );
                    }

                    final list = snapshot.data ?? [];

                    if (list.isEmpty) {
                      // Beautiful customized empty state
                      return Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.04),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.contact_phone_outlined,
                                  size: 70,
                                  color: Colors.amber.withOpacity(0.4),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "No Contacts Saved",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                                child: Text(
                                  "Tap the glowing plus button below to add your first user card details to Firebase Firestore.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Contact cards list view
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: list.length,
                      padding: const EdgeInsets.only(bottom: 90),
                      itemBuilder: (context, index) {
                        final details = list[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.06),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Info Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      details.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Phone Number
                                    _buildInfoRow(Icons.phone_rounded, details.number),
                                    const SizedBox(height: 4),

                                    // Email
                                    _buildInfoRow(Icons.mail_outline_rounded, details.email),
                                    const SizedBox(height: 4),

                                    // Address
                                    _buildInfoRow(Icons.location_on_outlined, details.address),
                                  ],
                                ),
                              ),

                              // Actions Column (Edit & Delete)
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit_rounded, color: Colors.blue[300], size: 20),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddEditUserScreen(existingDetails: details),
                                        ),
                                      );
                                    },
                                    tooltip: 'Edit Card',
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline_rounded, color: Colors.red[300], size: 20),
                                    onPressed: () {
                                      _showDeleteConfirmation(context, details.id, details.name);
                                    },
                                    tooltip: 'Delete Card',
                                  ),
                                ],
                              ),
                            ],
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

      // Premium glowing Floating Action Button
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            )
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddEditUserScreen(),
              ),
            );
          },
          backgroundColor: Colors.amber,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.black,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.amber.withOpacity(0.7), size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
