import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/providers/transaction_provider.dart';

class Badge {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final bool isUnlocked;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.isUnlocked = false,
  });

  Badge copyWith({bool? isUnlocked}) {
    return Badge(
      id: id,
      title: title,
      description: description,
      emoji: emoji,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

final badgesProvider = Provider<List<Badge>>((ref) {
  final summary = ref.watch(summaryProvider);
  final catSummary = ref.watch(categorySummaryProvider);
  final streak = ref.watch(streakProvider);

  final List<Badge> allBadges = [
    Badge(
      id: 'coffee_clown',
      title: 'Coffee Clown',
      description: 'Buy coffee more than 3 times',
      emoji: '🤡',
    ),
    Badge(
      id: 'gourmet_broke',
      title: 'Gourmet Broke',
      description: 'Spend over \$100 on Food',
      emoji: '🍔',
    ),
    Badge(
      id: 'serial_spender',
      title: 'Serial Spender',
      description: 'Spend money 5 days in a row',
      emoji: '💸',
    ),
    Badge(
      id: 'shopping_addict',
      title: 'Shopaholic',
      description: 'Spend over \$200 on Shopping',
      emoji: '🛍️',
    ),
    Badge(
      id: 'gamer_ruin',
      title: 'Gamer Ruin',
      description: 'More than 2 Entertainment purchases',
      emoji: '🎮',
    ),
    Badge(
      id: 'doctor_wealthy',
      title: 'Fragile Wallet',
      description: 'Spend over \$50 on Health/Pharmacy',
      emoji: '💊',
    ),
    Badge(
      id: 'uber_vip',
      title: 'Uber VIP',
      description: 'More than 3 Transport expenses',
      emoji: '🚗',
    ),
    Badge(
      id: 'rent_crier',
      title: 'Rent Crier',
      description: 'Pay Rent (Ouch!)',
      emoji: '🏠',
    ),
    Badge(
      id: 'sugar_daddy',
      title: 'Sugar Daddy',
      description: 'Spend over \$500 total',
      emoji: '💎',
    ),
    Badge(
      id: 'broke_king',
      title: 'Broke King',
      description: 'Spend 100% of your income',
      emoji: '👑',
    ),
    Badge(
      id: 'zen_monk',
      title: 'Zen Monk',
      description: 'Keep spending below 30% of income',
      emoji: '🧘‍♂️',
    ),
  ];

  final income = summary['income'] ?? 0.0;
  final expenses = summary['expenses'] ?? 0.0;
  final ratio = income > 0 ? expenses / income : 1.0;

  bool isCoffeeClown = (catSummary['Coffee']?.count ?? 0) > 3;
  bool isGourmetBroke = (catSummary['Food']?.amount ?? 0) > 100;
  bool isSerialSpender = streak >= 5;
  bool isZenMonk = income > 0 && ratio < 0.3;

  bool isShoppingAddict = (catSummary['Shopping']?.amount ?? 0) > 200;
  bool isGamerRuin = (catSummary['Entertainment']?.count ?? 0) > 2;
  bool isDoctorWealthy = (catSummary['Health']?.amount ?? 0) > 50;
  bool isUberVip = (catSummary['Transport']?.count ?? 0) > 3;
  bool isRentCrier = (catSummary['Rent']?.count ?? 0) >= 1;
  bool isSugarDaddy = expenses > 500;
  bool isBrokeKing = income > 0 && expenses >= income;

  return allBadges.map((b) {
    if (b.id == 'coffee_clown' && isCoffeeClown) return b.copyWith(isUnlocked: true);
    if (b.id == 'gourmet_broke' && isGourmetBroke) return b.copyWith(isUnlocked: true);
    if (b.id == 'serial_spender' && isSerialSpender) return b.copyWith(isUnlocked: true);
    if (b.id == 'shopping_addict' && isShoppingAddict) return b.copyWith(isUnlocked: true);
    if (b.id == 'gamer_ruin' && isGamerRuin) return b.copyWith(isUnlocked: true);
    if (b.id == 'doctor_wealthy' && isDoctorWealthy) return b.copyWith(isUnlocked: true);
    if (b.id == 'uber_vip' && isUberVip) return b.copyWith(isUnlocked: true);
    if (b.id == 'rent_crier' && isRentCrier) return b.copyWith(isUnlocked: true);
    if (b.id == 'sugar_daddy' && isSugarDaddy) return b.copyWith(isUnlocked: true);
    if (b.id == 'broke_king' && isBrokeKing) return b.copyWith(isUnlocked: true);
    if (b.id == 'zen_monk' && isZenMonk) return b.copyWith(isUnlocked: true);
    return b;
  }).toList();
});
