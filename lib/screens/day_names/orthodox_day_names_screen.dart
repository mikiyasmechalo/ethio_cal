import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ethiopian_datetime/ethiopian_datetime.dart';
import 'package:ethio_cal/constants/orthodox_day_names.dart';
import 'package:ethio_cal/providers/theme_provider.dart';

class OrthodoxDayNamesScreen extends StatefulWidget {
  const OrthodoxDayNamesScreen({super.key});

  @override
  State<OrthodoxDayNamesScreen> createState() => _OrthodoxDayNamesScreenState();
}

class _OrthodoxDayNamesScreenState extends State<OrthodoxDayNamesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTab = 0; // 0: 1-30 Days, 1: Pagumen

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final highlight = theme.highlightColor;
    final surface = theme.surfaceColor;
    final accent = theme.accentColor;
    final nowEt = ETDateTime.now();

    // Filter items based on query
    final monthlyEntries = OrthodoxDayNames.monthlySaints.entries.where((entry) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      if (entry.key.toString().contains(q)) return true;
      return entry.value.any((saint) => saint.toLowerCase().contains(q));
    }).toList();

    final pagumenEntries = OrthodoxDayNames.pagumenSaints.entries.where((entry) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      if (entry.key.toString().contains(q)) return true;
      return entry.value.any((saint) => saint.toLowerCase().contains(q));
    }).toList();

    final activeEntries = _selectedTab == 0 ? monthlyEntries : pagumenEntries;

    return Scaffold(
      backgroundColor: theme.scaffoldColor,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: highlight),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'የዕለት ስሞች (Orthodox Day Names)',
          style: GoogleFonts.chauPhilomeneOne(
            color: highlight,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Tab Switcher
            Container(
              color: surface,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  // Search TextField
                  Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.chauPhilomeneOne(color: highlight, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'በስም ወይም በቀን ፈልግ (Search saint or day)...',
                        hintStyle: GoogleFonts.chauPhilomeneOne(
                          color: highlight.withOpacity(0.4),
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(Icons.search_rounded, color: highlight.withOpacity(0.5), size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, color: highlight.withOpacity(0.5), size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tabs: 1-30 ወርሃዊ vs ጳጉሜ
                  Row(
                    children: [
                      Expanded(
                        child: _tabButton(
                          title: 'ወርሃዊ በዓላት (1 - 30)',
                          isSelected: _selectedTab == 0,
                          accentColor: accent,
                          highlightColor: highlight,
                          surfaceColor: theme.scaffoldColor,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _tabButton(
                          title: 'ጳጉሜ (Pagumen 1 - 6)',
                          isSelected: _selectedTab == 1,
                          accentColor: accent,
                          highlightColor: highlight,
                          surfaceColor: theme.scaffoldColor,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Saints List
            Expanded(
              child: activeEntries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: highlight.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          Text(
                            'ምንም አልተገኘም (No saints found)',
                            style: GoogleFonts.chauPhilomeneOne(
                              color: highlight.withOpacity(0.5),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: activeEntries.length,
                      itemBuilder: (context, index) {
                        final entry = activeEntries[index];
                        final dayNum = entry.key;
                        final saints = entry.value;
                        final isToday = _selectedTab == 0
                            ? (nowEt.month != 13 && nowEt.day == dayNum)
                            : (nowEt.month == 13 && nowEt.day == dayNum);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isToday ? accent.withOpacity(0.12) : surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isToday ? accent : highlight.withOpacity(0.08),
                              width: isToday ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Day badge
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isToday ? accent : highlight.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$dayNum',
                                  style: GoogleFonts.chauPhilomeneOne(
                                    fontSize: 20,
                                    color: isToday ? Colors.white : highlight,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Saints list
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            saints.first,
                                            style: GoogleFonts.chauPhilomeneOne(
                                              fontSize: 17,
                                              color: highlight,
                                            ),
                                          ),
                                        ),
                                        if (isToday)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: accent,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'ዛሬ (Today)',
                                              style: GoogleFonts.chauPhilomeneOne(
                                                fontSize: 10,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (saints.length > 1) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        saints.sublist(1).join(' • '),
                                        style: GoogleFonts.chauPhilomeneOne(
                                          fontSize: 13,
                                          color: highlight.withOpacity(0.65),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required bool isSelected,
    required Color accentColor,
    required Color highlightColor,
    required Color surfaceColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? accentColor : surfaceColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: GoogleFonts.chauPhilomeneOne(
            fontSize: 12,
            color: isSelected ? Colors.white : highlightColor.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
