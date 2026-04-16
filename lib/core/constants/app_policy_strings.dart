/// 이용약관 및 개인정보 처리방침 문자열
///
/// 법적 내용이므로 별도 파일로 관리합니다.
/// 다국어 도입 시 이 파일을 ARB/intl 기반으로 교체하면 됩니다.
class AppPolicyStrings {
  AppPolicyStrings._();

  // ── 이용약관 ─────────────────────────────────────────────
  static const terms1Title = '제1조 (목적)';
  static const terms1Body =
      '본 약관은 지름막(이하 "앱")이 제공하는 서비스의 이용과 관련하여 앱과 이용자 간의 권리, 의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.';

  static const terms2Title = '제2조 (서비스 이용)';
  static const terms2Body =
      '① 앱은 충동구매를 방지하기 위한 72시간 대기 기능, 소비 기록 관리, 커뮤니티 나눔 기능을 제공합니다.\n② 서비스는 Google 계정을 통한 로그인 후 이용 가능하며, 일부 기능은 비로그인 상태에서도 사용할 수 있습니다.\n③ 이용자는 앱의 서비스를 개인적, 비상업적 목적으로만 이용할 수 있습니다.';

  static const terms3Title = '제3조 (이용자의 의무)';
  static const terms3Body =
      '① 이용자는 다음 행위를 해서는 안 됩니다.\n  - 타인의 정보를 도용하거나 허위 정보를 등록하는 행위\n  - 앱의 운영을 방해하거나 서버에 과부하를 유발하는 행위\n  - 커뮤니티에 욕설, 비방, 광고 등 부적절한 게시물을 작성하는 행위\n  - 관련 법령에 위반되는 행위\n② 이용자는 본 약관 및 관련 법령을 준수할 의무가 있습니다.';

  static const terms4Title = '제4조 (서비스 중단)';
  static const terms4Body =
      '앱은 다음의 경우 서비스 제공을 일시적으로 중단할 수 있습니다.\n  - 서버 점검, 교체, 고장, 통신두절 등의 경우\n  - 천재지변, 국가비상사태 등 불가항력적인 경우\n  - 기타 앱이 서비스 제공이 불가능하다고 판단하는 경우';

  static const terms5Title = '제5조 (광고)';
  static const terms5Body =
      '앱은 Google AdMob을 통한 광고를 제공할 수 있으며, 광고 수익은 서비스 운영 및 개선에 사용됩니다. 광고는 관련 법령에 따라 표시됩니다.';

  static const terms6Title = '제6조 (면책조항)';
  static const terms6Body =
      '① 앱은 이용자가 서비스를 통해 기대하는 수익이나 소비 절약 효과에 대해 보증하지 않습니다.\n② 이용자 간 커뮤니티 나눔 게시물의 내용에 대해 앱은 책임을 지지 않습니다.\n③ 앱은 무료로 제공되는 서비스의 중단으로 인한 손해에 대해 책임을 지지 않습니다.';

  static const terms7Title = '제7조 (약관의 변경)';
  static const terms7Body =
      '앱은 필요한 경우 약관을 변경할 수 있으며, 변경된 약관은 앱 내 공지를 통해 이용자에게 알립니다. 변경된 약관에 동의하지 않는 경우 서비스 이용을 중단하고 탈퇴할 수 있습니다.';

  static const termsAdditionalTitle = '부칙';
  static const termsAdditionalBody = '본 약관은 2026년 4월 1일부터 시행됩니다.';

  // ── 개인정보 처리방침 ──────────────────────────────────────
  static const privacy1Title = '1. 수집하는 개인정보';
  static const privacy1Body =
      '앱은 서비스 제공을 위해 다음과 같은 정보를 수집합니다.\n\n[필수 수집 항목]\n  - Google 계정 이메일, 프로필 사진 (로그인 시)\n  - 사용자가 입력한 참기 아이템 이름, 가격, 이유\n\n[자동 수집 항목]\n  - 기기 정보 (광고 제공 목적, Google AdMob)\n  - 앱 이용 기록';

  static const privacy2Title = '2. 개인정보의 수집 목적';
  static const privacy2Body =
      '수집한 개인정보는 다음 목적으로만 사용됩니다.\n  - 회원 식별 및 서비스 제공\n  - 소비 기록 저장 및 통계 제공\n  - 커뮤니티 나눔 서비스 운영\n  - 맞춤형 광고 제공 (Google AdMob)';

  static const privacy3Title = '3. 개인정보의 보유 및 이용기간';
  static const privacy3Body =
      '수집한 개인정보는 서비스 이용 기간 동안 보유하며, 회원 탈퇴 시 즉시 삭제합니다. 단, 관련 법령에 따라 일정 기간 보관이 필요한 경우 해당 기간 동안 보관합니다.';

  static const privacy4Title = '4. 개인정보의 제3자 제공';
  static const privacy4Body =
      '앱은 이용자의 개인정보를 원칙적으로 제3자에게 제공하지 않습니다. 다만, 다음의 경우는 예외입니다.\n  - 이용자가 사전에 동의한 경우\n  - 법령에 따라 수사기관의 요청이 있는 경우\n  - Google AdMob을 통한 광고 서비스 제공 (기기 식별 정보에 한함)';

  static const privacy5Title = '5. 개인정보 처리 위탁';
  static const privacy5Body =
      '앱은 서비스 운영을 위해 다음 업체에 개인정보 처리를 위탁합니다.\n\n  - Google Firebase (데이터 저장 및 인증)\n    위탁 목적: 회원 인증, 데이터 저장\n\n  - Google AdMob (광고 서비스)\n    위탁 목적: 광고 제공 및 분석';

  static const privacy6Title = '6. 이용자의 권리';
  static const privacy6Body =
      '이용자는 언제든지 다음의 권리를 행사할 수 있습니다.\n  - 개인정보 열람 요청\n  - 개인정보 수정 요청\n  - 개인정보 삭제 요청 (회원 탈퇴)\n  - 개인정보 처리 정지 요청\n\n위 권리 행사는 앱 내 설정 또는 이메일을 통해 요청하실 수 있습니다.';

  static const privacy7Title = '7. 개인정보 보호책임자';
  static const privacy7Body =
      '개인정보 처리에 관한 문의는 앱 내 이메일을 통해 연락해 주시기 바랍니다. 이용자의 문의에 성실히 답변하겠습니다.';

  static const privacy8Title = '8. 방침의 변경';
  static const privacy8Body =
      '본 개인정보 처리방침은 법령, 정책 변경에 따라 수정될 수 있으며 변경 시 앱 내 공지를 통해 안내합니다.\n\n시행일: 2026년 4월 1일';
}
