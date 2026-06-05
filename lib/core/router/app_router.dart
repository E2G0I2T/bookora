import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/book_detail/book_detail_page.dart';
import '../../presentation/pages/cart/cart_page.dart';
import '../../presentation/pages/auth/auth_page.dart';
import '../../presentation/pages/order/order_page.dart';
import '../widgets/main_shell.dart';
import '../../presentation/pages/wishlist/wishlist_page.dart';

part 'app_router.g.dart';

// 라우트 경로 상수
class AppRoutes {
  static const home = '/';
  static const bookDetail = '/book/:id';
  static const cart = '/cart';
  static const auth = '/auth';
  static const order = '/order';
  static const wishlist = '/wishlist';

  static String bookDetailPath(String id) => '/book/$id';
}

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => _buildPage(
              state: state,
              child: const HomePage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.cart,
            pageBuilder: (context, state) => _buildPage(
              state: state,
              child: const CartPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.order,
            pageBuilder: (context, state) => _buildPage(
              state: state,
              child: const OrderPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.wishlist,
            pageBuilder: (context, state) => _buildPage(
              state: state,
              child: const WishlistPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.bookDetail,
        pageBuilder: (context, state) {
          final bookId = state.pathParameters['id']!;
          return _buildPage(
            state: state,
            child: BookDetailPage(bookId: bookId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.auth,
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const AuthPage(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('페이지를 찾을 수 없어요: ${state.error}'),
      ),
    ),
  );
}

CustomTransitionPage _buildPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}