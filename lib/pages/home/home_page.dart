import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/api/refrigerator_api.dart';
import 'package:mobile_project/api/user_api.dart';
import 'package:mobile_project/models/refrigerators_model.dart';
import 'package:mobile_project/models/user.dart';
import 'package:mobile_project/pages/home/favorite_refrigerator.dart';
import 'package:mobile_project/pages/home/home_add_dialog.dart';
import 'package:mobile_project/pages/home/notification.dart';
import 'package:mobile_project/pages/home/profile_widget.dart';
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

  // Method to simulate data loading
  Future<void> _refreshData() async {
    Provider.of<LoadingProvider>(context, listen: false).setLoading(true);
    await Future.delayed(const Duration(seconds: 2));
    Provider.of<LoadingProvider>(context, listen: false).setLoading(false);
  }

  Future<Map<String, dynamic>> _fetchData() async {
    PlatformUser? user =
        await userApi.getUser(FirebaseAuth.instance.currentUser!.uid);
    List<Refrigerator> favoriteRefrigerator = await refrigeratorApi
        .getFavoriteRefrigerators(FirebaseAuth.instance.currentUser!.uid);
    return {
      "user": user,
      "refrigerators": favoriteRefrigerator,
    };
  }

  @override
  void initState() {
    userApi = UserApi();
    refrigeratorApi = RefrigeratorApi();
    _fetchData();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    _favoriteScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text("Error loading data"),
          );
        }
        return Scaffold(
            body: RefreshIndicator(
          onRefresh: _refreshData,
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Colors.white,
          displacement: 60,
          strokeWidth: 3,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(children: [
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
                            child: snapshot.data?["user"].profilePictureURL ==
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                : ProfileWidget(
                                    context: context,
                                  ),
                          ),
                        ],
                      ),
                    ),

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
                              // SearchTextInput(controller: searchController),
                              Text("หมวดหมู่",
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
                                      title: "ใกล้หมดอายุ",
                                      onPressed: () {}),
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
                                              return TabbedDialog();
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
                          favoriteRefrigerators: snapshot.data!["refrigerators"]
                              as List<Refrigerator>,
                          favoriteScrollController: _favoriteScrollController),
                      const SizedBox(height: 20),
                      const NotificationWidget(),
                    ],
                  )),
              const SizedBox(height: 50),
            ]),
          ),
        ));
      },
      future: _fetchData(),
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
