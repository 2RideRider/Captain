class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? profileImage;
  final double? walletBalance;
  final double? ratings;
  final bool? isVerified;
  final bool? isOnline;
  final Map<String, dynamic>? vehicle;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.walletBalance,
    this.ratings,
    this.isVerified,
    this.isOnline,
    this.vehicle,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      profileImage: json['profileImage'] as String?,
      walletBalance: json['walletBalance'] != null ? (json['walletBalance'] as num).toDouble() : null,
      ratings: json['ratings'] != null ? (json['ratings'] as num).toDouble() : null,
      isVerified: json['isVerified'] as bool?,
      isOnline: json['isOnline'] as bool?,
      vehicle: json['vehicle'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profileImage': profileImage,
      'walletBalance': walletBalance,
      'ratings': ratings,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'vehicle': vehicle,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? profileImage,
    double? walletBalance,
    double? ratings,
    bool? isVerified,
    bool? isOnline,
    Map<String, dynamic>? vehicle,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      walletBalance: walletBalance ?? this.walletBalance,
      ratings: ratings ?? this.ratings,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      vehicle: vehicle ?? this.vehicle,
    );
  }
}
