import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/api/user_api.dart';
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/components/icon_dialog.dart';
import 'package:mobile_project/components/input_feild.dart';

class SetUpDisplayNamePage extends StatefulWidget {
  const SetUpDisplayNamePage({super.key});

  @override
  State<SetUpDisplayNamePage> createState() => _SetUpDisplayNamePageState();
}

class _SetUpDisplayNamePageState extends State<SetUpDisplayNamePage> {
  late UserApi _userController;
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _userController = UserApi();
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
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Enter Your Display Name",
                      style: GoogleFonts.notoSansThai(fontSize: 18),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          InputFeild(
                              label: "",
                              hintText: "Your name",
                              controller: _displayNameController),
                          const SizedBox(
                            height: 30,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Button(
                              height: 37,
                              width: 150,
                              text: "Next",
                              fontColor: Colors.white,
                              overlayColor: Colors.white,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              borderColor: Colors.black,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    _userController.initUser(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      _displayNameController.text,
                                    );
                                    Navigator.pushNamed(
                                      context,
                                      "/signup/profile",
                                    );
                                  } on FirebaseAuthException catch (error) {
                                    showDialog(
                                        context: context,
                                        builder: (context) => const IconDialog(
                                              icon: Icon(Icons.error),
                                              title: "Failed to sign up",
                                              titleColor: Colors.redAccent,
                                              content:
                                                  "something went wrong , please try again",
                                              actionText: "Try again",
                                              actionColor: Colors.redAccent,
                                            ));
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
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
