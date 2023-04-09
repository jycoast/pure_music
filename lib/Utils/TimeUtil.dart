





class TimeUtil2 {
  static String _durationTransform(int seconds) {
    var d = Duration(seconds: seconds);
    List<String> parts = d.toString().split(':');
    return '${parts[1]}分${parts[2].substring(0, 2)}秒';
  }
}
