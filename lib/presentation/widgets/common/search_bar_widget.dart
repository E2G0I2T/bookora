import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/book_provider.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  const SearchBarWidget({super.key});

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    // 이전 타이머 취소
    _debounceTimer?.cancel();

    if (value.trim().isEmpty) {
      ref.read(searchQueryProvider.notifier).clear();
      return;
    }

    // 500ms 후에 검색 실행
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).update(value);
    });
  }

  void _onClear() {
    _debounceTimer?.cancel();
    _controller.clear();
    ref.read(searchQueryProvider.notifier).clear();
    _focusNode.unfocus();
  }

  void _onSubmit(String value) {
    // 엔터 입력 시 즉시 검색
    _debounceTimer?.cancel();
    if (value.trim().isNotEmpty) {
      ref.read(searchQueryProvider.notifier).update(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onChanged,
        onSubmitted: _onSubmit,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: '책 제목, 저자를 검색해보세요',
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 22,
          ),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  onPressed: _onClear,
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}