import 'package:flutter/material.dart';
import '../models/user_details.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AddEditUserScreen extends StatefulWidget {
  final UserDetails? existingDetails;

  const AddEditUserScreen({super.key, this.existingDetails});

  @override
  State<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _numberController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final d = widget.existingDetails;
    _nameController = TextEditingController(text: d?.name ?? '');
    _numberController = TextEditingController(text: d?.number ?? '');
    _emailController = TextEditingController(text: d?.email ?? '');
    _addressController = TextEditingController(text: d?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    final details = UserDetails(
      id: widget.existingDetails?.id ?? '',
      name: _nameController.text.trim(),
      number: _numberController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      addedBy: currentUser.uid,
      createdAt: widget.existingDetails?.createdAt ?? DateTime.now(),
    );

    bool success;
    if (widget.existingDetails != null) {
      // Edit mode
      success = await FirestoreService.updateUserDetails(details);
    } else {
      // Add mode
      success = await FirestoreService.addUserDetails(details);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context); // Go back to Home Screen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.existingDetails != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Premium AMOLED dark slate
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? "Edit Details" : "Add Details",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form Header
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.badge_outlined,
                                size: 48,
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isEdit ? "Update Contact Card Information" : "Create a New Contact Card",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Form Fields
                      const Text(
                        "Full Name",
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration(
                          hintText: "Enter full name",
                          icon: Icons.person_outline_rounded,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Name is required";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "Phone Number",
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _numberController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration(
                          hintText: "Enter phone number",
                          icon: Icons.phone_outlined,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Phone number is required";
                          }
                          if (val.trim().length < 8) {
                            return "Please enter a valid phone number";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "Email Address",
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration(
                          hintText: "Enter email address",
                          icon: Icons.mail_outline_rounded,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Email is required";
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                            return "Please enter a valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "Address",
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration(
                          hintText: "Enter street address",
                          icon: Icons.location_city,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Address is required";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),

                      // Submit Button
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEAB308), Color(0xFFCA8A04)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _saveDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              isEdit ? "Save Changes" : "Create Card",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.white38, size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.03),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.amber, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }
}
