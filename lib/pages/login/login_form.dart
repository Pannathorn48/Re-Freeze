import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/api/user_api.dart';
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/components/icon_dialog.dart';
import 'package:mobile_project/components/input_feild.dart';
import 'package:mobile_project/services/custom_theme.dart';
import 'package:mobile_project/services/login_service.dart';
import 'package:mobile_project/services/validator_service.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late UserApi userController;
  bool _isVisible = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    userController = UserApi();
  }

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
                    final userCredential = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: emailController.text,
                            password: passwordController.text);
                    final exist =
                        await userController.getUser(userCredential.user!.uid);
                    if (exist?.displayName == null) {
                      Navigator.pushNamed(context, "/signup/display-name");
                    } else {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/home',
                        (Route<dynamic> route) => false,
                      );
                    }
                  } on FirebaseAuthException catch (e) {
                    switch (e.code) {
                      case 'invalid-email':
                      case 'invalid-credential':
                        showDialog(
                            context: context,
                            builder: (context) => const IconDialog(
                                icon: Icon(Icons.error),
                                title: "Invalid Credential",
                                titleColor: CustomColors.error,
                                content:
                                    "Your email or password is incorrect , please try again",
                                actionText: "Try again",
                                actionColor: CustomColors.error));
                        break;
                      case 'network-request-failed':
                        showDialog(
                            context: context,
                            builder: (context) => const IconDialog(
                                icon: Icon(Icons.error),
                                title: "Network Error",
                                titleColor: CustomColors.error,
                                content:
                                    "It seem to be a problem with network , please try again later",
                                actionText: "Try again",
                                actionColor: CustomColors.error));
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
              onPressed: () async {
                try {
                  final userCred = await GoogleAuth.signInWithGoogle();
                  final exist =
                      await userController.getUser(userCred.user!.uid);
                  if (exist?.displayName == null) {
                    Navigator.pushNamed(context, "/signup/display-name");
                  } else {
                    if (mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/home',
                        (Route<dynamic> route) => false,
                      );
                    }
                  }
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
