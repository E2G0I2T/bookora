import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 768;
        if (isWide) {
          return _WebLayout(child: child);
        }
        return _MobileLayout(child: child);
      },
    );
  }
}

// 모바일 레이아웃 — 하단 네비게이션
class _MobileLayout extends StatelessWidget {
  final Widget child;
  const _MobileLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getIndex(location),
        onTap: (index) => _onTap(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: '장바구니',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: '주문내역',
          ),
        ],
      ),
    );
  }
}

// 웹 레이아웃 — 상단 네비게이션
class _WebLayout extends StatelessWidget {
  final Widget child;
  const _WebLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bookora',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          _NavButton(
            label: '홈',
            icon: Icons.home_outlined,
            isActive: location == '/',
            onTap: () => context.go('/'),
          ),
          _NavButton(
            label: '장바구니',
            icon: Icons.shopping_cart_outlined,
            isActive: location == '/cart',
            onTap: () => context.go('/cart'),
          ),
          _NavButton(
            label: '주문내역',
            icon: Icons.receipt_long_outlined,
            isActive: location == '/order',
            onTap: () => context.go('/order'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: child,
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: isActive ? AppColors.primary : AppColors.textSecondary,
        size: 20,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

int _getIndex(String location) {
  if (location == '/cart') return 1;
  if (location == '/order') return 2;
  return 0;
}

void _onTap(BuildContext context, int index) {
  switch (index) {
    case 0:
      context.go('/');
    case 1:
      context.go('/cart');
    case 2:
      context.go('/order');
  }
}