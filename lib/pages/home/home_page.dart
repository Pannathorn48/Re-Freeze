import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/api/refrigerator_api.dart';
import 'package:mobile_project/api/user_api.dart';
import 'package:mobile_project/models/refrigerators_model.dart';
import 'package:mobile_project/models/user.dart';
import 'package:mobile_project/pages/home/favorite/favorite_refrigerator.dart';
import 'package:mobile_project/pages/home/home_dialog/home_add_dialog.dart';
import 'package:mobile_project/pages/home/notification/notification.dart';
import 'package:mobile_project/pages/home/profile_widget.dart';
import 'package:mobile_project/pages/item-detail/item_detail_page.dart'; // Import the item detail page
import 'package:mobile_project/services/providers.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late UserApi userApi;
  late RefrigeratorApi refrigeratorApi;
  final TextEditingController searchController = TextEditingController();
  final ScrollController _favoriteScrollController = ScrollController();
  String searchText = "";
  bool _isLoading = false;

  // Stream controller to manage data stream
  late StreamController<Map<String, dynamic>> _dataStreamController;

  // Initialize stream and fetch initial data
  void _initializeDataStream() {
    _dataStreamController = StreamController<Map<String, dynamic>>();
    // Use addPostFrameCallback to avoid setting state during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAndAddData();
    });
  }

  // Fetch data and add to stream
  Future<void> _fetchAndAddData() async {
    try {
      // Set local loading state instead of using Provider during initialization
      setState(() {
        _isLoading = true;
      });

      // After the widget is fully built, now it's safe to update the provider
      if (mounted) {
        Provider.of<LoadingProvider>(context, listen: false).setLoading(true);
      }

      PlatformUser? user =
          await userApi.getUser(FirebaseAuth.instance.currentUser!.uid);
      List<Refrigerator> favoriteRefrigerator = await refrigeratorApi
          .getFavoriteRefrigerators(FirebaseAuth.instance.currentUser!.uid);

      final data = {
        "user": user,
        "refrigerators": favoriteRefrigerator,
      };

      if (!_dataStreamController.isClosed && mounted) {
        _dataStreamController.add(data);
      }

      // Update loading states
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        Provider.of<LoadingProvider>(context, listen: false).setLoading(false);
      }
    } catch (error) {
      if (!_dataStreamController.isClosed && mounted) {
        _dataStreamController.addError(error);
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          Provider.of<LoadingProvider>(context, listen: false)
              .setLoading(false);
        }
      }
    }
  }

  // Method to refresh data
  Future<void> _refreshData() async {
    return _fetchAndAddData();
  }

  @override
  void initState() {
    super.initState();
    userApi = UserApi();
    refrigeratorApi = RefrigeratorApi();
    _initializeDataStream();
  }

  @override
  void dispose() {
    searchController.dispose();
    _favoriteScrollController.dispose();
    _dataStreamController.close();
    super.dispose();
  }

  // Navigate to ItemListScreen with combined view
  void _navigateToItemsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ItemListScreen(type: ItemListType.all),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _dataStreamController.stream,
      builder: (context, snapshot) {
        // Show loading indicator for initial load
        if ((snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) ||
            _isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Error loading data"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text("Try Again"),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: Text("No data available"),
            ),
          );
        }

        // Main UI with refreshed data
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _refreshData,
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Colors.white,
            displacement: 60,
            strokeWidth: 3,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: 400,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        // Background container
                        Container(
                          height: 320,
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade500,
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.topCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Hi, ${snapshot.data!["user"].displayName}",
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child:
                                    snapshot.data?["user"].profilePictureURL ==
                                            null
                                        ? Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer,
                                                borderRadius:
                                                    BorderRadius.circular(100)),
                                            child: Icon(
                                              Icons.person,
                                              size: 40,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          )
                                        : ProfileWidget(
                                            context: context,
                                          ),
                              ),
                            ],
                          ),
                        ),

                        // Categories UI component
                        Positioned(
                          top: 150,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: 230,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade500,
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Text("หมวดหมู่",
                                      style: GoogleFonts.notoSansThai(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      )),
                                  const SizedBox(height: 30),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildCategoryIcon(
                                          icon: SvgPicture.asset(
                                            'assets/icons/Refrigerator.svg',
                                            width: 30,
                                            colorFilter: ColorFilter.mode(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                BlendMode.srcIn),
                                          ),
                                          title: "ตู้เย็นทั้งหมด",
                                          onPressed: () {
                                            Navigator.pushNamed(
                                                context, "/refrigerators");
                                          }),
                                      _buildCategoryIcon(
                                          icon: Icon(Icons.warning,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                          title: "การแจ้งเตือน",
                                          onPressed: _navigateToItemsScreen),
                                      _buildCategoryIcon(
                                          icon: Icon(
                                            Icons.shopping_bag,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                          title: "เหลือน้อย",
                                          onPressed: () {}),
                                      _buildCategoryIcon(
                                          icon: Icon(
                                            Icons.add,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                          title: "เพิ่มรายการ",
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return const TabbedDialog();
                                                });
                                          })
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(right: 25, left: 25),
                      child: Column(
                        children: [
                          FavoriteRefrigeratorWidget(
                              favoriteRefrigerators: snapshot
                                  .data!["refrigerators"] as List<Refrigerator>,
                              favoriteScrollController:
                                  _favoriteScrollController),
                          const SizedBox(height: 20),
                          const NotificationWidget(),
                        ],
                      )),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryIcon({
    required Widget icon,
    required String title,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 7, left: 7),
      child: Column(
        children: [
          IconButton(
            onPressed: onPressed,
            icon: icon,
            style: IconButton.styleFrom(
              iconSize: 30,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            title,
            style: GoogleFonts.notoSansThai(),
          )
        ],
      ),
    );
  }
}
