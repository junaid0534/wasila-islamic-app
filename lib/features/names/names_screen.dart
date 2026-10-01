import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/name_model.dart';
import '../../core/services/names_service.dart';
import '../../core/widgets/font_settings_sheet.dart';
import 'widgets/animated_name_card.dart';

class NamesScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const NamesScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<NamesScreen> createState() => _NamesScreenState();
}

class _NamesScreenState extends ConsumerState<NamesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  List<IslamicNameModel> _allahNames = [];
  List<IslamicNameModel> _prophetNames = [];
  bool _isLoading = true;
  bool _isListMode = true; // Default to Column/List View
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<void> _loadData() async {
    final allah = await NamesService.loadAllahNames();
    final prophet = await NamesService.loadProphetNames();
    if (mounted) {
      setState(() {
        _allahNames = allah;
        _prophetNames = prophet;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<IslamicNameModel> _filterNames(List<IslamicNameModel> list) {
    if (_searchQuery.isEmpty) return list;
    return list.where((n) {
      final inArabic = n.arabic.contains(_searchQuery);
      final inTrans = n.transliteration.toLowerCase().contains(_searchQuery);
      final inUrdu = n.urduMeaning.contains(_searchQuery);
      final inEng = n.englishMeaning.toLowerCase().contains(_searchQuery);
      final inId = n.id.toString() == _searchQuery;
      return inArabic || inTrans || inUrdu || inEng || inId;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAllah = _filterNames(_allahNames);
    final filteredProphet = _filterNames(_prophetNames);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  // Collapsing / Floating AppBar and Split Tabs
                  SliverAppBar(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    centerTitle: true,
                    floating: true,
                    snap: true,
                    pinned: false,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      'اسماءِ مبارکہ',
                      style: GoogleFonts.notoNastaliqUrdu(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.format_size_rounded, color: Colors.white),
                        tooltip: 'فونٹ تبدیل کریں',
                        onPressed: () => FontSettingsSheet.show(context),
                      ),
                      IconButton(
                        icon: Icon(
                          _isListMode ? Icons.grid_view_rounded : Icons.view_agenda_rounded,
                          color: Colors.white,
                        ),
                        tooltip: _isListMode ? 'گرڈ ویو' : 'لسٹ ویو',
                        onPressed: () => setState(() => _isListMode = !_isListMode),
                      ),
                      const SizedBox(width: 4),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(56),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Tab 0: اسماء الحسنى (99)
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _tabController.animateTo(0);
                                  setState(() {});
                                },
                                behavior: HitTestBehavior.opaque,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _tabController.index == 0 ? Colors.white : Colors.transparent,
                                    borderRadius: _tabController.index == 0
                                        ? const BorderRadius.only(
                                            topLeft: Radius.circular(23),
                                            bottomLeft: Radius.circular(23),
                                          )
                                        : null,
                                  ),
                                  child: Text(
                                    'اسماء الحسنى (99)',
                                    style: GoogleFonts.notoNastaliqUrdu(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: _tabController.index == 0 ? AppColors.primary : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Vertical White Center Divider
                            Container(
                              width: 1.2,
                              height: 44,
                              color: Colors.white.withValues(alpha: 0.35),
                            ),

                            // Tab 1: اسماء النبى ﷺ (99)
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _tabController.animateTo(1);
                                  setState(() {});
                                },
                                behavior: HitTestBehavior.opaque,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _tabController.index == 1 ? Colors.white : Colors.transparent,
                                    borderRadius: _tabController.index == 1
                                        ? const BorderRadius.only(
                                            topRight: Radius.circular(23),
                                            bottomRight: Radius.circular(23),
                                          )
                                        : null,
                                  ),
                                  child: Text(
                                    'اسماء النبى ﷺ (99)',
                                    style: GoogleFonts.notoNastaliqUrdu(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: _tabController.index == 1 ? AppColors.primary : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Search Bar that scrolls up smoothly
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      color: AppColors.background,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'عربی، انگلش یا اردو معنی سے تلاش کریں...',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () => _searchController.clear(),
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: AppColors.sageBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: AppColors.sageBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildNamesList(filteredAllah, 'اللہ تعالیٰ کے مبارک نام'),
                  _buildNamesList(filteredProphet, 'حضور نبی اکرم ﷺ کے مبارک نام'),
                ],
              ),
            ),
    );
  }

  Widget _buildNamesList(List<IslamicNameModel> names, String categoryTitle) {
    if (names.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'کوئی نام نہیں ملا',
              style: GoogleFonts.notoNastaliqUrdu(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_isListMode) {
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: names.length,
        itemBuilder: (context, index) {
          final item = names[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 18), // Increased row spacing
            child: AnimatedNameCard(
              name: item,
              isListMode: true,
            ),
          );
        },
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.92,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
      ),
      itemCount: names.length,
      itemBuilder: (context, index) {
        final item = names[index];
        return AnimatedNameCard(
          name: item,
          isListMode: false,
        );
      },
    );
  }
}
