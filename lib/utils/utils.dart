class LogMessage {
  final String Tag;
  LogMessage({required this.Tag});

  void LogPrint({String? method, required String message}) {
    print("$Tag=> $method : $message");
    return;
  }
}
