import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase 클라이언트 Provider
final supabaseProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

// 현재 유저 상태
final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange;
});

// 현재 유저
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(data: (state) => state.session?.user);
});

// 로그인 여부
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// Auth 액션
final authActionProvider = Provider<AuthAction>((ref) {
  return AuthAction(ref.watch(supabaseProvider));
});

class AuthAction {
  final SupabaseClient _supabase;

  AuthAction(this._supabase);

  // 이메일 회원가입
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  // 이메일 로그인
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // 로그아웃
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}