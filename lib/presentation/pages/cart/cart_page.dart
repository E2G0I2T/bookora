import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/book_model.dart';
import '../order/order_page.dart';
import '../../providers/book_provider.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartItemsProvider);
    
    debugPrint('===== CartPage build =====');
    debugPrint('cartItems.length: ${cartItems.length}');
    for (final item in cartItems) {
      debugPrint('  - ${item.title}');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('장바구니 (${cartItems.length})'),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(cartItemsProvider.notifier).clear(),
              child: const Text(
                '전체 삭제',
                style: TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _EmptyCart()
          : _CartList(cartItems: cartItems),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : _CartBottomBar(cartItems: cartItems),
    );
  }
}

// 빈 장바구니
class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textHint,
          ).animate().fadeIn().scale(),
          const SizedBox(height: 16),
          Text(
            '장바구니가 비어있어요',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            '마음에 드는 책을 담아보세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textHint,
                ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

// 장바구니 목록
class _CartList extends StatelessWidget {
  final List<BookModel> cartItems;

  const _CartList({required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cartItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _CartItem(book: cartItems[index])
            .animate()
            .fadeIn(delay: (index * 80).ms)
            .slideX(begin: 0.1);
      },
    );
  }
}

// 장바구니 아이템
class _CartItem extends ConsumerWidget {
  final BookModel book;

  const _CartItem({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 책 표지
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: book.thumbnail.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: book.thumbnail,
                    width: 70,
                    height: 95,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 70,
                      height: 95,
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.book, color: AppColors.textHint),
                    ),
                  )
                : Container(
                    width: 70,
                    height: 95,
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.book, color: AppColors.textHint),
                  ),
          ),
          const SizedBox(width: 12),
          // 책 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  book.authors,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_formatPrice(book.displayPrice)}원',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    // 삭제 버튼
                    GestureDetector(
                      onTap: () =>
                          ref.read(cartItemsProvider.notifier).remove(book),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

// 하단 결제 바
class _CartBottomBar extends ConsumerWidget {
  final List<BookModel> cartItems;

  const _CartBottomBar({required this.cartItems});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalPrice = cartItems.fold<int>(
      0,
      (sum, book) => sum + book.displayPrice,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 총액
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 ${cartItems.length}권',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              Text(
                '${_formatPrice(totalPrice)}원',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 주문하기 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showOrderDialog(context, ref, totalPrice);
              },
              child: Text('${_formatPrice(totalPrice)}원 주문하기'),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDialog(BuildContext context, WidgetRef ref, int totalPrice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('주문 확인'),
        content: Text(
          '총 ${cartItems.length}권, ${_formatPrice(totalPrice)}원을\n주문하시겠어요?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(orderListProvider.notifier).addOrder(
                cartItems,
                totalPrice,
              );
              ref.read(cartItemsProvider.notifier).clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('주문이 완료됐어요! 🎉'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: const Text('주문하기'),
          ),
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