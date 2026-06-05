import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/book_model.dart';

part 'kakao_book_datasource.g.dart';

// ⚠️ 본인의 REST API 키로 교체해주세요
const _kakaoApiKey = 'a5033cd37da82faa2d275804ade4bc6b';
const _baseUrl = 'https://dapi.kakao.com/v3/search/book';

@riverpod
KakaoBookDatasource kakaoBookDatasource(Ref ref) {
  return KakaoBookDatasource();
}

class KakaoBookDatasource {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Authorization': 'KakaoAK $_kakaoApiKey',
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // 도서 검색
  Future<List<BookModel>> searchBooks({
    required String query,
    String target = 'title',
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '',
        queryParameters: {
          'query': query,
          'target': target,
          'page': page,
          'size': size,
        },
      );

      final documents = response.data['documents'] as List<dynamic>;
      return documents
          .map((json) => BookModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 베스트셀러 (카테고리별 인기도서)
  Future<List<BookModel>> fetchBestsellers({
    String query = '베스트셀러',
    int size = 20,
  }) async {
    return searchBooks(query: query, target: 'title', size: size);
  }

  // 카테고리별 도서
  Future<List<BookModel>> fetchByCategory({
    required String category,
    int page = 1,
    int size = 20,
  }) async {
    return searchBooks(query: category, page: page, size: size);
  }

  Future<BookModel?> fetchByIsbn(String isbn) async {
    try {
      final response = await _dio.get(
        '',
        queryParameters: {
          'query': isbn,
          'target': 'isbn',
        },
      );
      final documents = response.data['documents'] as List<dynamic>;
      if (documents.isEmpty) return null;
      return BookModel.fromJson(documents.first);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('네트워크 연결이 느려요. 다시 시도해주세요.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return Exception('API 키가 올바르지 않아요.');
        }
        return Exception('서버 오류가 발생했어요. ($statusCode)');
      default:
        return Exception('알 수 없는 오류가 발생했어요.');
    }
  }
}