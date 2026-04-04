abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = '서버 오류가 발생했습니다.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = '네트워크 연결을 확인해주세요.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = '인증 오류가 발생했습니다.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = '로컬 데이터 오류가 발생했습니다.']);
}
