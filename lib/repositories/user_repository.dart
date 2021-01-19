import '../cores/user.dart';

class UserRepository {
  User _user = new User();

  User get user => _user; 

  createUser() {
    _user.createUser();  
  }

  validPaperWallet(String wallet) {
    return _user.validPaperWallet(wallet);
  }
}
