import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/book_model.dart';
import '../../providers/book_provider.dart';

class BookDetailPage extends ConsumerWidget {
  final String bookId;

  const BookDetailPage({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cachedBook = ref.watch(
      bookCacheProvider.select((cache) => cache[bookId]),
    );

    // 캐시에 있으면 바로 표시
    if (cachedBook != null) {
      return _BookDetailView(book: cachedBook);
    }

    // 없으면 API로 조회
    final bookAsync = ref.watch(bookByIsbnProvider(bookId));
    return bookAsync.when(
      data: (book) {
        if (book == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('도서 상세')),
            body: const Center(child: Text('책 정보를 찾을 수 없어요')),
          );
        }
        return _BookDetailView(book: book);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('도서 상세')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('도서 상세')),
        body: Center(child: Text('오류: $e')),
      ),
    );
  }
}

class _BookDetailView extends ConsumerWidget {
  final BookModel book;

  const _BookDetailView({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWishlisted = ref.watch(
      wishlistItemsProvider.select((list) => list.any((b) => b.isbn == book.isbn)),
    );
    final isInCart = ref.watch(
      cartItemsProvider.select((list) => list.any((b) => b.isbn == book.isbn)),
    );
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('도서 상세'),
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(wishlistItemsProvider.notifier).toggle(book),
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : AppColors.textSecondary,
            ),
          ),
        ],
      ),
      body: isWide
          ? _WideLayout(book: book, isInCart: isInCart)
          : _NarrowLayout(book: book, isInCart: isInCart),
      bottomNavigationBar: isWide
          ? null
          : _BottomBar(book: book, isInCart: isInCart),
    );
  }
}

// 모바일 레이아웃
class _NarrowLayout extends StatelessWidget {
  final BookModel book;
  final bool isInCart;

  const _NarrowLayout({required this.book, required this.isInCart});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 책 표지
          _BookCover(book: book, height: 300),
          // 책 정보
          Padding(
            padding: const EdgeInsets.all(20),
            child: _BookInfo(book: book),
          ),
        ],
      ),
    );
  }
}

// 웹 레이아웃
class _WideLayout extends ConsumerWidget {
  final BookModel book;
  final bool isInCart;

  const _WideLayout({required this.book, required this.isInCart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 왼쪽 — 책 표지
            SizedBox(
              width: 280,
              child: Column(
                children: [
                  _BookCover(book: book, height: 380),
                  const SizedBox(height: 20),
                  _ActionButtons(book: book, isInCart: isInCart),
                ],
              ),
            ),
            const SizedBox(width: 48),
            // 오른쪽 — 책 정보
            Expanded(child: _BookInfo(book: book)),
          ],
        ),
      ),
    );
  }
}

// 책 표지
class _BookCover extends StatelessWidget {
  final BookModel book;
  final double height;

  const _BookCover({required this.book, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      color: AppColors.surfaceVariant,
      child: book.thumbnail.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: book.thumbnail,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.book,
                size: 80,
                color: AppColors.textHint,
              ),
            )
          : const Icon(Icons.book, size: 80, color: AppColors.textHint),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// 책 정보
class _BookInfo extends StatelessWidget {
  final BookModel book;

  const _BookInfo({required this.book});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목
        Text(
          book.title,
          style: Theme.of(context).textTheme.headlineMedium,
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 8),

        // 저자 & 출판사
        Row(
          children: [
            const Icon(Icons.person_outline,
                size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                book.authors,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.business_outlined,
                size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              book.publisher,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 20),

        // 가격
        _PriceSection(book: book).animate().fadeIn(delay: 250.ms),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 16),

        // 책 소개
        Text(
          '책 소개',
          style: Theme.of(context).textTheme.titleMedium,
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 8),
        Text(
          book.contents.isNotEmpty ? book.contents : '소개 정보가 없어요.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
        ).animate().fadeIn(delay: 350.ms),
        const SizedBox(height: 24),
      ],
    );
  }
}

// 가격 섹션
class _PriceSection extends StatelessWidget {
  final BookModel book;

  const _PriceSection({required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (book.discountRate > 0) ...[
                Text(
                  '${_formatPrice(book.price)}원',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.textHint,
                      ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                '${_formatPrice(book.displayPrice)}원',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          if (book.discountRate > 0) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '-${book.discountRate}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
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

// 액션 버튼 (웹용)
class _ActionButtons extends ConsumerWidget {
  final BookModel book;
  final bool isInCart;

  const _ActionButtons({required this.book, required this.isInCart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isInCart
            ? null
            : () {
                ref.read(cartItemsProvider.notifier).add(book);
                final cart = ref.read(cartItemsProvider);
                debugPrint('장바구니 담기 후 아이템 수: ${cart.length}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('장바구니에 담았어요! (총 ${cart.length}권)'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            icon: Icon(isInCart ? Icons.check : Icons.shopping_cart_outlined),
            label: Text(isInCart ? '담긴 도서' : '장바구니'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            child: const Text('바로 구매'),
          ),
        ),
      ],
    );
  }
}

// 하단 바 (모바일용)
class _BottomBar extends ConsumerWidget {
  final BookModel book;
  final bool isInCart;

  const _BottomBar({required this.book, required this.isInCart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isInCart
              ? null
              : () {
                  ref.read(cartItemsProvider.notifier).add(book);
                  final cart = ref.read(cartItemsProvider);
                  debugPrint('장바구니 담기 후 아이템 수: ${cart.length}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('장바구니에 담았어요! (총 ${cart.length}권)'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              icon: Icon(isInCart ? Icons.check : Icons.shopping_cart_outlined),
              label: Text(isInCart ? '담긴 도서' : '장바구니'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('바로 구매'),
            ),
          ),
        ],
      ),
    );
  }
}