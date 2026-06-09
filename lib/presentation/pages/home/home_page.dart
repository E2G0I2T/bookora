import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/book_provider.dart';
import '../../widgets/common/book_card.dart';
import '../../widgets/common/category_chip.dart';
import '../../widgets/common/search_bar_widget.dart';
import '../../../data/models/book_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../widgets/common/skeleton_widget.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final isSearching = searchQuery.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isSearching) ...[
                      Text(
                        'Bookora',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(color: AppColors.primary),
                      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                      const SizedBox(height: 4),
                      Text(
                        '원하는 책을 찾아보세요',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                      const SizedBox(height: 16),
                    ],
                    const SearchBarWidget(),
                  ],
                ),
              ),
            ),

            if (isSearching) ...[
              const _SearchResultSection(),
            ] else ...[
              // 베스트셀러 섹션
              const SliverToBoxAdapter(
                child: _BestsellerSection(),
              ),

              // 카테고리 필터
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _CategorySection(),
                ),
              ),

              // 카테고리별 도서
              const _CategoryBooksSection(),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _SearchResultSection extends ConsumerWidget {
  const _SearchResultSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider);

    return results.when(
      data: (books) {
        Future.microtask(() =>
        ref.read(bookCacheProvider.notifier).addAll(books));
        if (books.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    const Icon(Icons.search_off,
                        size: 64, color: AppColors.textHint),
                    const SizedBox(height: 16),
                    Text('검색 결과가 없어요',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) => BookCard(book: books[index])
                  .animate()
                  .fadeIn(delay: (index * 50).ms),
              childCount: books.length,
            ),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 0.6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Center(child: Text('오류: $e')),
      ),
    );
  }
}

class _CategorySection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: bookCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = bookCategories[index];
          return CategoryChip(
            label: category,
            isSelected: selected == category,
            onTap: () =>
                ref.read(selectedCategoryProvider.notifier).select(category),
          ).animate().fadeIn(delay: (index * 50).ms);
        },
      ),
    );
  }
}

class _BestsellerSection extends ConsumerWidget {
  const _BestsellerSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bestsellers = ref.watch(bestsellersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department,
                  color: AppColors.accent, size: 20),
              const SizedBox(width: 6),
              Text('베스트셀러',
                  style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        bestsellers.when(
          data: (books) {
            Future.microtask(() =>
            ref.read(bookCacheProvider.notifier).addAll(books));
            return SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: books.length > 10 ? 10 : books.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _BestsellerCard(
                    book: books[index],
                    rank: index + 1,
                  ).animate().fadeIn(delay: (index * 60).ms).slideX(begin: 0.1);
                },
              ),
            );
          },
          loading: () => const BestsellerSectionSkeleton(),
          error: (e, _) => Center(child: Text('오류: $e')),
        ),
      ],
    );
  }
}

class _BestsellerCard extends ConsumerWidget {
  final BookModel book;
  final int rank;

  const _BestsellerCard({required this.book, required this.rank});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWishlisted = ref.watch(
      wishlistItemsProvider.select((list) => list.any((b) => b.isbn == book.isbn)),
    );

    return GestureDetector(
      onTap: () => context.push(AppRoutes.bookDetailPath(book.isbn)),
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: book.thumbnail.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: book.thumbnail,
                          width: 130,
                          height: 170,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 130,
                            height: 170,
                            color: AppColors.surfaceVariant,
                            child: const Icon(Icons.book,
                                color: AppColors.textHint),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 130,
                            height: 170,
                            color: AppColors.surfaceVariant,
                            child: const Icon(Icons.book,
                                color: AppColors.textHint),
                          ),
                        )
                      : Container(
                          width: 130,
                          height: 170,
                          color: AppColors.surfaceVariant,
                          child: const Icon(Icons.book,
                              color: AppColors.textHint),
                        ),
                ),
                // 순위 뱃지
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: rank <= 3 ? AppColors.accent : AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                // 찜 버튼
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => ref
                        .read(wishlistItemsProvider.notifier)
                        .toggle(book),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isWishlisted
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 16,
                        color: isWishlisted
                            ? Colors.red
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBooksSection extends ConsumerWidget {
  const _CategoryBooksSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(booksByCategoryProvider);
    final category = ref.watch(selectedCategoryProvider);

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              children: [
                const Icon(Icons.grid_view_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 6),
                Text(
                  category == '전체' ? '추천 도서' : '$category 도서',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
        books.when(
          data: (bookList) {
            Future.microtask(() =>
              ref.read(bookCacheProvider.notifier).addAll(bookList));
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => BookCard(book: bookList[index])
                      .animate()
                      .fadeIn(delay: (index * 50).ms),
                  childCount: bookList.length,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
              ),
            );
          },
          loading: () => const BookGridSkeleton(),
          error: (e, _) => SliverToBoxAdapter(
            child: Center(child: Text('오류: $e')),
          ),
        ),
      ],
    );
  }
}