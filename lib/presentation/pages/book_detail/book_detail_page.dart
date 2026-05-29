import 'package:flutter/material.dart';

class BookDetailPage extends StatelessWidget {
  final String bookId;

  const BookDetailPage({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('도서 상세')),
      body: Center(
        child: Text('도서 ID: $bookId'),
      ),
    );
  }
}