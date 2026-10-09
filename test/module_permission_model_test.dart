import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart_store/features/auth/domain/models/module_permission_model.dart';

void main() {
  group('Vendor module access', () {
    test('owner retains full access when role data is absent', () {
      final permissions = ModulePermissionModel.forVendorSession(
        isOwner: true,
      );

      expect(permissions.order, isTrue);
      expect(permissions.employee, isTrue);
      expect(permissions.role, isTrue);
      expect(permissions.chat, isTrue);
    });

    test('employee with missing or empty role modules gets no access', () {
      for (final modules in <List<String>?>[null, <String>[]]) {
        final permissions = ModulePermissionModel.forVendorSession(
          isOwner: false,
          assignedModules: modules,
        );

        expect(permissions.dashboard, isFalse);
        expect(permissions.order, isFalse);
        expect(permissions.employee, isFalse);
        expect(permissions.role, isFalse);
      }
    });

    test('employee receives only assigned modules', () {
      final permissions = ModulePermissionModel.forVendorSession(
        isOwner: false,
        assignedModules: const ['order', 'chat'],
      );

      expect(permissions.order, isTrue);
      expect(permissions.chat, isTrue);
      expect(permissions.dashboard, isFalse);
      expect(permissions.employee, isFalse);
      expect(permissions.role, isFalse);
    });
  });
}
