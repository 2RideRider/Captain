import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:captain_app_flutter/services/graphql_service.dart';

class WalletState {
  final bool isLoading;
  final String? errorMessage;
  final double todayEarnings;
  final int completedRidesCount;
  final double weeklyAverage;
  final double totalEarnings;
  final Map<String, double> weeklyDailyEarnings;
  final List<Map<String, dynamic>> transactions;

  WalletState({
    this.isLoading = false,
    this.errorMessage,
    this.todayEarnings = 0.0,
    this.completedRidesCount = 0,
    this.weeklyAverage = 0.0,
    this.totalEarnings = 0.0,
    this.weeklyDailyEarnings = const {
      'Mon': 0.0,
      'Tue': 0.0,
      'Wed': 0.0,
      'Thu': 0.0,
      'Fri': 0.0,
      'Sat': 0.0,
      'Sun': 0.0,
    },
    this.transactions = const [],
  });

  WalletState copyWith({
    bool? isLoading,
    String? errorMessage,
    double? todayEarnings,
    int? completedRidesCount,
    double? weeklyAverage,
    double? totalEarnings,
    Map<String, double>? weeklyDailyEarnings,
    List<Map<String, dynamic>>? transactions,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      completedRidesCount: completedRidesCount ?? this.completedRidesCount,
      weeklyAverage: weeklyAverage ?? this.weeklyAverage,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      weeklyDailyEarnings: weeklyDailyEarnings ?? this.weeklyDailyEarnings,
      transactions: transactions ?? this.transactions,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final GraphQLService _graphQLService = GraphQLService();

  WalletNotifier() : super(WalletState());

  Future<void> fetchWalletData() async {
    state = state.copyWith(isLoading: true);
    try {
      // 1. Fetch stats
      const String statsQuery = r'''
        query GetDriverStats {
          getDriverStats {
            totalEarnings
            todayEarnings
            completedRides
            rating
          }
        }
      ''';

      // 2. Fetch rides
      const String ridesQuery = r'''
        query GetRides {
          getRides {
            id
            status
            fare
            createdAt
            pickupLocation {
              address
            }
            dropLocation {
              address
            }
          }
        }
      ''';

      final statsResponse = await _graphQLService.performQuery(statsQuery);
      final ridesResponse = await _graphQLService.performQuery(ridesQuery);

      double total = 0.0;
      double today = 0.0;
      int completedCount = 0;

      if (!statsResponse.hasException && statsResponse.data?['getDriverStats'] != null) {
        final stats = statsResponse.data?['getDriverStats'];
        total = (stats['totalEarnings'] as num?)?.toDouble() ?? 0.0;
        today = (stats['todayEarnings'] as num?)?.toDouble() ?? 0.0;
        completedCount = (stats['completedRides'] as num?)?.toInt() ?? 0;
      }

      List<Map<String, dynamic>> transactionsList = [];
      Map<String, double> dailyBreakdown = {
        'Mon': 0.0,
        'Tue': 0.0,
        'Wed': 0.0,
        'Thu': 0.0,
        'Fri': 0.0,
        'Sat': 0.0,
        'Sun': 0.0,
      };

      if (!ridesResponse.hasException && ridesResponse.data?['getRides'] != null) {
        final ridesList = ridesResponse.data?['getRides'] as List<dynamic>;

        final now = DateTime.now();
        // Start of current week (Monday)
        final mondayThisWeek = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeek = DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day);
        final endOfWeek = startOfWeek.add(const Duration(days: 7));

        for (var ride in ridesList) {
          final status = ride['status'] as String?;
          final fare = (ride['fare'] as num?)?.toDouble() ?? 0.0;
          final createdAtStr = ride['createdAt'] as String?;
          final pickupAddress = ride['pickupLocation']?['address'] as String? ?? 'Unknown Pickup';

          if (createdAtStr != null) {
            final createdAt = DateTime.parse(createdAtStr);

            // Populate weekly chart if the ride is in the current week and is completed
            if (status == 'completed' && createdAt.isAfter(startOfWeek) && createdAt.isBefore(endOfWeek)) {
              final dayIndex = createdAt.weekday; // 1 = Mon, ..., 7 = Sun
              final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              final dayName = days[dayIndex - 1];
              dailyBreakdown[dayName] = (dailyBreakdown[dayName] ?? 0.0) + fare;
            }

            // Map to transaction
            transactionsList.add({
              'title': 'Ride completed - $pickupAddress',
              'date': _formatTransactionDate(createdAt),
              'amount': '₹ ${fare.toStringAsFixed(2)}',
              'type': 'Trip',
              'isCredit': true,
              'createdAt': createdAt,
            });
          }
        }
      }

      // Sort transactions by date descending
      transactionsList.sort((a, b) => (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime));

      // Calculate weekly average from total earnings (assuming 4 weeks default)
      double weeklyAvg = total > 0 ? (total / 4.0) : 0.0;
      if (weeklyAvg == 0.0 && total == 0.0) {
        double thisWeekSum = dailyBreakdown.values.reduce((a, b) => a + b);
        weeklyAvg = thisWeekSum;
      }

      state = WalletState(
        todayEarnings: today,
        completedRidesCount: completedCount,
        weeklyAverage: weeklyAvg,
        totalEarnings: total,
        weeklyDailyEarnings: dailyBreakdown,
        transactions: transactionsList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  String _formatTransactionDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dtDate = DateTime(dt.year, dt.month, dt.day);

    final String timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    if (dtDate == today) {
      return 'Today, $timeStr';
    } else if (dtDate == yesterday) {
      return 'Yesterday, $timeStr';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]}, $timeStr';
    }
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier();
});
