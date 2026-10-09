class EmployeeRoleOptionModel {
  final int id;
  final String name;
  final List<String> modules;
  final int employeesCount;

  const EmployeeRoleOptionModel({
    required this.id,
    required this.name,
    this.modules = const [],
    this.employeesCount = 0,
  });

  factory EmployeeRoleOptionModel.fromJson(Map<String, dynamic> json) {
    return EmployeeRoleOptionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      modules: (json['modules'] as List<dynamic>? ?? [])
          .map((value) => value.toString())
          .toList(),
      employeesCount: (json['employees_count'] as num?)?.toInt() ?? 0,
    );
  }
}
