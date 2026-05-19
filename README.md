<div align="center">

<img src="https://play-lh.googleusercontent.com/rg4cd8ImucJXNXNtKHImg0rKlXstO0NdETPEDpISHwuiRNpje9GEn7Hcl_ysg_5t_6WLmTDg02poJrLumatALQ=w120-h120" width="80" />

# 지름막

**사기 전에, 72시간.**

충동구매를 막아주는 72시간 보류 습관 앱

[![Google Play](https://img.shields.io/badge/Google_Play-지름막-7C3AED?style=for-the-badge&logo=google-play&logoColor=white)](https://play.google.com/store/apps/details?id=com.pause72.jireummak&hl=ko)
[![Release](https://img.shields.io/github/v/release/pause72/jireummak?style=for-the-badge&color=7C3AED)](https://github.com/pause72/jireummak/releases)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)

</div>

---

## 💡 About

사고 싶은 물건이 생기면 바로 결제하지 말고 지름막에 등록하세요.  
**72시간 후에도 여전히 필요하다면**, 그건 진짜 필요한 거예요.

> 지름막은 소비를 **막는** 앱이 아닙니다. 한 번 더 **생각하게** 해주는 앱입니다.

---

## 🛠 Tech Stack

| Category | Stack |
|---|---|
| Framework | Flutter 3.x / Dart 3.x |
| State Management | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) + [riverpod_generator](https://pub.dev/packages/riverpod_generator) |
| Navigation | [go_router](https://pub.dev/packages/go_router) |
| Backend | Firebase Auth · Cloud Firestore · Firebase Functions |
| Data Modeling | [freezed](https://pub.dev/packages/freezed) + [json_serializable](https://pub.dev/packages/json_serializable) |
| Linting | [riverpod_lint](https://pub.dev/packages/riverpod_lint) + [custom_lint](https://pub.dev/packages/custom_lint) |

---

## 🏗 Architecture

Feature-first Clean Architecture — 각 feature는 3개의 레이어로 분리됩니다.

```
Presentation  →  Domain  ←  Data
(Riverpod)       (Models     (Firebase /
                  Repos)      Functions)
```

- **domain** — 순수 Dart. 외부 의존성 없음. 비즈니스 로직의 계약서.
- **data** — Firebase/Functions 구현체. domain의 repository 인터페이스를 구현.
- **presentation** — UI + Riverpod provider. domain을 통해서만 data에 접근.

---

## 📁 Project Structure

```
jireummak/
├── lib/
│   ├── main.dart                        # ProviderScope + Firebase init
│   ├── firebase_options.dart            # flutterfire CLI 자동 생성
│   ├── app/
│   │   ├── app.dart                     # MaterialApp.router + theme
│   │   └── router.dart                  # GoRouter (Riverpod provider)
│   ├── core/
│   │   ├── constants/
│   │   ├── errors/                      # Typed failure classes
│   │   ├── extensions/                  # Dart extension methods
│   │   ├── theme/                       # Light / Dark ThemeData
│   │   └── utils/
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── home/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   └── shared/
│       ├── providers/
│       └── widgets/
├── functions/                           # Firebase Cloud Functions (Node.js)
├── assets/
│   ├── images/
│   └── icons/
├── firebase.json
└── firestore.rules
```

---

## 🚀 Getting Started

### 1. 패키지 설치

```bash
flutter pub get
```

### 2. Firebase 연결

```bash
# FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# Firebase 연결 (firebase_options.dart 자동 생성)
flutterfire configure
```

### 3. 코드 생성

```bash
# 1회 빌드
dart run build_runner build --delete-conflicting-outputs

# 변경 감지 (개발 중)
dart run build_runner watch --delete-conflicting-outputs
```

### 4. 실행

```bash
flutter run
```

---

## ➕ Adding a New Feature

```
lib/features/<feature_name>/
├── data/
│   ├── datasources/<feature>_remote_datasource.dart
│   └── repositories/<feature>_repository_impl.dart
├── domain/
│   ├── models/<feature>_model.dart          # @freezed
│   └── repositories/<feature>_repository.dart
└── presentation/
    ├── pages/<feature>_page.dart
    ├── providers/<feature>_provider.dart    # @riverpod
    └── widgets/
```

---

## 📦 Code Generation

> `.g.dart`, `.freezed.dart` 파일은 git에 포함합니다 (CI 빌드 단순화).

| Generated File | Source |
|---|---|
| `*.g.dart` | `@riverpod`, `@JsonSerializable` |
| `*.freezed.dart` | `@freezed` |
| `router.g.dart` | `@riverpod` on GoRouter |

---

<div align="center">

Made with ❤️ by [pause72](https://github.com/pause72)

</div>
