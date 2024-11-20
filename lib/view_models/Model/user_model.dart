
class UserModel {
  String firstName;
  String lastName;
  String gender;
  String email;
  String createdAt;
  String phoneNumber;
  String uid;


  UserModel(
      {required this.firstName,
        required this.lastName,
        required this.gender,
        required this.email,
        required this.createdAt,
        required this.phoneNumber,
        required this.uid,
      });
// from map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        firstName: map['firstName']??'',
        lastName: map['lastName']??'',
        email: map['email']??'',
        gender: map['gender']??'',
        createdAt: map['createdAt']??'',
        phoneNumber: map['phoneNumber']??'',
        uid: map['uid']??'',
    );
  }


  // to map
  Map<String,dynamic>toMap(){
    return {
      "firstName":firstName,
      "lastName":lastName,
      "gender":gender,
      "email":email,
      "createdAt":createdAt,
      "phoneNumber":phoneNumber,
      "uid":uid,
    };
  }
}
