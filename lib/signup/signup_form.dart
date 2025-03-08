import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/components/input_feild.dart';
import 'package:mobile_project/services/validator.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            const InputFeild(
              label: "Email",
              keyboardType: TextInputType.emailAddress,
              hintText: "Enter your email",
              validator: Validator.validateEmail,
            ),
            const SizedBox(
              height: 15,
            ),
            InputFeild(
              label: "Password",
              hintText: "Enter your password",
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 15,
            ),
            InputFeild(
              label: "Confirm Password",
              hintText: "Enter your password",
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
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
              onPressed: () {
                _formKey.currentState!.validate();
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
              onPressed: () {},
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
