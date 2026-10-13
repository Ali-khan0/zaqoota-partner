class EmployeePermissionOptionModel {
  final String key;
  final String label;

  const EmployeePermissionOptionModel({required this.key, required this.label});

  factory EmployeePermissionOptionModel.fromJson(Map<String, dynamic> json) {
    final key = json['key']?.toString() ?? '';
    final apiLabel = json['label']?.toString() ?? '';
    return EmployeePermissionOptionModel(
      key: key,
      // Some Laravel translation fallbacks return the translation key itself.
      // Do not expose that implementation detail in the mobile UI.
      label: apiLabel.startsWith('messages.') || apiLabel.isEmpty
          ? key
              .split('_')
              .map((part) => part.isEmpty
                  ? part
                  : '${part[0].toUpperCase()}${part.substring(1)}')
              .join(' ')
          : apiLabel,
    );
  }
}
