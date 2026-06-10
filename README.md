# 📚 Bookora

> Flutter 기반 크로스플랫폼 도서 쇼핑 앱 (Android + Web)

[![Flutter](https://img.shields.io/badge/Flutter-3.44.0-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12.0-blue?logo=dart)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-2.12.4-green?logo=supabase)](https://supabase.com)
[![Firebase](https://img.shields.io/badge/Firebase-Hosting-orange?logo=firebase)](https://firebase.google.com)

## 🌐 배포 URL

**[https://bookora-a58e9.web.app](https://bookora-a58e9.web.app)**

---

## 📱 주요 기능

| 기능 | 설명 |
|------|------|
| 📖 도서 검색 | 카카오 도서 검색 API 연동, 실시간 디바운스 검색 |
| 🏆 베스트셀러 | 실시간 베스트셀러 목록 가로 스크롤 |
| 🗂 카테고리 | 소설/경제/IT/자기계발 등 카테고리별 도서 탐색 |
| 📄 도서 상세 | 도서 상세 정보, 할인율, 책 소개 |
| 🛒 장바구니 | 담기/삭제/전체삭제, 총액 계산 |
| ❤️ 찜 목록 | 찜하기/해제, Supabase 서버 동기화 |
| 📦 주문 | 장바구니/바로구매, 배송·결제 정보 확인 후 주문 |
| 🧾 주문 내역 | 주문 목록, 배송 상태, 배송·결제 정보 표시 |
| 👤 마이페이지 | 프로필, 기본 배송지(카카오 주소 검색), 결제 수단 설정 |
| 🔐 인증 | Supabase Auth 이메일 로그인/회원가입/로그아웃 |

---

## 🛠 기술 스택

### Frontend
- **Flutter 3.44.0** — 단일 코드베이스로 Android/Web 동시 지원
- **Riverpod 3.x** — 전역 상태관리 (NotifierProvider 패턴)
- **GoRouter** — 웹 URL 지원 라우팅, ShellRoute 기반 네비게이션
- **flutter_animate** — 페이지 전환 및 위젯 애니메이션
- **cached_network_image** — 이미지 캐싱 최적화

### Backend & 인프라
- **Supabase** — Auth, PostgreSQL DB, Row Level Security
- **Firebase Hosting** — 웹 배포
- **카카오 도서 검색 API** — 실시간 도서 데이터
- **카카오 우편번호 API** — 주소 검색 (GitHub Pages 연동)

### 아키텍처
lib/
├── core/
│   ├── constants/       # 환경변수
│   ├── router/          # GoRouter 설정
│   ├── theme/           # 앱 테마, 컬러 시스템
│   └── widgets/         # 공통 레이아웃 (MainShell)
├── data/
│   ├── datasources/     # 카카오 API
│   ├── models/          # BookModel
│   └── repositories/    # BookRepository, SupabaseRepository
└── presentation/
├── pages/           # 홈/상세/장바구니/주문/찜/마이페이지/인증
├── providers/       # Riverpod Providers
└── widgets/         # 재사용 위젯 (BookCard, SkeletonUI 등)

---

## 📸 스크린샷

> 모바일 (Android) / 웹 스크린샷 추가 예정

---

## 🚀 시작하기

### 사전 준비
- Flutter 3.44.0 이상
- Dart 3.12.0 이상
- Android Studio 또는 VS Code

### 설치

```bash
# 저장소 클론
git clone https://github.com/E2G0I2T/bookora.git
cd bookora

# 패키지 설치
flutter pub get

# 코드 생성
dart run build_runner build
```

### 환경 변수 설정

`lib/core/constants/supabase_constants.dart` 파일에 본인의 Supabase 정보를 입력해주세요.

```dart
class SupabaseConstants {
  static const supabaseUrl = 'YOUR_SUPABASE_URL';
  static const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

`lib/data/datasources/kakao_book_datasource.dart` 파일에 카카오 REST API 키를 입력해주세요.

```dart
const _kakaoApiKey = 'YOUR_KAKAO_API_KEY';
```

### 실행

```bash
# Android
flutter run -d [device_id]

# Web
flutter run -d chrome
```

---

## 🗄 데이터베이스 구조

```sql
-- 주문
orders (id, user_id, total_price, status, created_at)

-- 주문 아이템
order_items (id, order_id, isbn, title, authors, thumbnail, price)

-- 찜 목록
wishlists (id, user_id, isbn, title, authors, thumbnail, price)
```

---

## ✨ 포트폴리오 어필 포인트

- **크로스플랫폼** — Flutter 단일 코드로 Android/Web 동시 구현
- **반응형 UI** — 모바일(하단 탭) ↔ 웹(상단 네비) 자동 전환
- **클린 아키텍처** — data / presentation / core 레이어 분리
- **Riverpod** — 현업 표준 상태관리 패턴 적용
- **외부 API 연동** — 카카오 도서/주소 검색 API
- **Supabase** — Auth + DB + RLS 보안 정책
- **스켈레톤 UI** — 로딩 상태 UX 개선
- **검색 디바운스** — API 호출 최적화
- **WebView 연동** — 카카오 우편번호 검색 네이티브 연동

---

## 👨‍💻 개발자

**Lee** · [GitHub](https://github.com/E2G0I2T)