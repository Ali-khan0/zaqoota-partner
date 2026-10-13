import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/features/employee/domain/repositories/employee_management_repository_interface.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

class EmployeeManagementRepository
    implements EmployeeManagementRepositoryInterface {
  final ApiClient apiClient;
  EmployeeManagementRepository({required this.apiClient});

  @override
  Future<Response> getEmployees({String? search, int page = 1}) {
    final query = <String, String>{'page': page.toString(), 'per_page': '50'};
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    final uri = Uri(queryParameters: query).query;
    return apiClient.getData('${AppConstants.employeeListUri}?$uri',
        handleError: false);
  }

  @override
  Future<Response> getRoles() =>
      apiClient.getData('${AppConstants.employeeRolesUri}?per_page=50',
          handleError: false);

  @override
  Future<Response> getPermissions() =>
      apiClient.getData('${AppConstants.employeeManagementUri}/permissions',
          handleError: false);

  @override
  Future<Response> createRole(
          {required String name, required List<String> modules}) =>
      apiClient.postData(
          AppConstants.employeeRolesUri, {'name': name, 'modules': modules},
          handleError: false);

  @override
  Future<Response> updateRole(int id,
          {required String name, required List<String> modules}) =>
      apiClient.putData('${AppConstants.employeeRolesUri}/$id',
          {'name': name, 'modules': modules},
          handleError: false);

  @override
  Future<Response> deleteRole(int id) => apiClient
      .deleteData('${AppConstants.employeeRolesUri}/$id', handleError: false);

  @override
  Future<Response> createEmployee(Map<String, String> fields, XFile image) {
    return apiClient.postMultipartData(
      AppConstants.employeeListUri,
      fields,
      [MultipartBody('image', image)],
      handleError: false,
    );
  }

  @override
  Future<Response> updateEmployee(
      int id, Map<String, String> fields, XFile? image) {
    final body = {...fields, '_method': 'PUT'};
    return apiClient.postMultipartData(
      '${AppConstants.employeeListUri}/$id',
      body,
      image == null ? [] : [MultipartBody('image', image)],
      handleError: false,
    );
  }

  @override
  Future<Response> deleteEmployee(int id) => apiClient
      .deleteData('${AppConstants.employeeListUri}/$id', handleError: false);
}
