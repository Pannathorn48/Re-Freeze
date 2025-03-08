import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/pages/login/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Text("Refreeze",
                  style: GoogleFonts.notoSansThai(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              const SizedBox(
                height: 50,
              ),
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Login",
                      style: GoogleFonts.notoSansThai(
                          fontSize: 27, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const LoginForm(),
                    const SizedBox(
                      height: 70,
                    ),
                    Center(
                      child: RichText(
                          text: TextSpan(
                              text: "Don't have an account? ",
                              style: GoogleFonts.notoSansThai(
                                  fontSize: 16, color: Colors.black),
                              children: [
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushNamed(context, '/home');
                                },
                              text: "Sign up",
                              style: GoogleFonts.notoSansThai(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.primary),
                            )
                          ])),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
