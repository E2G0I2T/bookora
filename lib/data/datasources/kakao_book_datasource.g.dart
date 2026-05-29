// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kakao_book_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(kakaoBookDatasource)
final kakaoBookDatasourceProvider = KakaoBookDatasourceProvider._();

final class KakaoBookDatasourceProvider
    extends
        $FunctionalProvider<
          KakaoBookDatasource,
          KakaoBookDatasource,
          KakaoBookDatasource
        >
    with $Provider<KakaoBookDatasource> {
  KakaoBookDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kakaoBookDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kakaoBookDatasourceHash();

  @$internal
  @override
  $ProviderElement<KakaoBookDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  KakaoBookDatasource create(Ref ref) {
    return kakaoBookDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KakaoBookDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KakaoBookDatasource>(value),
    );
  }
}

String _$kakaoBookDatasourceHash() =>
    r'b7a0d36cc6737486a9e0df2bef6afc916a985e81';
