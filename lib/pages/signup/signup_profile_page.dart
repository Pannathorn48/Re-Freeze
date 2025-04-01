import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_project/api/user_api.dart';
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/components/icon_dialog.dart';
import 'package:mobile_project/services/custom_theme.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupProfilePage extends StatefulWidget {
  const SignupProfilePage({super.key});

  @override
  State<SignupProfilePage> createState() => _SignupProfilePageState();
}

class _SignupProfilePageState extends State<SignupProfilePage> {
  final UserApi userController = UserApi();
  XFile? image;
  final ImagePicker _picker = ImagePicker();
  bool isSelected = false;
  void onImageSelected(XFile? image) {
    setState(() {
      this.image = image;
      isSelected = true;
    });
  }

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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: image != null
                          ? Image.file(
                              File(image!.path),
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.person,
                                  size: 100,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
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
                          if (image != null) {
                            onImageSelected(image);
                            print("Selected image path: ${image.path}");
                          } else {
                            setState(() {
                              isSelected = false;
                              this.image = null;
                            });
                          }
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
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (Route<dynamic> route) => false,
                );
              },
              text: "ข้าม",
              width: 150,
              height: 35,
              backgroundColor: Colors.white70,
              fontColor: Colors.black45,
              borderColor: Colors.black45)
          : Button(
              onPressed: () async {
                try {
                  String fileExtension = path.extension(image!.path);

                  String storagePath =
                      '/profile/${FirebaseAuth.instance.currentUser!.uid}$fileExtension';

                  String fullPath = await Supabase.instance.client.storage
                      .from('mobile-image')
                      .upload(storagePath, File(image!.path));

                  await userController.updateProfilePicture(
                      FirebaseAuth.instance.currentUser!.uid, fullPath);

                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home',
                    (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  debugPrint(e.toString());
                  showDialog(
                      context: context,
                      builder: (context) => const IconDialog(
                          icon: Icon(Icons.error),
                          title: "Failed to sign up",
                          titleColor: CustomColors.error,
                          content: "something went wrong , please try again",
                          actionText: "Try again",
                          actionColor: CustomColors.error));
                }
              },
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
