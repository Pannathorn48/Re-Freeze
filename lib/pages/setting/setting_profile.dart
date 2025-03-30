import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/api/user_api.dart';
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/components/input_feild.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingProfile extends StatefulWidget {
  const SettingProfile({super.key});
  @override
  State<SettingProfile> createState() => _SettingProfileState();
}

class _SettingProfileState extends State<SettingProfile> {
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final UserApi _userApi = UserApi();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _userApi.getUser(_auth.currentUser?.uid);
      if (user != null) {
        nameController.text = user.displayName!;
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load user data');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateDisplayName() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String uid = _auth.currentUser!.uid;

      // Update display name
      if (nameController.text.isNotEmpty) {
        await _userApi.updateDisplayName(uid, nameController.text);
        _showSuccessSnackBar('Display name updated successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update display name');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          message,
          style: GoogleFonts.notoSansThai(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          message,
          style: GoogleFonts.notoSansThai(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: Text(
          "Profile Settings",
          style: GoogleFonts.notoSansThai(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 25.0, vertical: 20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Display Name Input
                      Text(
                        "Change Display Name",
                        style: GoogleFonts.notoSansThai(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      InputFeild(
                        label: 'New Display Name',
                        controller: nameController,
                        obscureText: false,
                        hintText: 'Enter your display name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a display name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 40),

                      // Save Button - Centered
                      Center(
                        child: Button(
                          text: 'Save Changes',
                          width: 200,
                          height: 50,
                          fontColor: Colors.white,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          borderRadius: 10,
                          onPressed: _updateDisplayName,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
