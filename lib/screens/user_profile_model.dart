// lib/screens/user_profile_model.dart
class UserProfile {
  String? iconPath;
  String? firstName;
  String? lastName;

  UserProfile({
    this.iconPath,
    this.firstName,
    this.lastName,
  });

  // Crear un mapa desde el objeto para subir a Firestore
  Map<String, dynamic> toMap() {
    return {
      'iconPath': iconPath,
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  // Crear un objeto desde el mapa que se obtiene de Firestore
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      iconPath: map['iconPath'],
      firstName: map['firstName'],
      lastName: map['lastName'],
    );
  }
}
