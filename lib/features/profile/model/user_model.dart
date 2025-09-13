class UserModel {
  String name;
  String surname;
  String email;
  String country;
  String phone;
  String birthdate;
  String avatarId;
  int points;

  UserModel({
    required this.name,
    required this.surname,
    required this.email,
    required this.country,
    required this.phone,
    required this.birthdate,
    required this.avatarId,
    required this.points,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['nom'] ?? '',
      surname: json['prenom'] ?? '',
      email: json['email'] ?? '',
      country: json['localisation'] ?? '',
      phone: json['numTel'] ?? '',
      birthdate: json['birthday'] ?? '',
      avatarId: json['avatarId'] ?? '',
      points: json['point'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': name,
      'prenom': surname,
      'email': email,
      'localisation': country,
      'numTel': phone,
      'birthday': birthdate.split('T')[0], // Format: YYYY-MM-DD
      'avatarId': avatarId,
      'point': points,
    };
  }
}
