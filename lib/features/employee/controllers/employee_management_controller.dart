import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/features/employee/domain/models/employee_role_option_model.dart';
import 'package:sixam_mart_store/features/employee/domain/models/employee_permission_option_model.dart';
import 'package:sixam_mart_store/features/employee/domain/models/vendor_employee_model.dart';
import 'package:sixam_mart_store/features/employee/domain/services/employee_management_service_interface.dart';

class EmployeeManagementController extends GetxController
    implements GetxService {
  final EmployeeManagementServiceInterface service;
  EmployeeManagementController({required this.service});

  List<VendorEmployeeModel>? _employees;
  List<VendorEmployeeModel>? get employees => _employees;

  List<EmployeeRoleOptionModel> _roles = [];
  List<EmployeeRoleOptionModel> get roles => _roles;

  List<EmployeePermissionOptionModel> _permissions = [];
  List<EmployeePermissionOptionModel> get permissions => _permissions;

  XFile? _pickedImage;
  XFile? get pickedImage => _pickedImage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingRoles = false;
  bool get isLoadingRoles => _isLoadingRoles;
  bool _rolesLoadFailed = false;
  bool get rolesLoadFailed => _rolesLoadFailed;

  bool _isLoadingPermissions = false;
  bool get isLoadingPermissions => _isLoadingPermissions;

  bool _isSavingRole = false;
  bool get isSavingRole => _isSavingRole;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;
  int _currentPage = 1;
  int _lastPage = 1;
  String? _activeSearch;
  bool get hasMoreEmployees => _currentPage < _lastPage;

  Future<void> loadEmployees({String? search}) async {
    _activeSearch = search;
    _currentPage = 1;
    _employees = null;
    update();
    final response = await service.getEmployees(search: search, page: 1);
    if (response.statusCode == 200 && response.body is Map) {
      final data = response.body['data'];
      if (data is List) {
        _employees = data
            .whereType<Map>()
            .map((item) =>
                VendorEmployeeModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        _lastPage = (response.body['meta']?['last_page'] as num?)?.toInt() ?? 1;
      }
    } else {
      _employees = [];
      showCustomSnackBar(_message(response));
    }
    update();
  }

  Future<void> loadMoreEmployees() async {
    if (_isLoadingMore || !hasMoreEmployees) return;
    _isLoadingMore = true;
    update();
    final response = await service.getEmployees(
        search: _activeSearch, page: _currentPage + 1);
    if (response.statusCode == 200 &&
        response.body is Map &&
        response.body['data'] is List) {
      _employees ??= [];
      _employees!.addAll((response.body['data'] as List).whereType<Map>().map(
          (item) =>
              VendorEmployeeModel.fromJson(Map<String, dynamic>.from(item))));
      _currentPage++;
      _lastPage =
          (response.body['meta']?['last_page'] as num?)?.toInt() ?? _lastPage;
    } else {
      showCustomSnackBar(_message(response));
    }
    _isLoadingMore = false;
    update();
  }

  Future<void> loadRoles() async {
    _isLoadingRoles = true;
    update();
    final response = await service.getRoles();
    if (response.statusCode == 200 &&
        response.body is Map &&
        response.body['data'] is List) {
      _rolesLoadFailed = false;
      _roles = (response.body['data'] as List)
          .whereType<Map>()
          .map((item) =>
              EmployeeRoleOptionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else {
      _rolesLoadFailed = true;
      _roles = [];
      showCustomSnackBar(_message(response));
    }
    _isLoadingRoles = false;
    update();
  }

  Future<void> loadPermissions() async {
    _isLoadingPermissions = true;
    update();
    final response = await service.getPermissions();
    if (response.statusCode == 200 &&
        response.body is Map &&
        response.body['data'] is List) {
      _permissions = (response.body['data'] as List)
          .whereType<Map>()
          .map((item) => EmployeePermissionOptionModel.fromJson(
              Map<String, dynamic>.from(item)))
          .where((permission) => permission.key.isNotEmpty)
          .toList();
    } else {
      _permissions = [];
      showCustomSnackBar(_message(response));
    }
    _isLoadingPermissions = false;
    update();
  }

  Future<bool> saveRole({
    required EmployeeRoleOptionModel? role,
    required String name,
    required List<String> modules,
  }) async {
    _isSavingRole = true;
    update();
    final response = role == null
        ? await service.createRole(name: name, modules: modules)
        : await service.updateRole(role.id, name: name, modules: modules);
    final success =
        role == null ? response.statusCode == 201 : response.statusCode == 200;
    _isSavingRole = false;
    if (success) {
      await loadRoles();
      Get.back(result: true);
      showCustomSnackBar(
          role == null
              ? 'role_added_successfully'.tr
              : 'role_updated_successfully'.tr,
          isError: false);
    } else {
      showCustomSnackBar(_message(response));
    }
    update();
    return success;
  }

  Future<bool> deleteRole(int id) async {
    _isSavingRole = true;
    update();
    final response = await service.deleteRole(id);
    final success = response.statusCode == 200;
    if (success) {
      showCustomSnackBar('role_deleted_successfully'.tr, isError: false);
      await loadRoles();
    } else {
      showCustomSnackBar(_message(response));
    }
    _isSavingRole = false;
    update();
    return success;
  }

  void pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      if (bytes.length > 2 * 1024 * 1024) {
        showCustomSnackBar('max_size_2_mb'.tr);
        return;
      }
      _pickedImage = picked;
    }
    update();
  }

  void clearPickedImage() {
    _pickedImage = null;
  }

  Future<bool> saveEmployee(
      {required Map<String, String> fields,
      required VendorEmployeeModel? employee}) async {
    _isLoading = true;
    update();

    final response = employee == null
        ? _pickedImage == null
            ? null
            : await service.createEmployee(fields, _pickedImage!)
        : await service.updateEmployee(employee.id, fields, _pickedImage);

    _isLoading = false;
    if (response == null) {
      showCustomSnackBar('please_upload_employee_image'.tr);
      update();
      return false;
    }

    final success = employee == null
        ? response.statusCode == 201
        : response.statusCode == 200;
    if (success) {
      Get.back(result: true);
      showCustomSnackBar(
          employee == null
              ? 'employee_added_successfully'.tr
              : 'employee_updated_successfully'.tr,
          isError: false);
    } else {
      showCustomSnackBar(_message(response));
    }

    _isLoading = false;
    update();
    return success;
  }

  Future<bool> deleteEmployee(int id) async {
    _isLoading = true;
    update();
    final response = await service.deleteEmployee(id);
    final success = response.statusCode == 200;
    if (success) {
      showCustomSnackBar('employee_deleted_successfully'.tr, isError: false);
      await loadEmployees();
    } else {
      showCustomSnackBar(_message(response));
    }
    _isLoading = false;
    update();
    return success;
  }

  String _message(Response response) {
    final body = response.body;
    if (body is Map &&
        body['errors'] is List &&
        (body['errors'] as List).isNotEmpty) {
      final messages = (body['errors'] as List)
          .whereType<Map>()
          .map((error) => error['message']?.toString() ?? '')
          .where((message) => message.isNotEmpty)
          .toSet();
      if (messages.isNotEmpty) return messages.join('\n');
    }
    if (body is Map && body['message'] != null) {
      return body['message'].toString();
    }
    return response.statusText ?? 'unexpected_error_occurred'.tr;
  }
}
