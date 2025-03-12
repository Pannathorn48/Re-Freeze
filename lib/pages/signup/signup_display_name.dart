import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/components/input_feild.dart';

class SetUpDisplayNamePage extends StatefulWidget {
  const SetUpDisplayNamePage({super.key});

  @override
  State<SetUpDisplayNamePage> createState() => _SetUpDisplayNamePageState();
}

class _SetUpDisplayNamePageState extends State<SetUpDisplayNamePage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
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
                              onPressed: () {},
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
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: Button(
      //     height: 37,
      //     width: 150,
      //     text: "Next",
      //     fontColor: Colors.white,
      //     overlayColor: Colors.white,
      //     backgroundColor: Theme.of(context).colorScheme.primary,
      //     borderColor: Colors.black,
      //     onPressed: () {},
      //   ),
      // ),
    );
  }
}
