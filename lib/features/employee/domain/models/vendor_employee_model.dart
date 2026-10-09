class VendorEmployeeModel {
  final int id;
  final String firstName;
  final String? lastName;
  final String phone;
  final String email;
  final String image;
  final int roleId;
  final String? roleName;

  const VendorEmployeeModel({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.phone,
    required this.email,
    required this.image,
    required this.roleId,
    this.roleName,
  });

  factory VendorEmployeeModel.fromJson(Map<String, dynamic> json) {
    final dynamic role = json['role'];
    return VendorEmployeeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      firstName: json['f_name']?.toString() ?? '',
      lastName: json['l_name']?.toString(),
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      roleId: (json['role_id'] as num?)?.toInt() ?? 0,
      roleName: role is Map<String, dynamic> ? role['name']?.toString() : null,
    );
  }
}
