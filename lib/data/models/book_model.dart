class BookModel {
  final String title;
  final String authors;
  final String publisher;
  final String thumbnail;
  final String contents;
  final String isbn;
  final int price;
  final int salePrice;
  final String status;
  final DateTime? datetime;

  const BookModel({
    required this.title,
    required this.authors,
    required this.publisher,
    required this.thumbnail,
    required this.contents,
    required this.isbn,
    required this.price,
    required this.salePrice,
    required this.status,
    this.datetime,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      title: json['title'] ?? '',
      authors: (json['authors'] as List<dynamic>?)?.join(', ') ?? '',
      publisher: json['publisher'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      contents: json['contents'] ?? '',
      isbn: (json['isbn'] ?? '').toString().trim(),
      price: json['price'] ?? 0,
      salePrice: json['sale_price'] ?? 0,
      status: json['status'] ?? '',
      datetime: json['datetime'] != null
          ? DateTime.tryParse(json['datetime'])
          : null,
    );
  }

  // 할인율 계산
  int get discountRate {
    if (price <= 0 || salePrice <= 0) return 0;
    return (((price - salePrice) / price) * 100).round();
  }

  // 실제 표시 가격
  int get displayPrice => salePrice > 0 ? salePrice : price;
}