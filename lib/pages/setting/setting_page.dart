import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_project/api/user_api.dart';
import 'package:mobile_project/models/user.dart';
import 'package:mobile_project/pages/setting/profile_widget.dart';
import 'package:mobile_project/services/custom_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_project/services/image_service.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final _userApi = UserApi();
  final _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  PlatformUser? _currentUser;
  String? _profilePictureURL;
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user ID from Firebase Auth
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final user = await _userApi.getUser(userId);
        final profilePicture = await _userApi.getProfilePicture(userId);

        if (mounted) {
          setState(() {
            _currentUser = user;
            _profilePictureURL = profilePicture;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading user data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadProfilePicture(File imageFile) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        // Upload the image using the ImageService
        final storagePath =
            await ImageService.uploadImage(imageFile.path, 'profiles');

        // Update user profile with new image URL
        await _userApi.updateProfilePicture(userId, storagePath);

        if (mounted) {
          setState(() {
            _profilePictureURL = ImageService.getSignURL(storagePath);
            _isUploading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading profile picture: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Image Source',
          style: GoogleFonts.notoSansThai(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                ),
              ),
              title: Text(
                'Camera',
                style: GoogleFonts.notoSansThai(fontSize: 16),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                  maxWidth: 800,
                );
                if (photo != null && mounted) {
                  await _uploadProfilePicture(File(photo.path));
                }
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.photo_library,
                  color: Colors.white,
                ),
              ),
              title: Text(
                'Gallery',
                style: GoogleFonts.notoSansThai(fontSize: 16),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                  maxWidth: 800,
                );
                if (image != null && mounted) {
                  await _uploadProfilePicture(File(image.path));
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.notoSansThai(color: Colors.red),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.greyBackground,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 10),
          child: Text(
            "Settings",
            style: GoogleFonts.notoSansThai(
              fontSize: 22,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Profile Header Section
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Profile Image with edit button overlay
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: _isUploading
                                    ? const CircleAvatar(
                                        radius: 60,
                                        backgroundColor: Colors.white,
                                        child: CircularProgressIndicator(),
                                      )
                                    : CircleAvatar(
                                        radius: 60,
                                        backgroundColor: Colors.white,
                                        child: ClipOval(
                                          child: ProfileSetting(
                                            context: context,
                                            imageUrl: _profilePictureURL,
                                            size: 120,
                                            iconSize: 70,
                                          ),
                                        ),
                                      ),
                              ),
                              GestureDetector(
                                onTap: _showImageSourceDialog,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.secondary,
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          // Display Name
                          Text(
                            _currentUser?.displayName ?? 'User',
                            style: GoogleFonts.notoSansThai(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          // Email or subtitle
                          Text(
                            _auth.currentUser?.email ?? 'No email',
                            style: GoogleFonts.notoSansThai(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 25),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Settings Options Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, bottom: 8.0),
                            child: Text(
                              'Account',
                              style: GoogleFonts.notoSansThai(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                          ),

                          // Profile Settings Card
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 6),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.person_outline,
                                  size: 28,
                                  color: Colors.blue,
                                ),
                              ),
                              title: Text(
                                'Change Display Name',
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 18,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: Colors.black45,
                              ),
                              onTap: () {
                                Navigator.pushNamed(context, "/setting/profile")
                                    .then((_) {
                                  // Refresh user data when returning from profile settings
                                  _loadUserData();
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Change Password Card
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 6),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.lock_outline,
                                  size: 28,
                                  color: Colors.purple,
                                ),
                              ),
                              title: Text(
                                'Change Password',
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 18,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: Colors.black45,
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/setting/password');
                              },
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Logout Button
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                FirebaseAuth.instance.signOut().then((value) {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/landing', (route) => false);
                                }).catchError((error) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(error.toString()),
                                    backgroundColor: Colors.red,
                                  ));
                                });
                              },
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: Colors.white,
                              ),
                              label: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'Logout',
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
