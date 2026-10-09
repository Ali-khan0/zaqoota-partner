import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_text_field_widget.dart';
import 'package:sixam_mart_store/common/widgets/details_custom_card.dart';
import 'package:sixam_mart_store/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_store/features/employee/controllers/employee_management_controller.dart';
import 'package:sixam_mart_store/features/employee/domain/models/employee_role_option_model.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';

class AddEmployeeRoleScreen extends StatefulWidget {
  final EmployeeRoleOptionModel? role;
  const AddEmployeeRoleScreen({super.key, this.role});

  @override
  State<AddEmployeeRoleScreen> createState() => _AddEmployeeRoleScreenState();
}

class _AddEmployeeRoleScreenState extends State<AddEmployeeRoleScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final Set<String> _selectedPermissions = {};

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.role?.name ?? '';
    _selectedPermissions.addAll(widget.role?.modules ?? const []);
    Get.find<EmployeeManagementController>().loadPermissions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit(EmployeeManagementController controller) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPermissions.isEmpty) return;
    await controller.saveRole(
      role: widget.role,
      name: _nameController.text.trim(),
      modules: _selectedPermissions.toList(),
    );
  }

  List<String> _unavailableModules(EmployeeManagementController controller) {
    final available = controller.permissions.map((item) => item.key).toSet();
    return _selectedPermissions
        .where((key) => !available.contains(key))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (Get.find<AuthController>().getUserType() != 'owner') {
      return Scaffold(
        appBar: CustomAppBarWidget(title: 'role_management'.tr),
        body: Center(
            child: Text('you_have_no_permission_to_access_this_feature'.tr)),
      );
    }
    return Scaffold(
      appBar: CustomAppBarWidget(
          title: widget.role == null ? 'add_role'.tr : 'edit_role'.tr),
      body: GetBuilder<EmployeeManagementController>(builder: (controller) {
        return Form(
          key: _formKey,
          child: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextFieldWidget(
                        controller: _nameController,
                        hintText: 'role_name'.tr,
                        labelText: 'role_name'.tr,
                        showTitle: true,
                        required: true,
                        capitalization: TextCapitalization.words,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'enter_role_name'.tr
                                : null,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text('permissions'.tr, style: robotoMedium),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Text('choose_role_permissions'.tr,
                          style: robotoRegular.copyWith(
                              color: Theme.of(context).hintColor)),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      if (controller.isLoadingPermissions)
                        const Center(
                            child: Padding(
                                padding: EdgeInsets.all(
                                    Dimensions.paddingSizeDefault),
                                child: CircularProgressIndicator()))
                      else if (controller.permissions.isEmpty)
                        DetailsCustomCard(
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeDefault),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('permissions_unavailable'.tr),
                              TextButton.icon(
                                onPressed: controller.loadPermissions,
                                icon: const Icon(Icons.refresh),
                                label: Text('retry'.tr),
                              ),
                            ],
                          ),
                        )
                      else
                        DetailsCustomCard(
                          padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeExtraSmall),
                          child: Column(
                            children: [
                              ...controller.permissions.map((permission) {
                                return CheckboxListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeSmall),
                                  title: Text(permission.label,
                                      style: robotoRegular),
                                  value: _selectedPermissions
                                      .contains(permission.key),
                                  activeColor: Theme.of(context).primaryColor,
                                  onChanged: (selected) => setState(() {
                                    if (selected == true) {
                                      _selectedPermissions.add(permission.key);
                                    } else {
                                      _selectedPermissions
                                          .remove(permission.key);
                                    }
                                  }),
                                );
                              }),
                              ..._unavailableModules(controller).map((key) =>
                                  CheckboxListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.paddingSizeSmall),
                                    title: Text(
                                        '${_permissionLabel(key)} (${'unavailable'.tr})',
                                        style: robotoRegular.copyWith(
                                            color:
                                                Theme.of(context).hintColor)),
                                    value: true,
                                    activeColor:
                                        Theme.of(context).disabledColor,
                                    onChanged: (_) => setState(
                                        () => _selectedPermissions.remove(key)),
                                  )),
                            ],
                          ),
                        ),
                      if (_unavailableModules(controller).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: Dimensions.paddingSizeExtraSmall),
                          child: Text('remove_unavailable_permissions'.tr,
                              style: robotoRegular.copyWith(
                                  color: Theme.of(context).colorScheme.error)),
                        ),
                      if (_selectedPermissions.isEmpty &&
                          !controller.isLoadingPermissions &&
                          controller.permissions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: Dimensions.paddingSizeExtraSmall),
                          child: Text('select_at_least_one_permission'.tr,
                              style: robotoRegular.copyWith(
                                  color: Theme.of(context).colorScheme.error)),
                        ),
                    ]),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: CustomButtonWidget(
                  buttonText:
                      widget.role == null ? 'save_role'.tr : 'update_role'.tr,
                  isLoading: controller.isSavingRole,
                  onPressed: controller.isSavingRole ||
                          controller.isLoadingPermissions ||
                          controller.permissions.isEmpty ||
                          _unavailableModules(controller).isNotEmpty
                      ? null
                      : () => _submit(controller),
                ),
              ),
            ),
          ]),
        );
      }),
    );
  }

  String _permissionLabel(String key) => key
      .split('_')
      .map((part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
