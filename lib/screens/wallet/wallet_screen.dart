import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:captain_app_flutter/providers/auth_provider.dart';
import 'package:captain_app_flutter/providers/wallet_provider.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(walletProvider.notifier).fetchWalletData();
      ref.read(authProvider.notifier).refreshProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final walletState = ref.watch(walletProvider);
    final user = authState.user;
    final balance = user?.walletBalance ?? 0.0;

    final filteredTransactions = _selectedFilter == 'All'
        ? walletState.transactions
        : walletState.transactions.where((t) => t['type'] == _selectedFilter).toList();

    if (walletState.isLoading && walletState.transactions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'My Wallet',
            style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 22),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'My Wallet',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium Diagonal Gradient Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF004D40), // Dark Teal
                    Color(0xFF00796B), // Teal
                    Color(0xFF00C853), // Emerald Green
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00796B).withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Stack(
                children: [
                  // Abstract geometric background pattern
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Opacity(
                      opacity: 0.1,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    bottom: -80,
                    child: Opacity(
                      opacity: 0.05,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL BALANCE',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹ ${balance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Withdrawal request of ₹ ${balance.toStringAsFixed(2)} submitted successfully.'),
                                    backgroundColor: const Color(0xFF00C853),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF004D40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_upward, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Withdraw to Bank',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Statistics Grid (Enhanced visual layout)
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Today\'s Earnings',
                    value: '₹ ${walletState.todayEarnings.toStringAsFixed(2)}',
                    icon: Icons.monetization_on_outlined,
                    color: const Color(0xFF0284C7), // Sky Blue
                    bgColor: const Color(0xFFF0F9FF),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Completed Rides',
                    value: '${walletState.completedRidesCount} Rides',
                    icon: Icons.local_taxi_outlined,
                    color: const Color(0xFFD97706), // Amber/Orange
                    bgColor: const Color(0xFFFFFBEB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Weekly Average',
                    value: '₹ ${walletState.weeklyAverage.toStringAsFixed(2)}',
                    icon: Icons.analytics_outlined,
                    color: const Color(0xFF7C3AED), // Violet
                    bgColor: const Color(0xFFF5F3FF),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Captain Rating',
                    value: '${user?.ratings ?? 0.0} ★',
                    icon: Icons.star_outline_rounded,
                    color: const Color(0xFFE11D48), // Rose
                    bgColor: const Color(0xFFFFF1F2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Weekly Earnings Custom Bar Chart
            _buildWeeklyChart(walletState.weeklyDailyEarnings),
            const SizedBox(height: 24),

            // Transactions Header & Filter chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View All',
                    style: TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Filter Chips
            Row(
              children: ['All', 'Trip', 'Cashout'].map((filter) {
                final isSelected = _selectedFilter == filter;
                final displayLabel = filter == 'Trip'
                    ? 'Trips'
                    : filter == 'Cashout'
                        ? 'Cashouts'
                        : filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      displayLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF00C853),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Transaction List
            filteredTransactions.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Center(
                      child: Text(
                        'No transactions match the filter.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredTransactions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final tx = filteredTransactions[index];
                      final title = tx['title'] as String;
                      final date = tx['date'] as String;
                      final amount = tx['amount'] as String;
                      final isCredit = tx['isCredit'] as bool;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.015),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isCredit
                                        ? const Color(0xFFECFDF5)
                                        : const Color(0xFFFEF2F2),
                                    radius: 20,
                                    child: Icon(
                                      isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                                      color: isCredit ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFF0F172A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          date,
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${isCredit ? "+" : "-"} $amount',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isCredit ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(Map<String, double> dailyEarnings) {
    double maxVal = dailyEarnings.values.fold(0.0, (m, e) => e > m ? e : m);
    final double maxEarning = maxVal > 0 ? maxVal : 100.0;
    final double chartHeight = 140.0;

    double weeklySum = dailyEarnings.values.fold(0.0, (sum, val) => sum + val);

    final now = DateTime.now();
    final mondayThisWeek = now.subtract(Duration(days: now.weekday - 1));
    final sundayThisWeek = mondayThisWeek.add(const Duration(days: 6));
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekRangeStr = 'Mon, ${months[mondayThisWeek.month - 1]} ${mondayThisWeek.day} - Sun, ${months[sundayThisWeek.month - 1]} ${sundayThisWeek.day}';

    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayDayName = daysOfWeek[now.weekday - 1];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Earnings',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    weekRangeStr,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Total: ₹ ${weeklySum.toStringAsFixed(0)}',
                  style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: chartHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dailyEarnings.entries.map((entry) {
                final day = entry.key;
                final amount = entry.value;
                final double barHeight = (amount / maxEarning) * (chartHeight - 45);
                final isToday = day == todayDayName;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '₹${amount.toInt()}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday ? const Color(0xFF00C853) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: barHeight,
                        width: 14,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isToday
                                ? [const Color(0xFF00C853), const Color(0xFF69F0AE)]
                                : [const Color(0xFF94A3B8), const Color(0xFFCBD5E1)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        day,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                          color: isToday ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
