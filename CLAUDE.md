# CLAUDE.md

> Claude Code 및 Claude.ai와의 협업을 위한 컨텍스트 파일  
> 마지막 업데이트: 2026-04

---

## 👤 나에 대해서

- **직업**: 솔로프리너 (전 10년차 모바일 앱 개발자)
- **목표**: 직접 만든 앱으로 수익화, 재정적 자유
- **작업 환경**: MacBook 2대 (Apple Silicon), Flutter/Dart 주력
- **성향**: 미니멀리스트, 절약 지향, 장기적 관점 선호

---

## 📱 앱 개발 프로젝트

### 현재 프로젝트: 지름막

- **앱 이름**: 지름막
- **컨셉**: 72시간 구매 대기를 통한 충동구매 억제 앱
- **타겟**: 20~40대 절약/미니멀 라이프 지향자
- **스택**: Flutter · Firebase · Riverpod
- **배포 대상**: iOS / Android (App Store / Google Play)
- **언어**: 한국어 앱, 코드 주석은 영어

### 개발 원칙

- 솔로프리너 기준으로 유지보수가 쉬운 구조 우선
- 과도한 추상화보다 명확하고 읽기 쉬운 코드 선호
- 기능보다 완성도: 작더라도 제대로 동작하는 것 우선
- Firebase 비용을 최소화하는 설계 지향

### 코드 스타일 가이드

```dart
// ✅ 선호
final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

// ❌ 비선호 (과도한 레이어)
final userRef = _firestoreService.getUserDocumentReference(uid);
```

- Riverpod: `@riverpod` 코드 생성 방식 사용
- 상태관리: AsyncNotifier / Notifier 패턴
- 파일 구조: feature-first (기능 단위 폴더링)
- 네이밍: 파일명 `snake_case`, 클래스명 `PascalCase`

### 요청 시 기본 동작

- 코드 제안 시 **전체 파일** 또는 **교체 가능한 단위**로 제공
- 변경 이유를 간단히 설명 후 코드 제시
- Flutter/Dart 최신 stable 버전 기준
- pub.dev 패키지 추천 시 popularity + 최근 업데이트 여부 함께 언급

---

## 📈 주식 투자

### 투자 성향

- **스타일**: 장기 가치투자 지향, 단기 트레이딩 관심 없음
- **시장**: 미국 주식 중심 (한국 주식 일부)
- **관심 섹터**: 기술주, AI 인프라, 소비재
- **리스크 성향**: 보수적 ~ 중립 (원금 보전 중시)
- **참고 철학**: 절약-투자-복리의 장기 사이클

### Claude에게 기대하는 역할

- 특정 종목의 **정량적 지표** 요약 (PER, PBR, 부채비율 등)
- 섹터 트렌드 및 뉴스 요약 (최신 검색 활용)
- **투자 결정은 내가 함** — Claude는 데이터와 관점 제공자
- "지금 사야 하나요?" 같은 질문엔 데이터 기반 분석으로 답변

### 주의사항

- 확정적 수익 예측이나 강한 매수/매도 추천은 하지 않아도 됨
- 대신 "이런 리스크가 있다", "이런 지표가 긍정적이다" 형태로 설명
- 환율, 금리 영향 등 매크로 요소도 함께 언급해주면 좋음

---

## 🤝 협업 스타일

### 커뮤니케이션

- **언어**: 한국어로 대화, 코드·명령어는 영어
- **톤**: 간결하고 실용적으로. 불필요한 격식 없이
- **설명 수준**: 10년차 개발자 기준 — 기초 설명 생략 가능
- 모르는 부분은 솔직하게 "모른다"고 말해줘

### 응답 형식 선호

- 긴 설명보다 **핵심 먼저, 세부사항 나중에**
- 선택지가 있을 때는 **추천 1개 + 이유** 방식 선호
- 코드 블록은 항상 언어 명시 (` ```dart `, ` ```bash ` 등)
- 체크리스트나 단계별 가이드는 번호 목록으로

### 하지 말아야 할 것

- 이미 알고 있는 Flutter/Dart 기초 개념 재설명
- "훌륭한 질문입니다" 같은 과도한 칭찬
- 확실하지 않은 정보를 확실한 것처럼 제시
- 투자에 대한 확정적 수익 예측

---

## 📁 프로젝트 구조 (참고용)

```
jiruemmak/                    # 지름막 앱 루트
├── lib/
│   ├── features/
│   │   ├── purchase/         # 구매 대기 핵심 기능
│   │   ├── history/          # 구매 이력
│   │   └── settings/         # 설정
│   ├── core/
│   │   ├── theme/
│   │   └── utils/
│   └── main.dart
├── test/
├── pubspec.yaml
└── CLAUDE.md                 # 이 파일
```

---

## 🔖 자주 쓰는 명령 패턴

```bash
# Flutter 빌드 및 실행
flutter run --flavor development

# 코드 생성 (Riverpod)
dart run build_runner build --delete-conflicting-outputs

# Firebase 배포
firebase deploy --only firestore:rules
```

---

*이 파일은 프로젝트 루트 또는 홈 디렉토리에 위치시키고, 내용이 바뀔 때마다 업데이트하세요.*
