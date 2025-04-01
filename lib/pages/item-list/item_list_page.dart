import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/components/custom_float_button.dart';
import 'package:mobile_project/models/item_model.dart';
import 'package:mobile_project/models/refrigerators_model.dart';
import 'package:mobile_project/pages/item-list/dialog/item_factory.dart';
import 'package:mobile_project/pages/item-list/dialog/item_quantity_edit.dart';
import 'package:mobile_project/pages/item-list/dialog/tag_filter_dialog.dart';
import 'package:mobile_project/pages/item-list/item_edit_bottom_sheet.dart';
import 'package:mobile_project/services/custom_theme.dart';
import 'package:mobile_project/api/item_api.dart';
import 'package:mobile_project/api/refrigerator_api.dart';
import 'package:mobile_project/services/image_service.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  String searchText = "";
  late ItemApi _itemApi;
  late RefrigeratorApi _refrigeratorApi;
  late Refrigerator refrigerator;
  TextEditingController searchController = TextEditingController();
  List<Item> filteredItems = [];
  List<Item> allItems = [];
  bool isLoading = true;
  bool isRefrigeratorLoading = true;

  // Add tag filtering
  List<Tag> selectedTags = [];

  // Add stream subscription to track and cancel
  StreamSubscription? _itemsSubscription;

  @override
  void initState() {
    super.initState();
    _itemApi = ItemApi();
    _refrigeratorApi = RefrigeratorApi();
  }

  @override
  void dispose() {
    // Cancel the stream subscription to prevent callbacks after dispose
    _itemsSubscription?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the refrigerator ID from route arguments
    final args = ModalRoute.of(context)!.settings.arguments;

    if (args is String) {
      _loadRefrigerator(args);
    } else if (args is Refrigerator) {
      if (mounted) {
        setState(() {
          refrigerator = args;
          isRefrigeratorLoading = false;
        });
        _loadItems();
      }
    } else {
      if (mounted) {
        _loadItems();
      }
    }
  }

  Future<void> _loadRefrigerator(String refrigeratorId) async {
    if (!mounted) return;

    setState(() {
      isRefrigeratorLoading = true;
    });

    try {
      final refrigeratorData =
          await _refrigeratorApi.getRefrigeratorById(refrigeratorId);

      if (!mounted) return;

      if (refrigeratorData != null) {
        setState(() {
          refrigerator = refrigeratorData;
          isRefrigeratorLoading = false;
        });
        _loadItems();
      } else {
        _loadItems();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'ไม่พบข้อมูลตู้เย็น',
            style: GoogleFonts.notoSansThai(),
          )),
        );
      }
    } catch (e) {
      if (!mounted) return;

      _loadItems();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'เกิดข้อผิดพลาดในการโหลดข้อมูลตู้เย็น: $e',
          style: GoogleFonts.notoSansThai(),
        )),
      );
    }
  }

  Future<void> _loadItems() async {
    if (!mounted) return;

    _itemsSubscription?.cancel();

    setState(() {
      isLoading = true;
    });

    try {
      _itemsSubscription =
          _itemApi.getItemsForRefrigerator(refrigerator.uid).listen((items) {
        if (mounted) {
          setState(() {
            allItems = items;
            _filterItems();
            isLoading = false;
          });
        }
      }, onError: (e) {
        if (mounted) {
          setState(() {
            isLoading = false;
            _filterItems();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e',
                    style: GoogleFonts.notoSansThai())),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          _filterItems();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e',
                  style: GoogleFonts.notoSansThai())),
        );
      }
    }
  }

  void _filterItems() {
    if (mounted) {
      setState(() {
        filteredItems = List.from(allItems);

        if (searchText.isNotEmpty) {
          filteredItems = filteredItems
              .where((item) =>
                  item.name.toLowerCase().contains(searchText.toLowerCase()))
              .toList();
        }

        if (selectedTags.isNotEmpty) {
          filteredItems = filteredItems.where((item) {
            return item.tags.any((itemTag) => selectedTags
                .any((selectedTag) => selectedTag.uid == itemTag.uid));
          }).toList();
        }
      });
    }
  }

  void _showTagFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => TagFilterDialog(
        selectedTags: selectedTags,
        onApplyFilter: (tags) {
          setState(() {
            selectedTags = tags;
            _filterItems();
          });
        },
      ),
    );
  }

  void _showQuantityEditSheet(Item item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ItemQuantityEditSheet(
          item: item,
          onQuantityUpdated: () {
            _loadItems();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.greyBackground,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: isRefrigeratorLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              )
            : Text(
                refrigerator.name,
                style: GoogleFonts.notoSansThai(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      style: GoogleFonts.notoSansThai(),
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            searchText = value;
                            _filterItems();
                          });
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "ค้นหา",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.blue[100]!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      IconButton(
                        onPressed: _showTagFilterDialog,
                        icon: Icon(
                          Icons.filter_alt_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      if (selectedTags.isNotEmpty)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              selectedTags.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (selectedTags.isNotEmpty)
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(
                    "กรองตาม:",
                    style: GoogleFonts.notoSansThai(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedTags.length,
                      itemBuilder: (context, index) {
                        final tag = selectedTags[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            side: const BorderSide(
                              color: Colors.transparent,
                              width: 1,
                            ),
                            backgroundColor: tag.color,
                            label: Text(
                              tag.name,
                              style: GoogleFonts.notoSansThai(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            deleteIcon: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                            onDeleted: () {
                              setState(() {
                                selectedTags.removeAt(index);
                                _filterItems();
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  if (selectedTags.length > 1)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedTags.clear();
                          _filterItems();
                        });
                      },
                      child: Text(
                        "ล้างตัวกรอง",
                        style: GoogleFonts.notoSansThai(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: isRefrigeratorLoading || isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredItems.isEmpty
                    ? Center(
                        child: Text(
                          "ไม่พบรายการอาหาร",
                          style: GoogleFonts.notoSansThai(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (BuildContext context, int index) {
                          final item = filteredItems[index];
                          return GestureDetector(
                            onTap: () {
                              _showQuantityEditSheet(item);
                            },
                            child: Card(
                              child: SizedBox(
                                width: double.infinity,
                                height: 170,
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Image.network(
                                      ImageService.getSignURL(item.imageUrl),
                                      width: 130,
                                      height: 130,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/no-image.png',
                                          width: 130,
                                          height: 130,
                                        );
                                      },
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "ชื่อ: ",
                                                  style:
                                                      GoogleFonts.notoSansThai(
                                                    fontSize: 20,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: item.name,
                                                  style:
                                                      GoogleFonts.notoSansThai(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "จำนวน ",
                                                  style:
                                                      GoogleFonts.notoSansThai(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "${item.quantity} ${item.unit}",
                                                  style:
                                                      GoogleFonts.notoSansThai(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "วันหมดอายุ ",
                                                  style:
                                                      GoogleFonts.notoSansThai(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: item.expiryDateString,
                                                  style:
                                                      GoogleFonts.notoSansThai(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: _getExpiryColor(
                                                        item.expiryDate),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 30,
                                            child: ListView(
                                              scrollDirection: Axis.horizontal,
                                              children: item.tags
                                                  .map((tag) => Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(right: 5),
                                                        child: Chip(
                                                          side: BorderSide(
                                                              color: tag.color,
                                                              width: 1),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                          backgroundColor:
                                                              tag.color,
                                                          label: Text(
                                                            tag.name,
                                                            style: GoogleFonts
                                                                .notoSansThai(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12),
                                                          ),
                                                        ),
                                                      ))
                                                  .toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        icon: const Icon(
                                            Icons.more_horiz_outlined),
                                        onPressed: () {
                                          _showEditBottomSheet(item);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: CustomFloatButton(
        onPressed: () {
          _showAddItemDialog();
        },
      ),
    );
  }

  // Determine color for expiry date text based on how soon it expires
  Color _getExpiryColor(DateTime expiryDate) {
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;

    if (daysUntilExpiry < 1) {
      return Colors.red; // Already expired
    } else if (daysUntilExpiry <= 3) {
      return Colors.orange; // Expiring soon
    } else {
      return Colors.green; // Plenty of time
    }
  }

  // Show bottom sheet with edit/delete options
  void _showEditBottomSheet(Item item) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return EditBottomSheet(
          title: item.name,
          item: item, // Pass the item to the bottom sheet
        );
      },
    );
  }

  // Show dialog to add a new item
  void _showAddItemDialog() {
    ItemDialogFactory.showItemDialog(context, refrigeratorId: refrigerator.uid);
  }
}
