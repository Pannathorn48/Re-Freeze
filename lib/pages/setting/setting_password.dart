import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/services/custom_theme.dart';
import 'package:mobile_project/components/input_feild.dart';

class SettingPassword extends StatefulWidget {
  const SettingPassword({super.key});

  @override
  State<SettingPassword> createState() => _SettingPassword();
}

class _SettingPassword extends State<SettingPassword> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    oldPasswordController.dispose();
    super.dispose();
  }

  // Function to update password with proper error handling
  Future<void> updatePassword() async {
    if (!formkey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user is currently signed in',
        );
      }

      // Get user credentials for reauthentication
      final credential = EmailAuthProvider.credential(
        email: user.email!, // Make sure user has an email
        password: oldPasswordController.text.trim(),
      );

      // Reauthenticate user before changing password
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(passwordController.text.trim());

      // Show success message
      if (mounted) {
        Navigator.pop(context); // Close the dialog or loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password updated successfully!',
              style: GoogleFonts.notoSansThai(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Clear fields after successful update
        passwordController.clear();
        confirmPasswordController.clear();
        oldPasswordController.clear();
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      String errorMessage;

      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Your current password is incorrect';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please log in again before changing your password';
          break;
        case 'weak-password':
          errorMessage = 'The new password is too weak';
          break;
        case 'user-not-found':
          errorMessage = 'User not found';
          break;
        default:
          errorMessage = 'Error: ${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: GoogleFonts.notoSansThai(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle other errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An unexpected error occurred: $e',
              style: GoogleFonts.notoSansThai(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 20),
          child: Text("Change Password",
              style: GoogleFonts.notoSansThai(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Form(
        key: formkey,
        child: Column(
          children: [
            const SizedBox(height: 50),
            // * New Password
            SizedBox(
              width: 325,
              child: InputFeild(
                label: 'New Password',
                controller: passwordController,
                obscureText: true,
                hintText: 'Enter new password',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ),

            // * Confirm New Password
            SizedBox(
              width: 325,
              child: InputFeild(
                label: 'Confirm New Password',
                controller: confirmPasswordController,
                obscureText: true,
                hintText: 'Confirm your new password',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ),

            // * Old Password
            SizedBox(
              width: 325,
              child: InputFeild(
                label: 'Old Password',
                controller: oldPasswordController,
                obscureText: true,
                hintText: 'Enter your current password',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
            ),

            // * Save Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Button(
                          text: 'Save',
                          width: 70,
                          height: 20,
                          fontColor: Colors.blue,
                          borderRadius: 25,
                          onPressed: updatePassword,
                        ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
