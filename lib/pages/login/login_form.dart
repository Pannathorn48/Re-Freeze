import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/components/icon_dialog.dart';
import 'package:mobile_project/components/input_feild.dart';
import 'package:mobile_project/services/validator.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isVisible = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
              obscureText: !_isVisible,
              suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isVisible = !_isVisible;
                    });
                  },
                  icon: Icon(
                      !_isVisible ? Icons.visibility : Icons.visibility_off)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'please enter your password';
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
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text);
                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      Navigator.pushNamed(context, '/home');
                    }
                  } on FirebaseAuthException catch (e) {
                    switch (e.code) {
                      case 'invalid-email':
                      case 'invalid-credential':
                        showDialog(
                            // ignore: use_build_context_synchronously
                            context: context,
                            builder: (context) => const IconDialog(
                                icon: Icon(Icons.error),
                                title: "Invalid Credential",
                                titleColor: Colors.redAccent,
                                content:
                                    "Your email or password is incorrect , please try again",
                                actionText: "Try again",
                                actionColor: Colors.redAccent));
                        break;
                      case 'network-request-failed':
                        showDialog(
                            // ignore: use_build_context_synchronously
                            context: context,
                            builder: (context) => const IconDialog(
                                icon: Icon(Icons.error),
                                title: "Network Error",
                                titleColor: Colors.redAccent,
                                content:
                                    "It seem to be a problem with network , please try again later",
                                actionText: "Try again",
                                actionColor: Colors.redAccent));
                        break;
                    }
                  }
                }
              },
              text: "Login",
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
              onPressed: () {},
              text: "Login with Google",
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
