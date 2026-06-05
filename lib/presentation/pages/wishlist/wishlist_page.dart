import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/book_model.dart';
import '../../providers/book_provider.dart';

class WishlistPage extends ConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('찜 목록 (${wishlist.length})'),
        actions: [
          if (wishlist.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('찜 목록 비우기'),
                    content: const Text('찜 목록을 모두 삭제할까요?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('취소'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          for (final book in [...wishlist]) {
                            ref
                                .read(wishlistItemsProvider.notifier)
                                .toggle(book);
                          }
                        },
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                '전체 삭제',
                style: TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: wishlist.isEmpty
          ? _EmptyWishlist()
          : _WishlistGrid(wishlist: wishlist),
    );
  }
}

// 빈 찜 목록
class _EmptyWishlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border,
            size: 80,
            color: AppColors.textHint,
          ).animate().fadeIn().scale(),
          const SizedBox(height: 16),
          Text(
            '찜한 책이 없어요',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            '마음에 드는 책을 찜해보세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textHint,
                ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

// 찜 목록 그리드
class _WishlistGrid extends StatelessWidget {
  final List<BookModel> wishlist;

  const _WishlistGrid({required this.wishlist});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wishlist.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        return _WishlistCard(book: wishlist[index])
            .animate()
            .fadeIn(delay: (index * 50).ms);
      },
    );
  }
}

// 찜 목록 카드
class _WishlistCard extends ConsumerWidget {
  final BookModel book;

  const _WishlistCard({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.bookDetailPath(book.isbn)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: book.thumbnail.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: book.thumbnail,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.surfaceVariant,
                              child: const Center(
                                child: Icon(Icons.book,
                                    color: AppColors.textHint),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.surfaceVariant,
                              child: const Center(
                                child: Icon(Icons.book,
                                    color: AppColors.textHint),
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.surfaceVariant,
                            child: const Center(
                              child:
                                  Icon(Icons.book, color: AppColors.textHint),
                            ),
                          ),
                  ),
                  // 찜 해제 버튼
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () =>
                          ref.read(wishlistItemsProvider.notifier).toggle(book),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          size: 16,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.authors,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                  ),
                  const SizedBox(height: 4),
                  if (book.displayPrice > 0)
                    Text(
                      '${_formatPrice(book.displayPrice)}원',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}