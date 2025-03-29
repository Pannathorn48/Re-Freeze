import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_project/api/user_controller.dart';

class ProfileWidget extends StatelessWidget {
  final BuildContext context;
  final UserController userController = UserController();
  ProfileWidget({super.key, required this.context});
  Future<Widget> _loadImage() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Icon(
        Icons.error,
        size: 40,
        color: Theme.of(context).colorScheme.primary,
      );
    }
    String? imageURL = await userController.getProfilePicture(uid);
    if (imageURL != null) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(imageURL),
      );
    } else {
      return Icon(
        Icons.error,
        size: 40,
        color: Theme.of(context).colorScheme.primary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadImage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Icon(
              Icons.error,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            );
          } else {
            return snapshot.data!;
          }
        });
  }
}
