import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/api/user_api.dart';
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/components/icon_dialog.dart';
import 'package:mobile_project/services/login_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late UserApi userController;
  @override
  void initState() {
    super.initState();
    userController = UserApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ขอต้อนรับสู่",
                      style: GoogleFonts.notoSansThai(fontSize: 24)),
                  Text("Refreeze",
                      style: GoogleFonts.notoSansThai(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary)),
                  Text("บริหารจัดการตู้เย็นอย่างมีประสิทธิภาพ",
                      style: GoogleFonts.notoSansThai(
                        fontSize: 20,
                      )),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Center(
              child: Button(
                onPressed: () async {
                  try {
                    final userCred = await GoogleAuth.signInWithGoogle();
                    final exist =
                        await userController.getUser(userCred.user!.uid);
                    if (exist != null && exist.displayName != null) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/home',
                        (Route<dynamic> route) => false,
                      );
                    } else {
                      Navigator.pushNamed(
                        context,
                        "/signup/display-name",
                      );
                    }
                  } catch (error) {
                    debugPrint(error.toString());
                    showDialog(
                        context: context,
                        builder: (context) => const IconDialog(
                              icon: Icon(Icons.error),
                              title: "Failed to sign up",
                              titleColor: Colors.redAccent,
                              content:
                                  "something went wrong , please try again ",
                              actionText: "Try again",
                              actionColor: Colors.redAccent,
                            ));
                  }
                },
                text: "Get start with Google",
                width: 335,
                height: 40,
                fontColor: Colors.black54,
                borderColor: Colors.black,
                icon: SvgPicture.asset("assets/icons/google.svg"),
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Center(
                child: Button(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              text: "Login",
              width: 335,
              height: 40,
              fontColor: Colors.black54,
              borderColor: Colors.black,
            )),
            const SizedBox(
              height: 20,
            ),
            RichText(
                text: TextSpan(
              text: "Don't have an account? ",
              style: GoogleFonts.notoSans(fontSize: 15, color: Colors.black54),
              children: [
                TextSpan(
                  text: "Sign up",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pushNamed(context, "/signup");
                    },
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
