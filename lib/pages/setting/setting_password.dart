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

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    oldPasswordController.dispose();
    super.dispose();
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
                  if ((value?.length ?? 0) < 6) {
                    return 'password must be at least 6 characters';
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
                  if ((value?.length ?? 0) < 1) {
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
                  child: Button(
                    text: 'Save',
                    width: 70,
                    height: 20,
                    fontColor: Colors.blue,
                    borderRadius: 25,
                    onPressed: () {
                      if (formkey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('New Password Saved!',
                              style: GoogleFonts.notoSansThai(
                                color: Colors.white,
                              )),
                        ));
                      }
                    },
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
