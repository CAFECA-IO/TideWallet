class User {
  bool _isCreated = false;

  bool get hasWallet {
    return this._isCreated;
  }

  createUser() {
    this._isCreated = true;
  }
}