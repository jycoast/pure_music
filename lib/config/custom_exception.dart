/// 接口的code没有返回为true的异常
class NotSuccessException implements Exception {
  String error;

  // NotSuccessException.fromRespData(BaseResponseData respData) {
  //   error = respData.error;
  // }

  @override
  String toString() {
    return 'NotExpectedException{respData: $error}';
  }
}

/// 用于未登录等权限不够,需要跳转授权页面
class UnAuthorizedException implements Exception {
  const UnAuthorizedException();

  @override
  String toString() => 'UnAuthorizedException';
}