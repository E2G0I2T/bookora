import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_theme.dart';

class AddressSearchPage extends StatefulWidget {
  const AddressSearchPage({super.key});

  @override
  State<AddressSearchPage> createState() => _AddressSearchPageState();
}

class _AddressSearchPageState extends State<AddressSearchPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return; // 웹에서는 WebView 초기화 스킵

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'AddressChannel',
        onMessageReceived: (message) {
          debugPrint('주소 수신: ${message.message}');
          if (mounted) Navigator.pop(context, message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (url.startsWith('address://')) {
              final encoded = url.replaceFirst('address://', '');
              final address = Uri.decodeComponent(encoded);
              if (mounted) Navigator.pop(context, address);
            }
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://e2g0i2t.github.io/bookora/kakao_postcode.html'));
  }

  @override
  Widget build(BuildContext context) {
    // 웹 플랫폼에서는 직접 입력 UI 표시
    if (kIsWeb) {
      return _WebAddressInput();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('주소 검색'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    '주소 검색을 불러오는 중...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// 웹 전용 주소 직접 입력 UI
class _WebAddressInput extends StatefulWidget {
  @override
  State<_WebAddressInput> createState() => _WebAddressInputState();
}

class _WebAddressInputState extends State<_WebAddressInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주소 입력'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '웹 환경에서는 주소를 직접 입력해주세요.\n모바일 앱에서는 주소 검색이 지원돼요.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '주소',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '예) 서울특별시 강남구 테헤란로 123',
                prefixIcon: Icon(Icons.home_outlined),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    Navigator.pop(context, _controller.text);
                  }
                },
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}