// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedCategory)
final selectedCategoryProvider = SelectedCategoryProvider._();

final class SelectedCategoryProvider
    extends $NotifierProvider<SelectedCategory, String> {
  SelectedCategoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedCategoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedCategoryHash();

  @$internal
  @override
  SelectedCategory create() => SelectedCategory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$selectedCategoryHash() => r'62ff2bed2c11cf61a344080e8c291cc266eed062';

abstract class _$SelectedCategory extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SearchQuery)
final searchQueryProvider = SearchQueryProvider._();

final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'790bd96a8a13bb944767c7bf06a5378cfc78a54d';

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(bestsellers)
final bestsellersProvider = BestsellersProvider._();

final class BestsellersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BookModel>>,
          List<BookModel>,
          FutureOr<List<BookModel>>
        >
    with $FutureModifier<List<BookModel>>, $FutureProvider<List<BookModel>> {
  BestsellersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bestsellersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bestsellersHash();

  @$internal
  @override
  $FutureProviderElement<List<BookModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BookModel>> create(Ref ref) {
    return bestsellers(ref);
  }
}

String _$bestsellersHash() => r'd8c10f95d12f28f90b65d7c3c5206f25a5127a45';

@ProviderFor(booksByCategory)
final booksByCategoryProvider = BooksByCategoryProvider._();

final class BooksByCategoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BookModel>>,
          List<BookModel>,
          FutureOr<List<BookModel>>
        >
    with $FutureModifier<List<BookModel>>, $FutureProvider<List<BookModel>> {
  BooksByCategoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'booksByCategoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$booksByCategoryHash();

  @$internal
  @override
  $FutureProviderElement<List<BookModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BookModel>> create(Ref ref) {
    return booksByCategory(ref);
  }
}

String _$booksByCategoryHash() => r'fc09cfe6426e2cf64c84b7af79118e2f17e9cc43';

@ProviderFor(searchResults)
final searchResultsProvider = SearchResultsProvider._();

final class SearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BookModel>>,
          List<BookModel>,
          FutureOr<List<BookModel>>
        >
    with $FutureModifier<List<BookModel>>, $FutureProvider<List<BookModel>> {
  SearchResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @$internal
  @override
  $FutureProviderElement<List<BookModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BookModel>> create(Ref ref) {
    return searchResults(ref);
  }
}

String _$searchResultsHash() => r'ff358f6e1d37313eedb0a543e2573725b273905f';
