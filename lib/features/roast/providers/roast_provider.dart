import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/providers/transaction_provider.dart';

enum RoastIntensity { mild, savage, nuclear }

class RoastIntensityNotifier extends Notifier<RoastIntensity> {
  @override
  RoastIntensity build() => RoastIntensity.savage;

  void updateIntensity(RoastIntensity newIntensity) {
    state = newIntensity;
  }
}

final roastIntensityProvider = NotifierProvider<RoastIntensityNotifier, RoastIntensity>(RoastIntensityNotifier.new);

class RoastResult {
  final int score;
  final String roastMessage;
  final String scoreReason;
  final String personalityTitle;
  final RoastIntensity intensity;
  final bool isEmpty;

  RoastResult(this.score, this.roastMessage, this.scoreReason,
      {this.personalityTitle = 'The Ghost',
      this.intensity = RoastIntensity.savage,
      this.isEmpty = false});
}

final _random = Random();

// ── Category-specific roasts ──────────────────────────────────────────────────
const _categoryRoasts = {
  'Coffee': [
    '"You\'re 90% caffeine. Your blood type is Arabica. Stop Buying Coffee."',
    '"Are you a human or a high-pressure espresso machine? \$50 on coffee??"',
    '"You spend more on beans than on your future. Iconic."',
    '"Baristas know your order, but your bank doesn\'t know your savings. Tragic."',
    '"Imagine if you invested the money you spend on iced lattes. You\'d have like... two more lattes."',
    '"Your heart rate is 120bpm but your net worth is dropping faster."',
  ],
  'Food': [
    '"Your stomach is a black hole for your savings. UberEats is not a hobby."',
    '"Eating like a king, budgeting like a peasant. Pick one."',
    '"50% of your income went to your gut. At least you\'ll die full and broke."',
    '"You literally eat your money. Do you poop gold? Because you should."',
    '"DoorDash drivers know where you live better than your own family."',
    '"You ordered a \$20 burger and paid \$15 in delivery fees. Financial genius at work."',
  ],
  'Shopping': [
    '"Retail therapy is not therapy if it causes a financial breakdown."',
    '"Buying things you don\'t need with money you don\'t have. Classic."',
    '"Your closet is full, your wallet is empty. Math doesn\'t check out."',
    '"Amazon Prime is not a personality trait. Stop clicking Buy Now."',
    '"You just bought another pair of shoes to walk to your second job."',
    '"Are you compensating for emotional emptiness with expensive sweaters?"',
  ],
  'Entertainment': [
    '"Having fun is expensive. Being broke is free. Choose wisely."',
    '"Netflix, Spotify, Gaming... you\'re entertained but economically doomed."',
    '"You pay to watch other people live while your own life falls apart financially."',
    '"Oh look, another Steam sale you couldn\'t resist. Go play outside, it\'s free."',
  ],
  'Transport': [
    '"Uber everywhere? Do your legs not work, or do you just hate having money?"',
    '"You spend more time in Ubers than you do working to pay for them."',
    '"Gas prices are high, but your financial irresponsibility is higher."',
  ],
  'Health': [
    '"Getting sick is too expensive. Have you tried simply not needing medicine?"',
    '"Taking care of yourself is great, but going bankrupt for vitamins is wild."',
  ],
  'Rent': [
    '"Ah, rent. Paying someone else\'s mortgage while crying in a 1-bedroom apartment."',
    '"At least you have a roof over your financially ruined head."',
  ],
  'Other': [
    '"Miscellaneous spending? Just say you lost the money, it\'s less embarrassing."',
    '"You don\'t even know what you bought, do you? Incredible levels of denial."',
  ]
};

// ── Personality Titles ────────────────────────────────────────────────────────
const _personalities = {
  'Coffee': 'The Caffeine Addict ☕',
  'Food': 'The Gourmet Broke 🍔',
  'Shopping': 'The Impulse Buyer 🛍️',
  'Entertainment': 'The Fun-Haver 🎮',
  'Transport': 'The Uber VIP 🚗',
  'Health': 'The Medical Bill 💊',
  'Rent': 'The Tenant 🏠',
  'Other': 'The Mystery Spender 💸',
  'Saving': 'The Zen Monk 🧘',
  'Chaos': 'The Financial Disaster 🌪️',
  'None': 'The Invisible 👻',
};

// ── Fallback roasts ──────────────────────────────────────────────────────────

const _emptyRoasts = [
  '"You\'re financially invisible right now 👻\nAdd something. I dare you."',
  '"No data = no judgment.\nBut also no budget. Fix that."',
  '"Schrodinger\'s budget: both broke and rich until you tell me."',
  '"I\'d roast you but you haven\'t given me anything to work with yet 💀"',
  '"Your wallet is a mystery. Even to itself."',
  '"Are you hiding your expenses from me because you know they are bad?"',
];

const _noIncomeRoasts = [
  '"Zero income, nonzero spending. You\'re cosplaying bankruptcy."',
  '"Spending without earning? Bold strategy. Let\'s see how that works out."',
  '"The audacity. The nerve. The financial recklessness."',
  '"You are running on fumes and credit card debt, aren\'t you?"',
  '"Who is funding this lifestyle? Because it\'s definitely not you."',
];

List<String> _overBudgetRoasts(double ratio) => [
      '"You spent ${(ratio * 100).toStringAsFixed(0)}% of your income. Please explain yourself."',
      '"Living ${(ratio * 100 - 100).toStringAsFixed(0)}% beyond your means. Iconic. Tragic."',
      '"At this rate, your emergency fund IS the debt."',
      '"You owe more than you make. That\'s not a budget. That\'s a cry for help."',
      '"Mathematics called requested a restraining order against your spending habits."',
      '"Your bank account is sweating right now. ${(ratio * 100).toStringAsFixed(0)}% consumed!"',
    ];

const _dangerRoasts = [
  '"You make money. You just don\'t respect it."',
  '"85% spent. One unexpected bill away from a full breakdown."',
  '"You technically have savings. Psychologically, you\'re doomed."',
  '"You\'re sprinting toward zero and calling it living."',
  '"At this point, you\'re just playing financial chicken with the end of the month."',
  '"I can hear your credit score crying from here."',
];

const _midRoasts = [
  '"You\'re managing. Barely. But managing. Don\'t push it."',
  '"You spend like someone who loves UberEats but hates being in debt. Pick one."',
  '"60% spent on non-essentials. Try cutting that by 20%. I suspect you won\'t."',
  '"Not terrible, not great. The beige of financial behavior."',
  '"You\'re one impulse purchase away from a bad month."',
  '"You survive each month through sheer luck rather than actual budgeting."',
];

const _goodRoasts = [
  '"You have money left? Suspicious behavior."',
  '"Saving over half your income? Boring, but statistically impressive."',
  '"Look at you, being an adult. Disgusting."',
  '"You actually have a financial future. Nerd."',
  '"Score: high. Personality: still questionable. Keep saving."',
  '"Saving money is great, but don\'t forget you are allowed to have some fun. Actually, never mind. Keep hoarding."',
];

const shareMessages = [
  'Post your shame 🔥',
  'Expose yourself 😈',
  'Show this to your friends 💀',
  'Let the world judge you 👀',
  'Tweet your financial ruin 💸',
];

const loadingMessages = [
  'Analyzing your bad decisions…',
  'Counting your mistakes…',
  'Judging you silently…',
  'Processing the damage…',
];

String pickShare() => shareMessages[_random.nextInt(shareMessages.length)];
String pickLoading() => loadingMessages[_random.nextInt(loadingMessages.length)];
String _pick(List<String> list) => list[_random.nextInt(list.length)];

final roastProvider = Provider<RoastResult>((ref) {
  final summary = ref.watch(summaryProvider);
  final catSummary = ref.watch(categorySummaryProvider);
  final intensity = ref.watch(roastIntensityProvider);

  final income = summary['income'] ?? 0;
  final expenses = summary['expenses'] ?? 0;

  if (income == 0 && expenses == 0) {
    return RoastResult(0, _pick(_emptyRoasts), 'No transactions yet',
        personalityTitle: _personalities['None']!,
        intensity: intensity,
        isEmpty: true);
  }

  // ── 1. Determine dominant category for specific roast
  String? topCategory;
  double maxAmount = 0;
  for (var entry in catSummary.entries) {
    if (entry.value.amount > maxAmount) {
      maxAmount = entry.value.amount;
      topCategory = entry.key;
    }
  }

  // ── 2. Determine personality
  String personality = _personalities['Chaos']!;
  if (expenses / (income > 0 ? income : 1) < 0.4) {
    personality = _personalities['Saving']!;
  } else if (topCategory != null &&
      (catSummary[topCategory]?.amount ?? 0) > (expenses * 0.4)) {
    personality = _personalities[topCategory] ?? _personalities['Chaos']!;
  }

  // ── 3. Pick base roast
  String message = '';
  if (topCategory != null &&
      _categoryRoasts.containsKey(topCategory) &&
      _random.nextBool()) {
    message = _pick(_categoryRoasts[topCategory]!);
  } else {
    // Fallback to ratio roasts
    if (income == 0 && expenses > 0) {
      message = _pick(_noIncomeRoasts);
    } else {
      final ratio = expenses / (income > 0 ? income : 1);
      if (ratio > 1.0)
        message = _pick(_overBudgetRoasts(ratio));
      else if (ratio > 0.8)
        message = _pick(_dangerRoasts);
      else if (ratio > 0.5)
        message = _pick(_midRoasts);
      else
        message = _pick(_goodRoasts);
    }
  }

  // ── 4. Apply Intensity Modifiers
  if (intensity == RoastIntensity.nuclear) {
    message = message
            .toUpperCase()
            .replaceAll('"', '')
            .replaceAll('.', ' !!!')
            .replaceAll('?', ' ???') +
        ' ☢️ NUCLEAR DAMAGE ☢️';
  } else if (intensity == RoastIntensity.mild) {
    message = message
        .replaceAll('"', '')
        .replaceAll('💀', '🙏')
        .replaceAll('doomed', 'challenging')
        .replaceAll('disgusting', 'unique')
        .replaceAll('cry for help', 'learning curve');
    message = '"Look, $message"';
  }

  // ── 5. Final Score / Reason
  final ratio = expenses / (income > 0 ? income : 1);
  int score = 0;
  String reason = '';

  if (income == 0) {
    score = 8;
    reason = 'No income recorded';
  } else if (ratio > 1.0) {
    score = 15;
    reason = 'Spending ${(ratio * 100).toStringAsFixed(0)}% of income';
  } else if (ratio > 0.8) {
    score = 38;
    reason = '${(ratio * 100).toStringAsFixed(0)}% spent — danger zone';
  } else if (ratio > 0.5) {
    score = 65;
    reason = 'Moderate spending ratio';
  } else {
    score = 88;
    reason = 'Low spending ratio — solid';
  }

  return RoastResult(score, message, reason,
      personalityTitle: personality, intensity: intensity);
});
