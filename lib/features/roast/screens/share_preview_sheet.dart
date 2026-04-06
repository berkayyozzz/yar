import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/roast_share_card.dart';
import '../services/share_service.dart';
import '../../roast/providers/roast_provider.dart';

/// Opens a full-height bottom sheet previewing the shareable card.
Future<void> showSharePreview(
  BuildContext context, {
  required RoastResult roast,
  required double income,
  required double expenses,
  required int streak,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SharePreviewSheet(
      roast: roast,
      income: income,
      expenses: expenses,
      streak: streak,
    ),
  );
}

class _SharePreviewSheet extends StatefulWidget {
  final RoastResult roast;
  final double income;
  final double expenses;
  final int streak;

  const _SharePreviewSheet({
    super.key,
    required this.roast,
    required this.income,
    required this.expenses,
    required this.streak,
  });

  @override
  State<_SharePreviewSheet> createState() => _SharePreviewSheetState();
}

class _SharePreviewSheetState extends State<_SharePreviewSheet> {
  final _cardKey = GlobalKey();
  bool _sharing = false;
  bool _saving = false;

  RenderRepaintBoundary? _getBoundary() {
    final ctx = _cardKey.currentContext;
    if (ctx == null) return null;
    final obj = ctx.findRenderObject();
    if (obj is RenderRepaintBoundary) return obj;
    return null;
  }

  Future<void> _onShare() async {
    final boundary = _getBoundary();
    if (boundary == null) return;
    setState(() => _sharing = true);
    try {
      await ShareService.shareCard(
        boundary: boundary,
        score: widget.roast.score,
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _onSave() async {
    final boundary = _getBoundary();
    if (boundary == null) return;
    setState(() => _saving = true);
    try {
      await ShareService.saveCard(boundary: boundary);
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('💾 Image saved to documents!'),
            backgroundColor: const Color(0xFF00FF7F),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _onCopyText() {
    HapticFeedback.mediumImpact();
    final text =
        '${widget.roast.roastMessage}\n\n📊 Financial Score: ${widget.roast.score}/100\n${widget.roast.scoreReason}\n\n#SmartBudgetRoast #GetJudged';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('📋 Roast text copied to clipboard!'),
        backgroundColor: const Color(0xFFFF007F),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    // Card preview height: maintain 9:16 ratio with a max height
    final previewH = (screenH * 0.62).clamp(0.0, screenH * 0.65);
    final previewW = previewH * (9 / 16);

    return Container(
      height: screenH * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // ── Drag handle
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 8),
            child: _DragHandle(),
          ),

          // ── Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Your Roast Card',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  'Story ready 9:16',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white38,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Card preview
          Expanded(
            child: Center(
              child: Container(
                width: previewW + 8,
                height: previewH + 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFF007F).withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF007F).withValues(alpha: 0.2),
                      blurRadius: 32,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: 1080,
                        height: 1920,
                        child: RoastShareCard(
                          roastMessage: widget.roast.roastMessage,
                          score: widget.roast.score,
                          scoreReason: widget.roast.scoreReason,
                          personalityTitle: widget.roast.personalityTitle,
                          income: widget.income,
                          expenses: widget.expenses,
                          streak: widget.streak,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Primary: Share
                _ActionButton(
                  label: _sharing ? 'Generating…' : 'Share to… 🔥',
                  backgroundColor: const Color(0xFFFF007F),
                  foregroundColor: Colors.white,
                  loading: _sharing,
                  onTap: _sharing ? null : _onShare,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: _saving ? 'Saving…' : 'Save Image 💾',
                        backgroundColor:
                            const Color(0xFF00FF7F).withValues(alpha: 0.12),
                        foregroundColor: const Color(0xFF00FF7F),
                        loading: _saving,
                        onTap: _saving ? null : _onSave,
                        border: Border.all(
                            color: const Color(0xFF00FF7F).withValues(alpha: 0.4)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        label: 'Copy Text 📋',
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.05),
                        foregroundColor: Colors.white60,
                        onTap: _onCopyText,
                        border: Border.all(color: Colors.white12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}

// ── Reusable action button ────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;
  final bool loading;
  final BoxBorder? border;

  const _ActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.onTap,
    this.loading = false,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: border,
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.inter(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }
}

// ── Drag handle ───────────────────────────────────────────────────────────────
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
