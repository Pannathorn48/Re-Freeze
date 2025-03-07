import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
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
              child: SizedBox(
                width: 335,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(color: Colors.black, width: 0.05),
                    elevation: 1.5,
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    shadowColor: null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    "assets/icons/google.svg",
                    width: 25,
                    height: 25,
                  ),
                  label: Text("Get start with Google",
                      style: GoogleFonts.notoSans(
                          fontSize: 17, color: Colors.black54)),
                ),
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Center(
              child: SizedBox(
                width: 335,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.black, width: 0.05),
                      elevation: 2,
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                      shadowColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: Text("Log in",
                        style: GoogleFonts.notoSans(
                            fontSize: 17, color: Colors.black54))),
              ),
            ),
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
                      Navigator.pushNamed(context, "/register");
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
