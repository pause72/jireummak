/// 앱 전체 UI 문자열 상수
///
/// 다국어(i18n) 도입 시 이 파일을 ARB/intl 기반으로 교체하면 됩니다.
/// 동적 문자열(파라미터 포함)은 static 메서드로 정의합니다.
class AppStrings {
  AppStrings._();

  // ── App 공통 ─────────────────────────────────────────────
  static const appName = '지름막';
  static const appTagline = '충동구매를 막는 72시간의 습관';
  static const appFooter = '지름막 · 충동구매를 막는 72시간의 습관';
  static const anonymous = '익명';
  static const cancel = '취소';
  static const loading = '로딩 중...';

  // ── Splash ───────────────────────────────────────────────
  static const splashLine1 = '사기 전에 72시간 참기,';
  static const splashLine2 = '진짜 필요한지 생각해보세요';

  // ── 로그인 ───────────────────────────────────────────────
  static const loginContinueWith = 'SNS 계정으로 계속하기';
  static const loginRequired = '로그인이 필요해요';
  static const loginGooglePrompt = 'Google 로그인으로 데이터를 보관하세요';
  static const loginGoogleButton = 'Google로 로그인';
  static const loginRequiredSnackbar = '로그인 후 이용할 수 있어요';

  // ── 홈 (참기 등록) ────────────────────────────────────────
  static const homeAddSheetTitle = '무엇을 사고 싶으신가요?';
  static const homeItemNameHint = '사고 싶은 물건 (필수)';
  static const homePriceHint = '가격 (필수)';
  static const homeReasonHint = '왜 사고 싶은가요? (선택)';
  static const homeStartButton = '72시간 시작';
  static const homeFabLabel = '72시간 참기';
  static const homeItemNameRequired = '사고 싶은 물건을 입력해주세요';
  static const homePriceRequired = '가격을 입력해주세요';

  // ── 빈 상태 ─────────────────────────────────────────────
  static const emptyWaitingTitle = '오늘은 욕심이 없는 날이네요';
  static const emptyWaitingBody =
      '갖고 싶은 게 생기면 글쓰기 버튼으로\n72시간 참기를 시작해보세요';

  // ── 참기 카드 ────────────────────────────────────────────
  static const cardDecisionBadge = '결정!';
  static const cardBuy = '살게요';
  static const cardResist = '참을게요';
  static const cardDeleteContent = '참기를 중지할까요?';
  static const cardDeleteCancel = '계속참기';
  static const cardDeleteConfirm = '중지';

  // ── 참기 아이템 남은 시간 ────────────────────────────────
  static const wishExpiredText = '72시간 완료 — 결정할 시간!';
  static String wishRemainingHours(int h, int m) => '$h시간 $m분 남음';
  static String wishRemainingMinutes(int m) => '$m분 남음';

  // ── 나눔 (커뮤니티) ─────────────────────────────────────
  static const exploreFabLabel = '나눔등록';
  static const exploreSearchHint = '내용 검색';
  static const exploreFilterAll = '전체';
  static const exploreFilterReview = '후기';
  static const exploreFilterTip = '팁';
  static const exploreEmptyPosts = '아직 게시글이 없어요\n첫 번째 나눔을 남겨보세요!';
  static const exploreLoadError = '불러오기 실패';
  static const exploreWriteSheetTitle = '어떤 이야기를 나눌까요?';
  static const exploreEditSheetTitle = '나눔 수정';
  static const exploreItemNameHint = '참기 아이템 이름 (선택)';
  static const exploreResisted = '참았어요';
  static const explorePurchased = '샀어요';
  static const exploreReviewHint = '72시간 참기 후기를 자유롭게 남겨주세요.';
  static const exploreTipHint = '소비 습관이나 절약에 도움이 된 팁을 공유해주세요.';
  static const explorePostSubmitButton = '나눔 등록';
  static const exploreEditSubmitButton = '수정 완료';

  // dynamic
  static String exploreResistStatus(bool resisted, String itemName) =>
      '72시간 후 ${resisted ? "참았어요" : "샀어요"} — $itemName';
  static String exploreSubmitError(Object e) => '등록 실패: $e';
  static String exploreEditError(Object e) => '수정 실패: $e';

  // ── 배움 섹션 레이블 ─────────────────────────────────────
  static const sectionConsumptionTips = '소비 습관 팁';
  static const sectionMinimalism = '미니멀리즘';
  static const section72hRule = '72시간 룰';

  // ── 마이 / 설정 ──────────────────────────────────────────
  static const myLearning = '배움';
  static const mySettings = '설정';
  static const myNotificationSettings = '알림 설정';
  static const myAppInfo = '앱 정보';
  static const myVersion = '버전';
  static const myTerms = '이용약관';
  static const myPrivacy = '개인정보 처리방침';
  static const myLogout = '로그아웃';
  static const myLogoutConfirmBody = '로그아웃 하시겠어요?';
  static const myTotalSaved = '총 절약 금액';
  static const myResisted = '참음';
  static const myPurchased = '구매';
  static const myTotalRegistered = '총 등록';
  static const myResistanceRate = '충동구매 저항률';
  static const myNicknameHint = '닉네임 1회 변경 가능';
  static const myTheme = '테마';

  // ── 닉네임 다이얼로그 ─────────────────────────────────────
  static const nicknameChangeTitle = '닉네임 변경';
  static const nicknameChangeWarning = '닉네임은 한 번만 변경할 수 있어요.';
  static const nicknameInputHint = '새 닉네임 입력';
  static const nicknameChangeButton = '변경';

  // ── 배움 콘텐츠 — 명언 ────────────────────────────────────
  static const learnQuoteText =
      '지금 살 여유가 없는 것은 나중에도 살 여유가 없다.\n하지만 지금 참을 수 있다면 나중엔 더 잘 살 수 있다.';
  static const learnQuoteAuthor = '— 미니멀리즘 격언';

  // ── 배움 콘텐츠 — 소비 습관 팁 ───────────────────────────
  static const tip1Title = '장바구니 24시간 방치하기';
  static const tip1Body =
      '온라인 쇼핑몰 장바구니에 담아두고 하루가 지나도 사고 싶으면 그때 구매하세요. 충동 구매의 70%가 이 과정에서 걸러집니다.';
  static const tip2Title = '소비 전 "왜?"를 3번 묻기';
  static const tip2Body =
      '"왜 사고 싶지?" → "정말 필요한가?" → "없으면 어떻게 될까?" 세 질문을 통과한 구매만이 진짜 필요한 소비입니다.';
  static const tip3Title = '1개 사면 1개 버리기';
  static const tip3Body =
      '새 물건을 들이기 전에 비슷한 물건을 먼저 처분하는 규칙. 소유물이 늘지 않고 물건의 가치를 더 신중히 따지게 됩니다.';

  // ── 배움 콘텐츠 — 미니멀리즘 ─────────────────────────────
  static const minimal1Title = '공간이 곧 자유다';
  static const minimal1Body =
      '물건이 많을수록 관리할 것도 많아집니다. 비워진 공간은 새로운 가능성을 만들어줍니다. 소유를 줄이면 마음도 가벼워집니다.';
  static const minimal2Title = '품질 vs 수량';
  static const minimal2Body =
      '싼 물건 10개보다 좋은 물건 1개가 낫습니다. 자주 쓰는 물건에 투자하고, 나머지는 빌리거나 포기하는 습관을 들이세요.';

  // ── 배움 콘텐츠 — 72시간 룰 ──────────────────────────────
  static const rule1Title = '왜 72시간인가?';
  static const rule1Body =
      '충동구매 욕구의 피크는 처음 24시간 안에 옵니다. 72시간(3일)이 지나면 욕구가 평균 80% 이상 감소한다는 연구 결과가 있습니다.';
  static const rule2Title = '감정과 구매의 연결';
  static const rule2Body =
      '스트레스, 지루함, 슬픔을 쇼핑으로 해소하려는 패턴을 인식하세요. 감정이 격할 때 등록한 아이템은 72시간 후 대부분 필요 없어집니다.';
  static const rule3Title = '절약한 돈의 힘';
  static const rule3Body =
      '매달 충동구매를 3번만 참아도 연간 수십만 원이 모입니다. 참을 때마다 저축 목표에 그 금액을 이체하면 동기부여가 배가됩니다.';

  // ── 알림 ────────────────────────────────────────────────
  static const notifChannelName = '참기 알림';
  static const notifChannelDesc = '72시간 참기 진행 알림';
  static const notif24hTitle = '하루가 지났어요';
  static const notif48hTitle = '이틀이 지났어요';
  static const notif72hTitle = '72시간을 참으셨어요!';
  static String notif24hBody(String name) =>
      '"$name" — 아직 사고 싶으신가요? 이틀 더 참아봐요!';
  static String notif48hBody(String name) =>
      '"$name" — 거의 다 왔어요! 하루만 더 버텨봐요.';
  static String notif72hBody(String name) =>
      '"$name" — 이제 결정할 시간이에요. 살까요, 참을까요?';
}
