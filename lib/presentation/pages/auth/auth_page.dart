import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authAction = ref.read(authActionProvider);
      if (_isLogin) {
        await authAction.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await authAction.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLogin ? '로그인됐어요! 👋' : '회원가입 완료! 환영해요 🎉'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: ${_parseError(e.toString())}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _parseError(String error) {
    debugPrint('Auth 오류 원문: $error'); // 실제 오류 출력
    if (error.contains('Invalid login credentials')) return '이메일 또는 비밀번호가 틀렸어요';
    if (error.contains('User already registered')) return '이미 가입된 이메일이에요';
    if (error.contains('Password should be at least')) return '비밀번호는 6자 이상이어야 해요';
    if (error.contains('Email not confirmed')) return '이메일 인증이 필요해요';
    if (error.contains('network')) return '네트워크 연결을 확인해주세요';
    return error; // 원문 그대로 표시
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 로고
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.book,
                              color: Colors.white,
                              size: 40,
                            ),
                          ).animate().fadeIn().scale(),
                          const SizedBox(height: 12),
                          Text(
                            'Bookora',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(color: AppColors.primary),
                          ).animate().fadeIn(delay: 100.ms),
                          const SizedBox(height: 4),
                          Text(
                            _isLogin ? '다시 만나서 반가워요 👋' : '함께해요 🎉',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ).animate().fadeIn(delay: 150.ms),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 이메일
                    Text('이메일',
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'example@email.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return '이메일을 입력해주세요';
                        if (!value.contains('@')) return '올바른 이메일 형식이 아니에요';
                        return null;
                      },
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 16),

                    // 비밀번호
                    Text('비밀번호',
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        hintText: '6자 이상 입력해주세요',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return '비밀번호를 입력해주세요';
                        if (value.length < 6) return '비밀번호는 6자 이상이어야 해요';
                        return null;
                      },
                    ).animate().fadeIn(delay: 250.ms),
                    const SizedBox(height: 24),

                    // 제출 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_isLogin ? '로그인' : '회원가입'),
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 16),

                    // 전환 버튼
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            setState(() => _isLogin = !_isLogin),
                        child: Text(
                          _isLogin
                              ? '계정이 없으신가요? 회원가입'
                              : '이미 계정이 있으신가요? 로그인',
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ).animate().fadeIn(delay: 350.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}