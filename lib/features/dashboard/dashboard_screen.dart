import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'providers/transaction_provider.dart' as p;
import 'widgets/add_transaction_sheet.dart';
import '../roast/providers/roast_provider.dart' as rp;
import '../roast/screens/share_preview_sheet.dart';
import '../roast/widgets/nuclear_alert_dialog.dart';
import '../roast/providers/badge_provider.dart';
import 'providers/settings_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  // ── Glow animation ───────────────────────────────────────────────────────
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // ── Progress bar animation ───────────────────────────────────────────────
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  // ── FAB loading state ────────────────────────────────────────────────────
  bool _fabLoading = false;
  String _fabLabel = '+ Roast Me';
  String _shareLabel = 'Post your shame 🔥';

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );
    _progressController.forward();
  }

  void _refreshProgress() {
    _progressController.reset();
    _progressController.forward();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _onFabPressed(BuildContext context) async {
    // Haptic + loading state
    HapticFeedback.mediumImpact();
    setState(() {
      _fabLoading = true;
      _fabLabel = rp.pickLoading();
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() {
      _fabLoading = false;
      _fabLabel = '+ Roast Me';
    });

    // Refresh roast randomly
    ref.invalidate(rp.roastProvider);

    if (!mounted) return;
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const AddTransactionSheet(),
    ).then((wantsNuclear) {
      _refreshProgress();
      if (wantsNuclear == true && mounted) {
        showNuclearAlert(context);
      }
    });
  }

  void _showSettingsSheet(BuildContext context, WidgetRef ref) {
    final limit = ref.read(settingsProvider);
    final ctrl = TextEditingController(text: limit?.toString() ?? '');
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Set Monthly Budget', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Budget Limit (\$)',
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final val = double.tryParse(ctrl.text);
                ref.read(settingsProvider.notifier).setBudgetLimit(val);
                Navigator.pop(ctx);
              },
              child: const Text('Save Limit'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                ref.read(settingsProvider.notifier).setBudgetLimit(null);
                Navigator.pop(ctx);
              },
              child: const Text('Clear Limit', style: TextStyle(color: Colors.redAccent)),
            ),
            const Divider(color: Colors.white24, height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (confirmCtx) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('Are you sure?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    content: const Text(
                      'Tüm harcamaları sıfırlamak (Clear All Data) istediğinize emin misiniz? Bu işlem geri alınamaz ve tüm verileriniz silinir.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(confirmCtx),
                        child: const Text('İptal (Cancel)', style: TextStyle(color: Colors.white54)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                        onPressed: () {
                          ref.read(p.transactionsProvider.notifier).clearAllTransactions();
                          Navigator.pop(confirmCtx);
                          // Trigger haptic feedback to confirm
                          HapticFeedback.heavyImpact();
                        },
                        child: const Text('Evet, Sıfırla (Reset)'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Tüm Harcamaları Sıfırla (Reset All)', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roast = ref.watch(rp.roastProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('dashboard_title'.tr(),
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white)),
        centerTitle: false,
        actions: [
          _buildIntensityToggle(ref),
          Consumer(
            builder: (context, ref, _) {
              final streak = ref.watch(p.streakProvider);
              if (streak == 0) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(right: 8, top: 12, bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9900).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFF9900).withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '$streak Day',
                      style: const TextStyle(
                        color: Color(0xFFFF9900),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white54),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showSettingsSheet(context, ref);
            },
          ),
        ],
      ),
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _buildSummaryCard(context, ref, roast),
              const SizedBox(height: 20),
              if (!roast.isEmpty) _buildCategorySummary(context, ref),
              if (!roast.isEmpty) const SizedBox(height: 20),
              _buildRoastSection(roast),
              const SizedBox(height: 20),
              if (!roast.isEmpty) _buildShareButton(context, roast),
              const SizedBox(height: 32),
              _buildBadgesSection(context, ref),
              const SizedBox(height: 32),
              _buildShameList(context, ref),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  // ── Summary Card ─────────────────────────────────────────────────────────
  Widget _buildSummaryCard(BuildContext context, WidgetRef ref, rp.RoastResult roast) {
    final summary = ref.watch(p.summaryProvider);
    final income = summary['income'] ?? 0.0;
    final expenses = summary['expenses'] ?? 0.0;
    final targetRatio = income > 0 ? (expenses / income).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          // Income / Expenses pills
          Row(
            children: [
              _StatPill(
                label: 'income'.tr(),
                value: '\$${income.toStringAsFixed(2)}',
                color: const Color(0xFF00FF7F),
              ),
              const SizedBox(width: 12),
              _StatPill(
                label: 'expenses'.tr(),
                value: '\$${expenses.toStringAsFixed(2)}',
                color: const Color(0xFFFF3355),
              ),
            ],
          ),
          const SizedBox(height: 22),
          // ── Animated progress bar ────────────────────────────────────
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, _) {
              final animated = targetRatio * _progressAnimation.value;
              final barColor = _progressColor(animated);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('spent'.tr(),
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12)),
                      Text('${(animated * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                              color: barColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: animated,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: LinearGradient(
                              colors: animated < 0.5
                                  ? [const Color(0xFF00FF7F), const Color(0xFF00CC66)]
                                  : animated < 0.8
                                      ? [const Color(0xFFFFDD00), const Color(0xFFFF9900)]
                                      : [const Color(0xFFFF3355), const Color(0xFFFF007F)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          // ── Remaining ────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('left'.tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white60)),
              Text(
                '\$${(summary['left'] ?? 0.0).toStringAsFixed(2)}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: (summary['left'] ?? 0.0) >= 0
                        ? Colors.white
                        : const Color(0xFFFF3355)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _progressColor(double ratio) {
    if (ratio < 0.5) return const Color(0xFF00FF7F);
    if (ratio < 0.8) return const Color(0xFFFFDD00);
    return const Color(0xFFFF3355);
  }

  // ── Intensity Toggle ─────────────────────────────────────────────────────
  Widget _buildIntensityToggle(WidgetRef ref) {
    final intensity = ref.watch(rp.roastIntensityProvider);
    final (icon, color, label) = switch (intensity) {
      rp.RoastIntensity.mild => ('🌱', Colors.greenAccent, 'Mild'),
      rp.RoastIntensity.savage => ('💀', Colors.orangeAccent, 'Savage'),
      rp.RoastIntensity.nuclear => ('☢️', Colors.redAccent, 'Nuclear'),
      _ => ('🌱', Colors.greenAccent, 'Mild'),
    };

    return IconButton(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 15)),
          Text(label,
              style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
      onPressed: () {
        HapticFeedback.mediumImpact();
        final next = switch (intensity) {
          rp.RoastIntensity.mild => rp.RoastIntensity.savage,
          rp.RoastIntensity.savage => rp.RoastIntensity.nuclear,
          rp.RoastIntensity.nuclear => rp.RoastIntensity.mild,
          _ => rp.RoastIntensity.mild,
        };
        ref.read(rp.roastIntensityProvider.notifier).updateIntensity(next);
      },
    );
  }

  // ── Badges Section ────────────────────────────────────────────────────────
  Widget _buildBadgesSection(BuildContext context, WidgetRef ref) {
    final badges = ref.watch(badgesProvider);
    if (badges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Achievements',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final badge = badges[index];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(badge.emoji, style: const TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            badge.title,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            badge.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            badge.isUnlocked ? 'Unlocked!' : 'Locked 🔒',
                            style: TextStyle(
                              color: badge.isUnlocked ? const Color(0xFF00FF7F) : Colors.white38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 100,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: badge.isUnlocked ? const Color(0xFF1E2A22) : const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: badge.isUnlocked ? const Color(0xFF00FF7F).withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        badge.emoji,
                        style: TextStyle(
                          fontSize: 28,
                          color: badge.isUnlocked ? Colors.white : Colors.white24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        badge.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badge.isUnlocked ? Colors.white : Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Shame List (History) ──────────────────────────────────────────────────
  Widget _buildShameList(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(p.transactionsProvider);
    if (transactions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Text(
                'Hall of Shame'.tr(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              const Text('📜', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final t = transactions[index];
            final isExpense = t.type == 'expense' || t.type == 'debt';
            
            // Emoji map (matching providers)
            const emojis = {
              'Food': '🍔',
              'Coffee': '☕',
              'Shopping': '🛍️',
              'Transport': '🚗',
              'Entertainment': '🎮',
              'Health': '💊',
              'Rent': '🏠',
              'Other': '💸',
            };

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isExpense 
                        ? Colors.redAccent.withValues(alpha: 0.1) 
                        : Colors.greenAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      emojis[t.category] ?? (isExpense ? '💸' : '💰'),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isExpense ? 'Bye-bye money' : 'Payday!',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isExpense ? '-' : '+'}\$${t.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: isExpense ? Colors.redAccent : Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd').format(t.date),
                        style: const TextStyle(color: Colors.white24, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Category Summary ─────────────────────────────────────────────────────
  Widget _buildCategorySummary(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(p.categorySummaryProvider);
    if (categories.isEmpty) return const SizedBox.shrink();

    // Sort by amount descending
    final list = categories.entries.toList()
      ..sort((a, b) => b.value.amount.compareTo(a.value.amount));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Top Damage',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ).tr(),
        ),
        SizedBox(
          height: 85,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final entry = list[index];
              return Container(
                width: 110,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(entry.value.emoji, style: const TextStyle(fontSize: 16)),
                        const Spacer(),
                        Text(
                          'x${entry.value.count}',
                          style: const TextStyle(color: Colors.white38, fontSize: 10),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '\$${entry.value.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      entry.key,
                      style: const TextStyle(color: Colors.white30, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Roast Card ───────────────────────────────────────────────────────────
  Widget _buildRoastSection(rp.RoastResult roast) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF181818),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: roast.isEmpty
                  ? Colors.white12
                  : const Color(0xFFFF007F).withValues(alpha: 0.7),
              width: 1.5,
            ),
            boxShadow: roast.isEmpty
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFFFF007F)
                          .withValues(alpha: 0.18 * _glowAnimation.value),
                      blurRadius: 28 * _glowAnimation.value,
                      spreadRadius: 2,
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(24),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              if (!roast.isEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF007F).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFF007F).withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    roast.personalityTitle,
                    style: const TextStyle(
                      color: Color(0xFFFF007F),
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'ai_roast'.tr(),
                        style: TextStyle(
                          color: roast.isEmpty
                              ? Colors.white30
                              : const Color(0xFFFF007F),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1.4,
                        ),
                      ),
                      if (!roast.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Text('😈', style: TextStyle(fontSize: 14)),
                        ),
                    ],
                  ),
                  if (!roast.isEmpty) _ScoreBadge(score: roast.score),
                ],
              ),
          const SizedBox(height: 18),
          // Roast message
          Text(
            roast.roastMessage,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: roast.isEmpty ? 16 : 20,
              color: roast.isEmpty ? Colors.white30 : Colors.white,
              height: 1.4,
            ),
          ),
          if (!roast.isEmpty) ...[
            const SizedBox(height: 18),
            _ScoreBar(score: roast.score, reason: roast.scoreReason),
          ],
        ],
      ),
    );
  }

  // ── Share Button ─────────────────────────────────────────────────────────
  Widget _buildShareButton(BuildContext context, rp.RoastResult roast) {
    final summary = ref.read(p.summaryProvider);
    final streak = ref.read(p.streakProvider);
    return GestureDetector(
      onTap: () async {
        HapticFeedback.heavyImpact();
        setState(() => _shareLabel = rp.pickShare());
        await showSharePreview(
          context,
          roast: roast,
          income: summary['income'] ?? 0.0,
          expenses: summary['expenses'] ?? 0.0,
          streak: streak,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFFF007F), width: 1.5),
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFF007F).withValues(alpha: 0.18),
              const Color(0xFFFF007F).withValues(alpha: 0.06),
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.ios_share_rounded,
                color: Color(0xFFFF007F), size: 18),
            const SizedBox(width: 8),
            Text(
              _shareLabel,
              style: const TextStyle(
                  color: Color(0xFFFF007F),
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  // ── FAB ──────────────────────────────────────────────────────────────────
  Widget _buildFab(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _fabLoading
            ? const Color(0xFF00CC66)
            : const Color(0xFF00FF7F),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF7F).withValues(alpha: 0.3),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _fabLoading ? null : () => _onFabPressed(context),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_fabLoading)
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Text('💀', style: TextStyle(fontSize: 18)),
                  ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _fabLabel,
                    key: ValueKey(_fabLabel),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stat Pill ────────────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatPill(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 11)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

// ── Score Badge ──────────────────────────────────────────────────────────────
class _ScoreBadge extends StatelessWidget {
  final int score;
  const _ScoreBadge({required this.score});

  Color get _color {
    if (score >= 80) return const Color(0xFF00FF7F);
    if (score >= 50) return const Color(0xFFFFDD00);
    return const Color(0xFFFF007F);
  }

  String get _emoji {
    if (score >= 80) return '🟢';
    if (score >= 50) return '🟡';
    return '🔴';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withValues(alpha: 0.35)),
      ),
      child: Text('$_emoji $score/100',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: _color)),
    );
  }
}

// ── Score Bar with reason ────────────────────────────────────────────────────
class _ScoreBar extends StatelessWidget {
  final int score;
  final String reason;
  const _ScoreBar({required this.score, required this.reason});

  Color get _color {
    if (score >= 80) return const Color(0xFF00FF7F);
    if (score >= 50) return const Color(0xFFFFDD00);
    return const Color(0xFFFF007F);
  }

  String get _label {
    if (score >= 80) return 'Financially Disciplined';
    if (score >= 65) return 'Getting There';
    if (score >= 40) return 'Financially Chaotic';
    return 'Economically Reckless';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.white10, height: 1),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('financial_score'.tr(),
                style:
                    const TextStyle(color: Colors.white38, fontSize: 11)),
            Text(reason,
                style: TextStyle(
                    color: _color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 6,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(_color),
          ),
        ),
        const SizedBox(height: 5),
        Text(_label,
            style: TextStyle(
                color: _color.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
