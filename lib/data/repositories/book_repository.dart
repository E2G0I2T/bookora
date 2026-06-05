import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../datasources/kakao_book_datasource.dart';
import '../models/book_model.dart';

part 'book_repository.g.dart';

@riverpod
BookRepository bookRepository(Ref ref) {
  return BookRepository(ref.watch(kakaoBookDatasourceProvider));
}

class BookRepository {
  final KakaoBookDatasource _datasource;

  BookRepository(this._datasource);

  Future<List<BookModel>> searchBooks({
    required String query,
    String target = 'title',
    int page = 1,
    int size = 20,
  }) async {
    if (query.trim().isEmpty) return [];
    return _datasource.searchBooks(
      query: query,
      target: target,
      page: page,
      size: size,
    );
  }

  Future<List<BookModel>> fetchBestsellers() async {
    return _datasource.fetchBestsellers();
  }

  Future<List<BookModel>> fetchByCategory(String category, {int page = 1}) async {
    return _datasource.fetchByCategory(category: category, page: page);
  }

  Future<BookModel?> fetchByIsbn(String isbn) async {
    return _datasource.fetchByIsbn(isbn);
  }
}