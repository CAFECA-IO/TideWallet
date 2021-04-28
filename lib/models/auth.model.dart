class AuthItem {
  final String token;
  final String tokenSecret;

  AuthItem({this.token, this.tokenSecret});

  AuthItem.fromJson(Map<String, dynamic> json):
   this.token = json['token'],
   this.tokenSecret = json['tokenSecret'];
  

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    
    data['token'] = this.token;
    data['tokenSecret'] = this.tokenSecret;

    return data;
  }

}