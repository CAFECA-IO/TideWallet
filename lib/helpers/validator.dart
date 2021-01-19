class Validator {
  List<bool> validPassword(String pwd, String walletName) {
    final List<bool> result = [];

    result.add(_validPasswordLength(pwd));
    result.add(_validPasswordLeastOneNumber(pwd));
    result.add(_validLowerAndUpperCase(pwd));
    result.add(_validDiffWithWalletName(pwd, walletName));

    return result;
  }

  bool _validPasswordLength(String pwd) {
    return pwd.length >= 8 && pwd.length <= 20; 
  }

  bool _validPasswordLeastOneNumber(String pwd) {
    RegExp regex = new RegExp('.*[0-9].*');

    return regex.hasMatch(pwd);
  }

  bool _validLowerAndUpperCase(String pwd) {
    RegExp regex = new RegExp('(?=.*[a-z])(?=.*[A-Z])');

    return regex.hasMatch(pwd);
  }

  bool _validDiffWithWalletName(String pwd, String walletName) {
    return pwd != walletName;
  }

}