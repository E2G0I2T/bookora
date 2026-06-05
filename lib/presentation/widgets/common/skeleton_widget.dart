import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

// 기본 스켈레톤 박스
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1200.ms,
          color: Colors.white.withOpacity(0.6),
        );
  }
}

// 베스트셀러 스켈레톤 카드
class BestsellerSkeletonCard extends StatelessWidget {
  const BestsellerSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 130, height: 170, borderRadius: 8),
          const SizedBox(height: 6),
          const SkeletonBox(width: 100, height: 12),
          const SizedBox(height: 4),
          const SkeletonBox(width: 70, height: 12),
        ],
      ),
    );
  }
}

// 도서 카드 스켈레톤
class BookCardSkeleton extends StatelessWidget {
  const BookCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SkeletonBox(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 12,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: double.infinity, height: 12),
                SizedBox(height: 4),
                SkeletonBox(width: 80, height: 10),
                SizedBox(height: 6),
                SkeletonBox(width: 60, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 베스트셀러 섹션 스켈레톤
class BestsellerSectionSkeleton extends StatelessWidget {
  const BestsellerSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => const BestsellerSkeletonCard(),
      ),
    );
  }
}

// 도서 그리드 스켈레톤
class BookGridSkeleton extends StatelessWidget {
  const BookGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, __) => const BookCardSkeleton(),
          childCount: 6,
        ),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 0.6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
      ),
    );
  }
}