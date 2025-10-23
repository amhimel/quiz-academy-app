import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/global_leaderboard_provider.dart';

class LeaderBoardScreen extends ConsumerStatefulWidget {
  const LeaderBoardScreen({super.key});

  @override
  ConsumerState<LeaderBoardScreen> createState() =>
      _LeaderBoardScreenState();
}

class _LeaderBoardScreenState
    extends ConsumerState<LeaderBoardScreen> {
  LBPeriod _period = LBPeriod.weekly;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(globalLeaderboardProvider(_period));

    return Scaffold(
      backgroundColor: const Color(0xFFF3EBDD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              const Text(
                'Leaderboard',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),

              // Segmented control
              _PeriodSegment(
                period: _period,
                onChanged: (p) => setState(() => _period = p),
              ),

              const SizedBox(height: 12),
              Expanded(
                child: async.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Failed: $e')),
                  data: (list) {
                    if (list.isEmpty) {
                      return const Center(child: Text('No data for this period.'));
                    }

                    final top3 = list.take(3).toList(growable: false);
                    final List<GlobalLBEntry> rest =
                    list.length > 3 ? list.sublist(3) : <GlobalLBEntry>[];

                    return ListView(
                      children: [
                        _PodiumAgg(entries: top3),
                        const SizedBox(height: 18),
                        _RestAgg(rest: rest),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/* ------------ Segmented (Weekly / Monthly / All Time) ------------ */

class _PeriodSegment extends StatelessWidget {
  final LBPeriod period;
  final ValueChanged<LBPeriod> onChanged;

  const _PeriodSegment({required this.period, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final selectedColor = const Color(0xFF3450F5);
    final border = Border.all(color: selectedColor, width: 1.2);
    final labels = const [
      'Weekly',
      'Monthly',
      'All Time',
    ];

    Widget seg(String text, bool selected, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? selectedColor : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : selectedColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: border,
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(.3),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        children: [
          seg(labels[0], period == LBPeriod.weekly,
                  () => onChanged(LBPeriod.weekly)),
          seg(labels[1], period == LBPeriod.monthly,
                  () => onChanged(LBPeriod.monthly)),
          seg(labels[2], period == LBPeriod.allTime,
                  () => onChanged(LBPeriod.allTime)),
        ],
      ),
    );
  }
}

/* ------------------------ Helpers ------------------------ */

String _ordinal(int n) {
  final mod100 = n % 100;
  if (mod100 >= 11 && mod100 <= 13) return '${n}th';
  switch (n % 10) {
    case 1:
      return '${n}st';
    case 2:
      return '${n}nd';
    case 3:
      return '${n}rd';
    default:
      return '${n}th';
  }
}

class _Photo extends StatelessWidget {
  final String? url;
  final double size;
  const _Photo({required this.url, this.size = 28});

  @override
  Widget build(BuildContext context) {
    final has = (url != null && url!.isNotEmpty);
    return CircleAvatar(
      radius: size,
      backgroundColor: Colors.white,
      backgroundImage: has ? NetworkImage(url!) : null,
      child: has ? null : const Icon(Icons.person, color: Colors.black54),
    );
  }
}

class _RankChip extends StatelessWidget {
  final String label;
  final Color color;
  const _RankChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}

/* ----------------------- Top-3 Podium ----------------------- */

class _PodiumAgg extends StatelessWidget {
  final List<GlobalLBEntry> entries;
  const _PodiumAgg({required this.entries});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    const h1 = 200.0, h2 = 200.0, h3 = 200.0;

    GlobalLBEntry? at(int i) => i < entries.length ? entries[i] : null;

    Widget bar(int rank, double height, List<Color> grad, GlobalLBEntry? e) {
      final name = e == null
          ? '—'
          : (e.displayName ?? e.userId.substring(0, 6));
      final score = e?.totalScore ?? 0;

      Color chipColor;
      switch (rank) {
        case 1:
          chipColor = const Color(0xFFFFC84D);
          break;
        case 2:
          chipColor = const Color(0xFFB7C7FF);
          break;
        default:
          chipColor = const Color(0xFFD7C9FF);
      }

      return Container(
        width: (w - 32) / 3 - 10,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: grad,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // avatar + rank chip INSIDE bar (top-center a bit lower)
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  _Photo(url: e?.avatarUrl, size: 25),
                  Positioned(
                    right: -16,
                    top: -6,
                    child: _RankChip(label: _ordinal(rank), color: chipColor),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // middle block: Name -> Points -> Rank
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18),
              ),
              const SizedBox(height: 6),
              Text(
                '$score\npoints',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),

            ],
          ),
        ),
      );
    }

    // 2nd | 1st | 3rd order
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: bar(2, h2, const [Color(0xFF7EB2FF), Color(0xFF6A8CFF)], at(1)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: bar(1, h1, const [Color(0xFFFF8DA1), Color(0xFFFF6A7B)], at(0)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: bar(3, h3, const [Color(0xFFA58DFF), Color(0xFF7A6BFF)], at(2)),
        ),
      ],
    );
  }
}

/* ---------------------- Rest (4th+) ---------------------- */

class _RestAgg extends StatelessWidget {
  final List<GlobalLBEntry> rest;
  const _RestAgg({required this.rest});

  @override
  Widget build(BuildContext context) {
    if (rest.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Column(
          children: List.generate(rest.length, (i) {
            final e = rest[i];
            final rank = i + 4;
            return Padding(
              padding: EdgeInsets.only(bottom: i == rest.length - 1 ? 0 : 12),
              child: _RowPill(
                rankLabel: _ordinal(rank),
                name: e.displayName ?? e.userId.substring(0, 6),
                avatarUrl: e.avatarUrl,
                points: e.totalScore,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _RowPill extends StatelessWidget {
  final String rankLabel;
  final String name;
  final String? avatarUrl;
  final int points;

  const _RowPill({
    required this.rankLabel,
    required this.name,
    required this.avatarUrl,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6FA),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // ordinal chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE7EDFF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(rankLabel,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: Colors.black87)),
          ),
          const SizedBox(width: 12),

          // avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE9D8FF),
            backgroundImage:
            (avatarUrl != null && avatarUrl!.isNotEmpty) ? NetworkImage(avatarUrl!) : null,
            child: (avatarUrl == null || avatarUrl!.isEmpty)
                ? const Icon(Icons.person, color: Colors.black54)
                : null,
          ),
          const SizedBox(width: 12),

          // center block: Name -> Points -> Rank
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text('$points points',
                      style: TextStyle(
                          fontSize: 13, color: Colors.black.withOpacity(.7))),
                  const SizedBox(height: 2),
                  Text(rankLabel,
                      style: TextStyle(
                          fontSize: 12, color: Colors.black.withOpacity(.6))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
