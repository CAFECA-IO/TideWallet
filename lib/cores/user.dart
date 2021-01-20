class User {
  bool _isCreated = false;

  bool get hasWallet {
    return this._isCreated;
  }

  void createUser() {
    this._isCreated = true;
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
    return true;

    // The reuturn value of fail
    // return false;
  }
}
