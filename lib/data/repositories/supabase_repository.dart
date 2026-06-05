import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book_model.dart';
import '../../presentation/providers/auth_provider.dart';

final supabaseRepositoryProvider = Provider<SupabaseRepository>((ref) {
  return SupabaseRepository(
    ref.watch(supabaseProvider),
  );
});

class SupabaseRepository {
  final SupabaseClient _supabase;

  SupabaseRepository(this._supabase);

  // 주문 저장
  Future<void> saveOrder({
    required List<BookModel> books,
    required int totalPrice,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('로그인이 필요해요');

    // 주문 생성
    final orderResponse = await _supabase
        .from('orders')
        .insert({
          'user_id': userId,
          'total_price': totalPrice,
          'status': '배송 준비중',
        })
        .select()
        .single();

    final orderId = orderResponse['id'];

    // 주문 아이템 저장
    final items = books
        .map((book) => {
              'order_id': orderId,
              'isbn': book.isbn,
              'title': book.title,
              'authors': book.authors,
              'thumbnail': book.thumbnail,
              'price': book.displayPrice,
            })
        .toList();

    await _supabase.from('order_items').insert(items);
  }

  // 주문 내역 조회
  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // 찜 목록 저장
  Future<void> saveWishlist(BookModel book) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('로그인이 필요해요');

    await _supabase.from('wishlists').upsert({
      'user_id': userId,
      'isbn': book.isbn,
      'title': book.title,
      'authors': book.authors,
      'thumbnail': book.thumbnail,
      'price': book.displayPrice,
    });
  }

  // 찜 목록 삭제
  Future<void> removeWishlist(String isbn) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('wishlists')
        .delete()
        .eq('user_id', userId)
        .eq('isbn', isbn);
  }

  // 찜 목록 조회
  Future<List<BookModel>> fetchWishlists() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('wishlists')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response)
        .map((item) => BookModel(
              title: item['title'] ?? '',
              authors: item['authors'] ?? '',
              publisher: '',
              thumbnail: item['thumbnail'] ?? '',
              contents: '',
              isbn: item['isbn'] ?? '',
              price: item['price'] ?? 0,
              salePrice: 0,
              status: '',
            ))
        .toList();
  }
}