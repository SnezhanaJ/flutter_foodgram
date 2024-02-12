class Usermodel {
  String email;
  String username;
  String profile;
  List following;
  List followers;
  final String uid;
  Usermodel(this.email, this.followers, this.following, this.profile,
      this.username, this.uid);
}