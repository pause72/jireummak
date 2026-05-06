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

  // ── 온보딩 ───────────────────────────────────────────────
  static const onboardingSkip = '건너뛰기';
  static const onboardingNext = '다음';
  static const onboardingStart = '시작하기';

  // 슬라이드 1
  static const onboarding1Headline1 = '지금 사고 싶은 거,';
  static const onboarding1Headline2 = '정말 필요한 걸까요?';
  static const onboarding1Body = '시간이 지나면 욕구도 줄어듭니다.\n72시간이 그 분기점이에요.';

  // 슬라이드 2
  static const onboarding2Headline = '이렇게 써보세요';
  static const onboarding2Feature1Title = '참기 등록';
  static const onboarding2Feature1Body = '사고 싶은 걸 등록하면\n72시간 카운트다운이 시작돼요';
  static const onboarding2Feature2Title = '기록 & 통계';
  static const onboarding2Feature2Body = '참기·구매 결과를 기록하고\n소비 패턴을 한눈에 확인해요';
  static const onboarding2Feature3Title = '공유 & 공감';
  static const onboarding2Feature3Body = '같은 고민을 가진 사람들과\n경험과 팁을 나눠요';
  static const onboarding2Feature4Title = '절약 목표 설정';
  static const onboarding2Feature4Body = '마이 탭에서 목표를 설정하면\n참을수록 목표에 가까워져요';

  // 슬라이드 3
  static const onboarding3Headline1 = '소비를 조금 더';
  static const onboarding3Headline2 = '똑똑하게';
  static const onboarding3Body = '72시간이 지나도 여전히 갖고 싶다면,\n그때 사세요. 그게 진짜 소비예요.';

  // ── 로그인 ───────────────────────────────────────────────
  static const loginSimpleStart = '간편하게 시작하기';
  static const loginGoogleContinue = 'Google로 계속하기';
  static const loginKakaoContinue = '카카오로 계속하기';
  static const loginContinueWith = 'SNS 계정으로 계속하기';
  static const loginRequired = '로그인이 필요해요';
  static const loginGooglePrompt = 'Google 로그인으로 데이터를 보관하세요';
  static const loginGoogleButton = 'Google로 로그인';
  static const loginRequiredSnackbar = '로그인 후 이용할 수 있어요';

  // ── 홈 (참기 등록) ────────────────────────────────────────
  static const homeAddSheetTitle = '이 구매를 72시간 미뤄볼까요?';
  static const homeItemNameHint = '예: 무선 청소기, 겨울 패딩, 러닝화';
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
  static const exploreItemNameExample = '예: 무선 청소기, 겨울 패딩, 러닝화';
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
  static const exploreTodayResisted = '오늘 참기 성공';
  static const exploreReviewCountLabel = '실전 후기';
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
  static const myHeroResisted = '참기 성공';
  static const myHeroTotalTime = '총 참기 시간';
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
      '충동구매 욕구의 피크는 처음 24시간 안에 옵니다. 72시간이 지나면 욕구가 평균 80% 이상 감소한다는 연구 결과가 있습니다.';
  static const rule2Title = '감정과 구매의 연결';
  static const rule2Body =
      '스트레스, 지루함, 슬픔을 쇼핑으로 해소하려는 패턴을 인식하세요. 감정이 격할 때 등록한 아이템은 72시간 후 대부분 필요 없어집니다.';
  static const rule3Title = '절약한 돈의 힘';
  static const rule3Body =
      '매달 충동구매를 3번만 참아도 연간 수십만 원이 모입니다. 참을 때마다 저축 목표에 그 금액을 이체하면 동기부여가 배가됩니다.';
  // ── 내비게이션 바 ─────────────────────────────────────────
  static const navResist = '참기';
  static const navRecord = '기록';
  static const navExplore = '공유';
  static const navMy = '마이';

  // ── 홈 - 등록 후 상태 ─────────────────────────────────────
  static String homeWaitingCount(int n) => '지금 $n개를 참고 있어요 💪';
  static const homeWaitingFooter =
      '잘 참고 있어요 🌿\n더 추가하고 싶은 게 있다면 참기 시작하기 버튼을 눌러보세요';
  static const homeSuccessSnackbarTitle = '좋은 선택이에요 💪';
  static const homeSlotFullTitle = '슬롯이 가득 찼어요';
  static String homeSlotFullBody(int freeSlots) =>
      '$freeSlots개까지 참기 등록이 가능해요.\n짧은 광고를 보면 하나 더 추가할 수 있어요.';
  static const homeWatchAdButton = '광고 보고 추가하기';
  static const homeAdNotReady = '광고를 불러오는 중이에요. 잠시 후 다시 시도해주세요.';

  static const motivationalMessages = [
    '72시간 후엔 마음이 달라져 있을 거예요 🌱',
    '참는 것도 연습이에요. 잘 하고 있어요 ✨',
    '지금 이 참음이 나중의 여유가 돼요 💰',
    '충동을 이겼어요. 대단해요! 🎉',
    '현명한 소비를 선택했어요 💪',
    '72시간 후 다시 물어볼게요. 그때도 사고 싶으면 그때 사요 😊',
  ];

  // ── 참기 카드 - 추가 ─────────────────────────────────────
  static const cardMenuEdit = '수정';
  static const cardMenuDelete = '삭제';
  static const cardEditTitle = '참기 수정';
  static const cardEditSubmit = '수정 완료';
  static const encouragementButton = '좋아요!';

  // ── 이유 기록 바텀시트 ────────────────────────────────────
  static const reasonsBuyLabel = '필요한 이유';
  static const reasonsResistLabel = '필요없는 이유';
  static const reasonsSheetSubtitle = '간단히 적어보면 충동이 줄어요 (선택)';
  static const reasonsFieldHint = '이유 입력 (선택)';
  static const reasonsAddButton = '이유 추가';
  static const reasonsCtaButton = '기록';
  static const reasonsHint1 = '72시간 뒤에도 이 이유가 유효할까요?';
  static const reasonsHint2 = '72시간 뒤의 나에게 맡겨보세요';

  // 비율바 레이블
  static const reasonsRatioEqual = '필요한 이유와 필요없는 이유가 같아요';
  static const reasonsRatioBuyMore = '필요한 이유가 더 많아요 — 72시간 뒤에 다시 확인해봐요';
  static const reasonsRatioResistMore = '필요없는 이유가 더 많아요 💪';

  // 저장 후 피드백 스낵바
  static const reasonsFeedbackDefault = '이미 충분히 고민하고 있어요 👍';
  static const reasonsFeedbackResistMore = '필요없는 이유가 더 많아요. 72시간 뒤에 다시 생각해봐요!';
  static const reasonsFeedbackBuyMore = '필요한 이유가 있네요. 72시간 뒤에도 같은 마음인지 확인해봐요.';
  static String reasonsFilledCount(int n) => '$n개';

  // 추천 칩
  static const buyChips = ['꼭 필요함', '삶의 질 올라갈 듯', '오래 쓸 것 같음', '계속 생각남', '나에게 보상'];
  static const resistChips = ['이미 비슷한 거 있음', '지금 감정임', '없어도 문제 없음', '가격 부담됨', '나중에도 살 수 있음'];

  static const resistMessages = <(String, String, String)>[
    ('🎉', '잘 참았어요!', '72시간을 버텨낸 현명한 선택이에요.\n이 절약이 쌓여 큰 자산이 될 거예요.'),
    ('💪', '충동을 이겼어요!', '참을 때마다 조금씩 더 강해지고 있어요.\n오늘의 절약, 정말 잘했어요!'),
    ('🌱', '훌륭해요!', '72시간이 지나 마음이 식었다면,\n그건 처음부터 충동이었던 거예요.'),
    ('✨', '멋진 선택이에요!', '사지 않는 것도 훌륭한 소비예요.\n절약한 돈은 더 의미 있는 곳에 쓰일 거예요.'),
    ('🏆', '대단해요!', '스스로를 이겨낸 오늘이 자랑스러워요.\n이 습관이 미래를 바꿔줄 거예요.'),
  ];

  static const purchaseMessages = <(String, String, String)>[
    ('🛒', '72시간 고민 끝의 선택이에요!', '구매 전 최저가를 꼭 확인하세요.\n네이버쇼핑이나 다나와를 활용해보세요!'),
    ('💡', '충분히 생각한 소비예요!', '구매 전 리뷰를 한 번 더 확인하고,\n최저가 알림을 설정해두면 더 좋아요.'),
    ('✅', '현명한 소비예요!', '충동이 아닌 확신으로 내린 결정이에요.\n좋은 가격에 구매하길 바라요!'),
    ('💰', '진짜 필요한 거니까 사는 거예요!', '구매 전 최저가 한 번만 더 확인해봐요.\n잘 쓰면 그것도 현명한 소비예요.'),
  ];

  // ── 기록 탭 ───────────────────────────────────────────────
  static const recordTotalSavedLabel = '💰 지금까지 아낀 금액';
  static const recordResistSuccessLabel = '🔥 참기 성공';
  static const recordPurchaseLabel = '🛍️ 구매';
  static const recordFilterAll = '전체';
  static const recordFilterResisted = '참음';
  static const recordFilterPurchased = '구매';
  static const recordSortRecent = '최근순';
  static const recordSortPriceHigh = '금액 높은순';
  static const badgeWaiting = '참기 중';
  static const badgePurchased = '구매 😅';
  static const badgeResisted = '성공 💪';
  static const recordEmptyLabel = '아직 기록이 없어요';
  static const recordDeclineButton = '안 살게요';
  static String daysAgo(int d) => '$d일 전';
  static String hoursAgo(int h) => '$h시간 전';
  static const justNow = '방금 전';
  static String recordResistedAgo(String ago) => '참기 성공 $ago';
  static String recordPurchasedAgo(String ago) => '구매 $ago';

  // ── 통계 탭 ───────────────────────────────────────────────
  static const statsPageTitle = '통계';
  static const amountZero = '₩ 0원';
  static const statsWaitingLabel = '참기';
  static String statsDecisionSummary(int decided, int cancelled) =>
      '결정한 $decided건 중 $cancelled건 취소';
  static String statsResistSummary(int decided, int cancelled) =>
      '결정한 $decided건 중 $cancelled건 참음';
  static String statsSpent(String amount) => '구매 지출 $amount';
  static const statsEmptyMessage = '아직 기록이 없어요.';
  static const statsEmptySubMessage =
      '갖고 싶은 게 생기면 글쓰기 버튼으로 72시간 참기를 시작해보세요.';
  static const statsNoCancelMessage = '아직 취소한 항목이 없어요.';
  static const statsNoCancelSubMessage = '72시간이 지나면 진짜 필요한지 다시 생각해보세요.';
  static const statsHighRateMessage = '대단해요! 충동구매를 잘 참고 있어요.';
  static const statsHighRateSubMessage = '절약한 금액으로 더 의미 있는 것에 투자해보세요.';
  static const statsMidRateMessage = '좋은 습관을 만들어가고 있어요.';
  static const statsMidRateSubMessage = '72시간 후 다시 생각하면 불필요한 소비가 보여요.';
  static const statsLowRateMessage = '조금씩 더 참아봐요.';
  static const statsLowRateSubMessage = '충동구매를 줄이면 소비 습관이 달라져요.';

  // ── 마이 - 닉네임 추가 ────────────────────────────────────
  static const nicknameChangeInfo = '30일에 한 번 변경할 수 있어요.';
  static String nicknameChangeDays(int d) => '$d일 후에 변경할 수 있어요.';
  static const nicknameRequired = '닉네임을 입력해주세요.';
  static const nicknameLoginRequired = '로그인이 필요해요.';
  static const nicknameSameAsCurrent = '현재 닉네임과 같아요.';
  static const nicknameDuplicate = '이미 사용 중인 닉네임이에요.';
  static const nicknamePermissionDenied = '변경 권한이 없어요. 다시 로그인 후 시도해 주세요.';
  static const nicknameErrorRetry = '오류가 발생했어요. 다시 시도해 주세요.';

  // ── 마이 - 절약 목표 다이얼로그 ──────────────────────────
  static const goalAddDialogTitle = '어떤 목표를 위해 참을까요?';
  static const goalMotivation = '이 목표를 위해 소비를 줄여보세요 💪';
  static const goalSetButton = '목표 설정하기';
  static const goalEditDialogTitle = '목표를 수정할까요?';
  static const goalUpdateButton = '목표 업데이트';
  static const goalEmptyAdd = '+ 목표를 설정해보세요 🎯';
  static const goalTitleHintAdd = '예: 내집마련, 여행가기, 아이폰 구매';
  static const goalTitleHintEdit = '예: 내집마련, 여행가기';
  static const goalAmountFieldHint = '목표 금액';
  static const goalEditShortLabel = '수정';
  static const goalAddShortLabel = '추가';
  static const goalQuickAdd1M = '+100만';
  static const goalQuickAdd5M = '+500만';
  static const goalQuickAdd10M = '+1000만';

  // ── 마이 - 레벨 / 진행 피드백 ──────────────────────────────
  // 레벨: 총 참기 일수(totalResistHours ~/ 24) 기준
  // Lv.1 < 7일 / Lv.2 7일+ / Lv.3 30일+ / Lv.4 100일+ / Lv.5 365일+
  static String levelBadge(int days) {
    if (days >= 365) return '🏆 Lv.5 절약마스터';
    if (days >= 100) return '💎 Lv.4 절약왕';
    if (days >= 30) return '🔥 Lv.3 참기고수';
    if (days >= 7) return '💪 Lv.2 절약러';
    return '🌱 Lv.1 절약 입문';
  }

  static String? levelNextInfo(int days) {
    if (days >= 365) return null;
    if (days >= 100) return '다음 레벨까지 ${365 - days}일';
    if (days >= 30) return '다음 레벨까지 ${100 - days}일';
    if (days >= 7) return '다음 레벨까지 ${30 - days}일';
    return '다음 레벨까지 ${7 - days}일';
  }

  static String progressFeedback(double progress) {
    if (progress >= 1.0) return '목표 달성! 🏆';
    if (progress >= 0.9) return '마지막 고비예요 ✨';
    if (progress >= 0.6) return '거의 다 왔어요 🔥';
    if (progress >= 0.3) return '잘 하고 있어요 💪';
    if (progress >= 0.1) return '좋은 출발이에요 👍';
    return '아직 시작이에요 🚀';
  }

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
