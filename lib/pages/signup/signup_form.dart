import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/components/icon_dialog.dart';
import 'package:mobile_project/components/input_feild.dart';
import 'package:mobile_project/api/user_controller.dart';
import 'package:mobile_project/models/user.dart';
import 'package:mobile_project/services/custom_theme.dart';
import 'package:mobile_project/services/login_service.dart';
import 'package:mobile_project/services/validator_service.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final UserController _userDatabase = UserController();
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            InputFeild(
              label: "Email",
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              hintText: "Enter your email",
              validator: Validator.validateEmail,
            ),
            const SizedBox(
              height: 15,
            ),
            InputFeild(
              label: "Password",
              controller: passwordController,
              hintText: "Enter your password",
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'please enter your password';
                }
                if (value.length < 6) {
                  return 'password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 15,
            ),
            InputFeild(
              label: "Confirm Password",
              controller: confirmPasswordController,
              hintText: "Enter your password",
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'please enter your password';
                }
                if (value != passwordController.text) {
                  return 'password does not match';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 30,
            ),
            Button(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final email = emailController.text;
                  final password = passwordController.text;
                  try {
                    final userCred = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: email, password: password);
                    if (userCred.user?.uid != null) {
                      PlatformUser? currentUser =
                          await _userDatabase.getUser(userCred.user!.uid);
                      if (currentUser?.displayName == null) {
                        Navigator.pushNamed(context, "/signup/display-name");
                      } else {
                        if (mounted) {
                          Navigator.pushNamed(context, '/home');
                        }
                      }
                    }
                  } on FirebaseAuthException catch (error) {
                    showDialog(
                        context: context,
                        builder: (context) => IconDialog(
                              icon: const Icon(Icons.error),
                              title: "Failed to sign up",
                              titleColor: CustomColors.error,
                              content: error.message!,
                              actionText: "Try again",
                              actionColor: CustomColors.error,
                            ));
                  }
                }
              },
              text: "Next",
              width: 385,
              height: 40,
              fontColor: Colors.white,
              backgroundColor: Theme.of(context).colorScheme.primary,
              overlayColor: Colors.white,
              borderColor: Colors.black,
            ),
            const SizedBox(
              height: 25,
            ),
            Text(
              "or",
              style: GoogleFonts.notoSansThai(fontSize: 16),
            ),
            const SizedBox(
              height: 25,
            ),
            Button(
              onPressed: () async {
                try {
                  await GoogleAuth.signInWithGoogle();
                } catch (error) {
                  showDialog(
                      context: context,
                      builder: (context) => const IconDialog(
                            icon: Icon(Icons.error),
                            title: "Failed to sign up",
                            titleColor: CustomColors.error,
                            content: "something went wrong , please try again",
                            actionText: "Try again",
                            actionColor: CustomColors.error,
                          ));
                }
              },
              text: "Sign up with Google",
              icon: SvgPicture.asset("assets/icons/google.svg"),
              width: 385,
              height: 40,
              fontColor: Colors.black54,
              borderColor: Colors.black,
            )
          ],
        ));
  }
}
