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
}