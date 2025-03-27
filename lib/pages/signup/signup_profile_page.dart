import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_project/components/button.dart';

class SignupProfilePage extends StatefulWidget {
  const SignupProfilePage({super.key});

  @override
  State<SignupProfilePage> createState() => _SignupProfilePageState();
}

class _SignupProfilePageState extends State<SignupProfilePage> {
  final ImagePicker _picker = ImagePicker();
  bool isSelected = false;
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
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/avatar-icon.svg',
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      "เลือกรูปเพื่อใช้เป็นรูปโปรไฟล์",
                      style: GoogleFonts.notoSansThai(
                          fontSize: 15, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Button(
                        onPressed: () async {
                          XFile? image = await _picker.pickImage(
                              source: ImageSource.gallery);
                        },
                        icon: SvgPicture.asset(
                          'assets/icons/image-icon.svg',
                          width: 20,
                          height: 20,
                        ),
                        text: "เปิดอัลบั้ม",
                        borderRadius: 30,
                        width: 150,
                        height: 35,
                        fontColor: Theme.of(context).colorScheme.primary,
                        borderColor: Colors.black45)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: !isSelected
          ? Button(
              onPressed: () {
                Navigator.pushNamed(context, "/home");
              },
              text: "ข้าม",
              width: 150,
              height: 35,
              backgroundColor: Colors.white70,
              fontColor: Colors.black45,
              borderColor: Colors.black45)
          : Button(
              onPressed: () {},
              text: "Next",
              width: 150,
              height: 35,
              fontColor: Colors.white,
              overlayColor: Colors.white,
              backgroundColor: Theme.of(context).colorScheme.primary,
              borderColor: Colors.black45),
    );
  }
}
