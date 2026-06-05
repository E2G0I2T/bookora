import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/book_model.dart';
import '../../data/repositories/book_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'book_provider.g.dart';

// 카테고리 목록
const bookCategories = ['전체', '소설', '경제/경영', 'IT/개발', '자기계발', '인문', '과학'];

// 선택된 카테고리 상태
@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  String build() => '전체';

  void select(String category) => state = category;
}

// 검색어 상태
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
  void clear() => state = '';
}

// 베스트셀러 목록
@riverpod
Future<List<BookModel>> bestsellers(Ref ref) async {
  final repo = ref.watch(bookRepositoryProvider);
  return repo.fetchBestsellers();
}

// 카테고리별 도서 목록
@riverpod
Future<List<BookModel>> booksByCategory(Ref ref) async {
  final category = ref.watch(selectedCategoryProvider);
  final repo = ref.watch(bookRepositoryProvider);

  if (category == '전체') {
    return repo.fetchBestsellers();
  }
  return repo.fetchByCategory(category);
}

// 검색 결과
@riverpod
Future<List<BookModel>> searchResults(Ref ref) async {
  final query = ref.watch(searchQueryProvider);
  final repo = ref.watch(bookRepositoryProvider);

  if (query.trim().isEmpty) return [];
  return repo.searchBooks(query: query);
}

// 장바구니 상태
final cartItemsProvider =
    NotifierProvider<CartItemsNotifier, List<BookModel>>(
        CartItemsNotifier.new);

class CartItemsNotifier extends Notifier<List<BookModel>> {
  @override
  List<BookModel> build() => [];

  void add(BookModel book) {
    if (!state.any((b) => b.isbn == book.isbn)) {
      state = [...state, book];
    }
  }

  void remove(BookModel book) {
    state = state.where((b) => b.isbn != book.isbn).toList();
  }

  bool contains(BookModel book) {
    return state.any((b) => b.isbn == book.isbn);
  }

  void clear() => state = [];
}

// 찜 목록 상태
final wishlistItemsProvider =
    NotifierProvider<WishlistItemsNotifier, List<BookModel>>(
        WishlistItemsNotifier.new);

class WishlistItemsNotifier extends Notifier<List<BookModel>> {
  @override
  List<BookModel> build() => [];

  void toggle(BookModel book) {
    if (state.any((b) => b.isbn == book.isbn)) {
      state = state.where((b) => b.isbn != book.isbn).toList();
    } else {
      state = [...state, book];
    }
  }

  bool contains(BookModel book) {
    return state.any((b) => b.isbn == book.isbn);
  }
}

// 전체 도서 캐시 (상세 페이지용)
final bookCacheProvider =
    NotifierProvider<BookCache, Map<String, BookModel>>(BookCache.new);

class BookCache extends Notifier<Map<String, BookModel>> {
  @override
  Map<String, BookModel> build() => {};

  void addAll(List<BookModel> books) {
    final newEntries = {for (var b in books) b.isbn: b};
    state = {...state, ...newEntries};
  }

  BookModel? find(String isbn) => state[isbn];
}

// ISBN으로 도서 상세 조회
@riverpod
Future<BookModel?> bookByIsbn(Ref ref, String isbn) async {
  // 캐시에 있으면 캐시 사용
  final cached = ref.watch(bookCacheProvider)[isbn];
  if (cached != null) return cached;

  // 없으면 API 호출
  final repo = ref.watch(bookRepositoryProvider);
  final book = await repo.fetchByIsbn(isbn);
  if (book != null) {
    ref.read(bookCacheProvider.notifier).addAll([book]);
  }
  return book;
}