import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_store/features/employee/domain/repositories/employee_management_repository_interface.dart';
import 'package:sixam_mart_store/features/employee/domain/services/employee_management_service_interface.dart';

class EmployeeManagementService implements EmployeeManagementServiceInterface {
  final EmployeeManagementRepositoryInterface repository;
  EmployeeManagementService({required this.repository});

  @override
  Future<Response> getEmployees({String? search, int page = 1}) =>
      repository.getEmployees(search: search, page: page);

  @override
  Future<Response> getRoles() => repository.getRoles();

  @override
  Future<Response> getPermissions() => repository.getPermissions();

  @override
  Future<Response> createRole(
          {required String name, required List<String> modules}) =>
      repository.createRole(name: name, modules: modules);

  @override
  Future<Response> updateRole(int id,
          {required String name, required List<String> modules}) =>
      repository.updateRole(id, name: name, modules: modules);

  @override
  Future<Response> deleteRole(int id) => repository.deleteRole(id);

  @override
  Future<Response> createEmployee(Map<String, String> fields, XFile image) =>
      repository.createEmployee(fields, image);

  @override
  Future<Response> updateEmployee(
          int id, Map<String, String> fields, XFile? image) =>
      repository.updateEmployee(id, fields, image);

  @override
  Future<Response> deleteEmployee(int id) => repository.deleteEmployee(id);
}
