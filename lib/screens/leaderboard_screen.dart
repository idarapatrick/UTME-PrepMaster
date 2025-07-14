import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _xpPeriods = ['24h', 'Weekly', 'Monthly'];
  int _xpPeriodIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentAmber,
          tabs: const [
            Tab(text: 'XP Earned'),
            Tab(text: 'CBT High Scores'),
          ],
        ),
      ),
      backgroundColor: isDark
          ? const Color(0xFF181A20)
          : AppColors.backgroundPrimary,
      body: TabBarView(
        controller: _tabController,
        children: [
          // XP Leaderboard
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ToggleButtons(
                  isSelected: List.generate(
                    _xpPeriods.length,
                    (i) => i == _xpPeriodIndex,
                  ),
                  onPressed: (i) => setState(() => _xpPeriodIndex = i),
                  borderRadius: BorderRadius.circular(12),
                  selectedColor: Colors.white,
                  fillColor: AppColors.dominantPurple,
                  color: AppColors.dominantPurple,
                  children: _xpPeriods
                      .map(
                        (p) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            p,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, i) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: i == 0
                          ? AppColors.accentAmber
                          : AppColors.dominantPurple.withOpacity(0.1),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: i == 0
                              ? AppColors.dominantPurple
                              : AppColors.dominantPurple,
                        ),
                      ),
                    ),
                    title: Text(
                      'User ${i + 1}',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${(10000 - i * 500)} XP',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // CBT High Scores Leaderboard
          ListView.builder(
            itemCount: 10,
            itemBuilder: (context, i) => ListTile(
              leading: CircleAvatar(
                backgroundColor: i == 0
                    ? AppColors.accentAmber
                    : AppColors.dominantPurple.withOpacity(0.1),
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: i == 0
                        ? AppColors.dominantPurple
                        : AppColors.dominantPurple,
                  ),
                ),
              ),
              title: Text(
                'User ${i + 1}',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${(400 - i * 10)} marks',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              trailing: i == 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentAmber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Top',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
