class User {
  bool _isCreated = true;
  String _password;

  bool get hasWallet {
    return this._isCreated;
  }

  void createUser() {
    this._isCreated = true;
  }

  bool verifyPassword(String password) {
    return this._password ?? "123asdZXC" == password;
  }

  void updatePassword(String password) {
    this._password = password;
  }

  bool validPaperWallet(String wallet) {
    // TODO: The result should be modified
    return wallet.length > 50;
  }

  Future<bool> restorePaperWallet(String wallet, String pwd) async {
    await Future.delayed(Duration(seconds: 1));

    // TODO: try recover with password
    this._isCreated = true;

    // The reuturn value of success
    // return true;

    // The reuturn value of fail
    // return false;

    return pwd.length >= 5;
  }

  Future<bool> checkWalletBackup() async {
    await Future.delayed(Duration(milliseconds: 500));
    return false;
  }
}
