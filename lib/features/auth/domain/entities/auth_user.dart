import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String uid;
  final String role;
  final bool isNewUser;
  final Map<String, dynamic>? newUserData;

  const AuthUser({
    required this.uid,
    this.role = 'driver',
    this.isNewUser = false,
    this.newUserData,
  });

  @override
  List<Object?> get props => [uid, role, isNewUser, newUserData];
}