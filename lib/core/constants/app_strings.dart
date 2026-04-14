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
  static const splashLine1 = '지금 사고 싶은 거,';
  static const splashLine2 = '72시간 뒤에도 필요할까요?';

  // ── 로그인 ───────────────────────────────────────────────
  static const loginContinueWith = 'SNS 계정으로 계속하기';
  static const loginRequired = '로그인이 필요해요';
  static const loginGooglePrompt = 'Google 로그인으로 데이터를 보관하세요';
  static const loginGoogleButton = 'Google로 로그인';
  static const loginRequiredSnackbar = '로그인 후 이용할 수 있어요';

  // ── 홈 (참기 등록) ────────────────────────────────────────
  static const homeAddSheetTitle = '이 구매를 72시간 미뤄볼까요?';
  static const homeItemNameHint = '예: 발뮤다 토스터기, 나이키 운동화';
  static const homePriceHint = '얼마짜리예요?';
  static const homeReasonHint = '지금 사고 싶은 이유를 적어보세요';
  static const homeStartButton = '참기 시작하기';
  static const homeFabLabel = '참기 시작하기';
  static const homeItemNameRequired = '사고 싶은 물건을 입력해주세요';
  static const homePriceRequired = '가격을 입력해주세요';
  static const homeConfirmTitle = '참기 시작할까요?';
  static const homeConfirmBody = '72시간 동안 이 구매를 미루기로 합니다.\n그 사이에 마음이 바뀔 수도 있어요.';
  static const homeConfirmButton = '참기 시작';

  // ── 구매 전 체크리스트 ────────────────────────────────────
  static const checklistTitle = '잠깐, 마지막 점검!';
  static const checklistQ1 = '지금 당장 필요한가?';
  static const checklistQ2 = '이미 비슷한 게 있지는 않은가?';
  static const checklistQ3 = '한 달 후에도 쓸 것 같은가?';
  static const checklistConfirm = '그래도 살게요';

  // ── 이미지 첨부 ──────────────────────────────────────────
  static const homeImagePickerLabel = '사고 싶은 물건 사진 추가';
  static const homeImagePickerCamera = '사진 찍기';
  static const homeImagePickerGallery = '앨범에서 선택';
  static const homeImagePickerRemove = '사진 제거';

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
  static const wishExpiredText = '지금 결정하세요!';
  static String wishRemainingHours(int h, int m) => '$h시간 $m분 남음';
  static String wishRemainingMinutes(int m) => '$m분 남음';

  // ── 나눔 (커뮤니티) ─────────────────────────────────────
  static const exploreFabLabel = '내 경험 공유하기';
  static const exploreFilterAll = '전체';
  static const exploreFilterReview = '후기';
  static const exploreFilterTip = '팁';
  static const exploreSortRecent = '최신순';
  static const exploreSortPopular = '인기순';
  static const exploreEmptyPosts = '아직 게시글이 없어요\n첫 번째 나눔을 남겨보세요!';
  static const exploreLoadError = '불러오기 실패';
  static const exploreWriteSheetTitle = '어떤 이야기를 나눌까요?';
  static const exploreEditSheetTitle = '나눔 수정';
  static const exploreItemNameHint = '어떤 걸 참았나요? (선택)';
  static const exploreItemNameExample = '예: 발뮤다 토스터기';
  static const exploreResisted = '참았어요 💪';
  static const explorePurchased = '결국 샀어요 😅';
  static const exploreReviewHint = '왜 사고 싶었나요?\n72시간 동안 어떤 생각이 들었나요?\n결과는 어땠나요?';
  static const exploreTipHint = '소비 습관이나 절약에 도움이 된 팁을 공유해주세요.';
  static const explorePostSubmitButton = '내 경험 나누기';
  static const exploreEditSubmitButton = '수정 완료';
  static const exploreWriteReviewTitle = '72시간 버틴 이야기, 들려주세요 💪';
  static const exploreWriteTipTitle = '다른 사람에게 도움이 될 팁을 알려주세요 💡';
  static const exploreSubmitSuccess = '좋은 경험을 나눠주셔서 감사해요 🙌';
  static const exploreHelpOthers = '이 글이 다른 사람의 참기에 도움이 됩니다';
  static const exploreMenuEdit = '수정';
  static const exploreMenuDelete = '삭제';
  static const exploreDeleteTitle = '게시글을 삭제할까요?';
  static const exploreDeleteBody = '이 글에 달린 공감도 함께 사라집니다.\n삭제 후에는 되돌릴 수 없어요.';
  static const exploreDeleteConfirm = '삭제';

  // dynamic
  static String exploreResistStatus(bool resisted, String itemName) =>
      '72시간 후 ${resisted ? "참았어요" : "샀어요"} — $itemName';
  static String exploreLikeLabel(int count) => '$count명 공감';
  static String exploreSubmitError(Object e) => '등록 실패: $e';
  static String exploreEditError(Object e) => '수정 실패: $e';

  // ── 배움 섹션 레이블 ─────────────────────────────────────
  static const sectionConsumptionTips = '소비 습관 팁';
  static const sectionMinimalism = '미니멀리즘';
  static const section72hRule = '72시간 룰';

  // ── 마이 / 설정 ──────────────────────────────────────────
  static const myLearning = '소비 인사이트';
  static const mySettings = '설정';
  static const myNotificationSettings = '알림 설정';
  static const myNotificationSubtitle = '72시간 참기후 리마인드 알림';
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

  // ── 저축 목표 ────────────────────────────────────────────
  static const mySavingsGoalSection = '절약 목표';
  static const mySavingsGoalEmpty = '절약 목표를 설정해\n소비 동기를 만들어보세요';
  static const mySavingsGoalTitleHint = '목표 이름 (예: 내집마련, 여행)';
  static const mySavingsGoalAmountHint = '목표 금액';
  static const mySavingsGoalCurrentHint = '현재 저축 금액';
  static const mySavingsGoalAddTitle = '절약 목표 추가';
  static const mySavingsGoalEditTitle = '절약 목표';
  static const mySavingsGoalAddButton = '추가';
  static const mySavingsGoalUpdateButton = '업데이트';
  static const mySavingsGoalDeleteButton = '목표 삭제';
  static const mySavingsGoalTitleRequired = '목표 이름을 입력해주세요';
  static const mySavingsGoalAmountRequired = '목표 금액을 입력해주세요';
  static const mySavingsGoalReached = '목표 달성!';

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

  // 1시간 — 긍정 강화
  static const notif1hTitle = '72시간 참기 시작! ✅';
  static String notif1hBody(String name) =>
      '"$name" — 지금 이 결정이 현명한 선택의 시작이에요 🌿';

  // 24시간 — 경각심 자극
  static const notif24hTitle = '🔥 지금이 가장 위험한 순간이에요';
  static String notif24hBody(String name) =>
      '"$name" — 충동구매의 80%는 24시간 안에 일어납니다. 조금만 더 버텨보세요!';

  // 48시간 — 반문으로 성찰 유도
  static const notif48hTitle = '💪 벌써 48시간을 참았어요';
  static String notif48hBody(String name) =>
      '"$name" — 아직도 필요하다고 느껴지나요?';

  // 72시간 — 감정 확인
  static const notif72hTitle = '⏰ 72시간이 됐어요';
  static String notif72hBody(String name) =>
      '"$name" — 지금 어떤 마음인가요?';
}
