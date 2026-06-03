import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:canopy/features/saplings/domain/entities/sapling.dart';
import 'package:canopy/features/discover/presentation/widgets/sapling_card.dart';

class SaplingCardStack extends StatefulWidget {
  const SaplingCardStack({
    super.key,
    required this.saplings,
    required this.onSwipeRight,
    required this.onSwipeLeft,
    required this.onTap,
    required this.isDisabled,
  });

  final List<Sapling> saplings;
  final void Function(Sapling) onSwipeRight;
  final void Function(Sapling) onSwipeLeft;
  final void Function(Sapling) onTap;
  final bool isDisabled;

  @override
  State<SaplingCardStack> createState() => _SaplingCardStackState();
}

class _SaplingCardStackState extends State<SaplingCardStack> {
  final _controller = CardSwiperController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.saplings.isEmpty) {
      return const _EmptyState();
    }

    return CardSwiper(
      controller: _controller,
      isDisabled: widget.isDisabled,
      cardsCount: widget.saplings.length,
      numberOfCardsDisplayed: widget.saplings.length.clamp(1, 3),
      onSwipe: (previousIndex, currentIndex, direction) {
        final sapling = widget.saplings[previousIndex];
        if (direction == CardSwiperDirection.right) {
          widget.onSwipeRight(sapling);
        } else if (direction == CardSwiperDirection.left) {
          widget.onSwipeLeft(sapling);
        }
        return true;
      },
      cardBuilder:
          (context, index, horizontalOffsetPercent, verticalOffsetPercent) {
            final sapling = widget.saplings[index];
            return SaplingCard(
              sapling: sapling,
              onTap: () => widget.onTap(sapling),
            );
          },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.park_outlined, size: 80),
          const SizedBox(height: 16),
          Text('No more saplings nearby', style: tt.titleMedium),
          const SizedBox(height: 8),
          Text('Check back tomorrow.', style: tt.bodyMedium),
        ],
      ),
    );
  }
}
