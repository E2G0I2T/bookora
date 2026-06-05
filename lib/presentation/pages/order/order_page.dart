import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/book_model.dart';
import '../../providers/book_provider.dart';
import '../../../data/repositories/supabase_repository.dart';

// 주문 모델
class OrderModel {
  final String id;
  final List<BookModel> books;
  final int totalPrice;
  final DateTime orderedAt;
  final String status;

  OrderModel({
    required this.id,
    required this.books,
    required this.totalPrice,
    required this.orderedAt,
    this.status = '배송 준비중',
  });
}

// 주문 내역 Provider
final orderListProvider = NotifierProvider<OrderListNotifier, List<OrderModel>>(
  OrderListNotifier.new,
);

class OrderListNotifier extends Notifier<List<OrderModel>> {
  @override
  List<OrderModel> build() => [];

  void addOrder(List<BookModel> books, int totalPrice) async {
    final order = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      books: books,
      totalPrice: totalPrice,
      orderedAt: DateTime.now(),
    );
    state = [order, ...state];

    // Supabase에 저장
    try {
      final repo = ref.read(supabaseRepositoryProvider);
      await repo.saveOrder(books: books, totalPrice: totalPrice);
    } catch (e) {
      debugPrint('주문 저장 오류: $e');
    }
  }
}

class OrderPage extends ConsumerWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('주문 내역')),
      body: orders.isEmpty ? _EmptyOrder() : _OrderList(orders: orders),
    );
  }
}

// 빈 주문 내역
class _EmptyOrder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppColors.textHint,
          ).animate().fadeIn().scale(),
          const SizedBox(height: 16),
          Text(
            '주문 내역이 없어요',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            '마음에 드는 책을 주문해보세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textHint,
                ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

// 주문 목록
class _OrderList extends StatelessWidget {
  final List<OrderModel> orders;

  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _OrderCard(order: orders[index])
            .animate()
            .fadeIn(delay: (index * 80).ms)
            .slideY(begin: 0.1);
      },
    );
  }
}

// 주문 카드
class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 주문 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '주문번호 #${order.id.substring(order.id.length - 6)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              _StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(order.orderedAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textHint,
                ),
          ),
          const Divider(height: 20),

          // 주문 도서 목록
          ...order.books.map((book) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.book_outlined,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${_formatPrice(book.displayPrice)}원',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              )),

          const Divider(height: 20),

          // 총액
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 ${order.books.length}권',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              Text(
                '${_formatPrice(order.totalPrice)}원',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}

// 상태 뱃지
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case '배송 준비중':
        color = AppColors.warning;
      case '배송중':
        color = AppColors.primary;
      case '배송 완료':
        color = AppColors.success;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}