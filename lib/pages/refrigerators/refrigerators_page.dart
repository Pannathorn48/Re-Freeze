import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/api/refrigerator_api.dart';
import 'package:mobile_project/components/custom_float_button.dart';
import 'package:mobile_project/components/search_text_input.dart';
import 'package:mobile_project/models/refrigerators_model.dart';
import 'package:mobile_project/pages/refrigerators/add_refrigerator_dialog.dart';
import 'package:mobile_project/pages/refrigerators/refrigerator_card.dart';
import 'package:mobile_project/services/custom_theme.dart';

class RefrigeratorsPage extends StatefulWidget {
  const RefrigeratorsPage({super.key});

  @override
  State<RefrigeratorsPage> createState() => _RefrigeratorsPageState();
}

class _RefrigeratorsPageState extends State<RefrigeratorsPage> {
  final TextEditingController _searchController = TextEditingController();
  final RefrigeratorApi _refrigeratorApi = RefrigeratorApi();
  String _searchQuery = '';
  List<String> _favoriteRefrigeratorIds = [];
  bool _isFetchingFavorites = false;
  Set<String> _processingRefrigeratorIds = {};

  // Keep track of refrigerators whose favorite status is being fetched
  Set<String> _fetchingFavoriteStatus = {};

  // Add stream subscription for proper management
  StreamSubscription<QuerySnapshot>? _refrigeratorsSubscription;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchFavoriteRefrigerators();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _refrigeratorsSubscription?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {
        _searchQuery = _searchController.text;
      });
    }
  }

  Future<void> _fetchFavoriteRefrigerators() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (!mounted) return;
    setState(() {
      _isFetchingFavorites = true;
    });

    try {
      // Get all refrigerators first to know which ones to mark as loading
      final refrigeratorsSnapshot =
          await _refrigeratorApi.getRefrigeratorsFromUserId(user.uid).first;

      if (!mounted) return;

      final allRefrigerators = refrigeratorsSnapshot.docs.map((doc) {
        return Refrigerator.fromJSON(doc.data() as Map<String, dynamic>);
      }).toList();

      // Mark all refrigerators as fetching favorite status
      if (mounted) {
        setState(() {
          for (var refrigerator in allRefrigerators) {
            _fetchingFavoriteStatus.add(refrigerator.uid);
          }
        });
      }

      // Now fetch the favorites
      final favorites =
          await _refrigeratorApi.getFavoriteRefrigerators(user.uid);

      if (!mounted) return;

      setState(() {
        _favoriteRefrigeratorIds = favorites.map((r) => r.uid).toList();
        // Clear the fetching status as we now have the data
        _fetchingFavoriteStatus.clear();
      });
    } catch (e) {
      // Handle error silently - we'll just assume no favorites
      debugPrint('Error fetching favorites: $e');
      if (mounted) {
        setState(() {
          _fetchingFavoriteStatus.clear(); // Clear on error too
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingFavorites = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: CustomColors.greyBackground,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 20),
          child: Text("ตู้เย็นทั้งหมด",
              style: GoogleFonts.notoSansThai(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButton: CustomFloatButton(onPressed: () {
        showDialog(
            context: context,
            builder: (context) => const AddRefrigeratorDialog());
      }),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: SearchTextInput(controller: _searchController),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: user != null
                ? StreamBuilder<QuerySnapshot>(
                    stream:
                        _refrigeratorApi.getRefrigeratorsFromUserId(user.uid),
                    builder: (context, snapshot) {
                      // Store the subscription for cleanup in dispose
                      if (snapshot.connectionState == ConnectionState.active &&
                          _refrigeratorsSubscription == null) {
                        _refrigeratorsSubscription = _refrigeratorApi
                            .getRefrigeratorsFromUserId(user.uid)
                            .listen((event) {}, onError: (_) {});
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            'ไม่พบตู้เย็น',
                            style: GoogleFonts.notoSansThai(fontSize: 16),
                          ),
                        );
                      }

                      // Convert to list of Refrigerator models
                      final refrigerators = snapshot.data!.docs.map((doc) {
                        return Refrigerator.fromJSON(
                            doc.data() as Map<String, dynamic>);
                      }).toList();

                      // Apply search filter
                      final filteredRefrigerators = _searchQuery.isEmpty
                          ? refrigerators
                          : refrigerators
                              .where((refrigerator) => refrigerator.name
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()))
                              .toList();

                      if (filteredRefrigerators.isEmpty) {
                        return Center(
                          child: Text(
                            'ไม่พบตู้เย็นที่ตรงกับการค้นหา',
                            style: GoogleFonts.notoSansThai(fontSize: 16),
                          ),
                        );
                      }

                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: filteredRefrigerators.length,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemBuilder: (context, index) {
                          final refrigerator = filteredRefrigerators[index];
                          final isFavorite = _favoriteRefrigeratorIds
                              .contains(refrigerator.uid);

                          // Check if this refrigerator's favorite status is being fetched
                          // or if it's being processed for another action
                          final isLoading = _processingRefrigeratorIds
                                  .contains(refrigerator.uid) ||
                              _fetchingFavoriteStatus
                                  .contains(refrigerator.uid);

                          return RefrigeratorCard(
                            refrigerator: refrigerator,
                            isFavorite: isFavorite,
                            isLoading: isLoading,
                            onDelete: () async {
                              if (!mounted) return;
                              setState(() {
                                _processingRefrigeratorIds
                                    .add(refrigerator.uid);
                              });

                              try {
                                await _refrigeratorApi
                                    .deleteRefrigerator(refrigerator.uid);
                                // No need to update state here as the StreamBuilder will refresh
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('ไม่สามารถลบตู้เย็นได้: $e')),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _processingRefrigeratorIds
                                        .remove(refrigerator.uid);
                                  });
                                }
                              }
                            },
                            onFavoriteToggle: () async {
                              if (!mounted) return;
                              setState(() {
                                _processingRefrigeratorIds
                                    .add(refrigerator.uid);
                              });

                              try {
                                if (isFavorite) {
                                  await _refrigeratorApi
                                      .removeFromFavorites(refrigerator.uid);
                                } else {
                                  await _refrigeratorApi
                                      .addToFavorites(refrigerator.uid);
                                }

                                // Update local state immediately for better UX
                                if (mounted) {
                                  setState(() {
                                    if (isFavorite) {
                                      _favoriteRefrigeratorIds
                                          .remove(refrigerator.uid);
                                    } else {
                                      _favoriteRefrigeratorIds
                                          .add(refrigerator.uid);
                                    }
                                  });
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(isFavorite
                                            ? 'ไม่สามารถลบออกจากรายการโปรดได้: $e'
                                            : 'ไม่สามารถเพิ่มในรายการโปรดได้: $e')),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _processingRefrigeratorIds
                                        .remove(refrigerator.uid);
                                  });
                                }
                              }
                            },
                          );
                        },
                      );
                    },
                  )
                : const Center(child: Text('กรุณาเข้าสู่ระบบก่อน')),
          )
        ],
      ),
    );
  }
}
