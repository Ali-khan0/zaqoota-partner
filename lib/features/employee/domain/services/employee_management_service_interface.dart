import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

abstract class EmployeeManagementServiceInterface {
  Future<Response> getEmployees({String? search, int page = 1});
  Future<Response> getRoles();
  Future<Response> getPermissions();
  Future<Response> createRole(
      {required String name, required List<String> modules});
  Future<Response> updateRole(int id,
      {required String name, required List<String> modules});
  Future<Response> deleteRole(int id);
  Future<Response> createEmployee(Map<String, String> fields, XFile image);
  Future<Response> updateEmployee(
      int id, Map<String, String> fields, XFile? image);
  Future<Response> deleteEmployee(int id);
}
