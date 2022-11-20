class UserModel {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String bio;
  final List followers;
  final List following;

  const UserModel({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.username,
    required this.bio,
    required this.followers,
    required this.following,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'uid': uid,
      'email': email,
      'bio': bio,
      'photoUrl': photoUrl,
      'followers': followers,
      'following': following,
    };
  }

  static UserModel fromJson(Map<String, dynamic> json) {
    return UserModel(
        email: json['email'],
        uid: json['uid'],
        photoUrl: json['photoUrl'],
        username: json['username'],
        bio: json['bio'],
        followers: json['followers'],
        following: json['following']);
  }
}
