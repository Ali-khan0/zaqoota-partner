import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_text_field_widget.dart';
import 'package:sixam_mart_store/common/widgets/details_custom_card.dart';
import 'package:sixam_mart_store/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_store/features/employee/controllers/employee_management_controller.dart';
import 'package:sixam_mart_store/features/employee/domain/models/employee_role_option_model.dart';
import 'package:sixam_mart_store/features/employee/domain/models/vendor_employee_model.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';

class AddEmployeeScreen extends StatefulWidget {
  final VendorEmployeeModel? employee;
  const AddEmployeeScreen({super.key, this.employee});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  int? _selectedRoleId;

  bool get _isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<EmployeeManagementController>();
    controller.clearPickedImage();
    controller.loadRoles();
    final employee = widget.employee;
    if (employee != null) {
      _firstNameController.text = employee.firstName;
      _lastNameController.text = employee.lastName ?? '';
      _phoneController.text = employee.phone;
      _emailController.text = employee.email;
      _selectedRoleId = employee.roleId;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = Get.find<EmployeeManagementController>();
    if (_selectedRoleId == null) return;

    final fields = <String, String>{
      'f_name': _firstNameController.text.trim(),
      'l_name': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'role_id': _selectedRoleId.toString(),
    };
    if (!_isEditing || _passwordController.text.isNotEmpty) {
      fields['password'] = _passwordController.text;
      fields['password_confirmation'] = _confirmPasswordController.text;
    }

    await controller.saveEmployee(fields: fields, employee: widget.employee);
  }

  @override
  Widget build(BuildContext context) {
    if (Get.find<AuthController>().getUserType() != 'owner') {
      return Scaffold(
          appBar: CustomAppBarWidget(title: 'employee_management'.tr),
          body: Center(
              child: Text('you_have_no_permission_to_access_this_feature'.tr)));
    }

    return Scaffold(
      appBar: CustomAppBarWidget(
          title: _isEditing ? 'edit_employee'.tr : 'add_employee'.tr),
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
                      _imagePicker(controller),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      CustomTextFieldWidget(
                        controller: _firstNameController,
                        hintText: 'first_name'.tr,
                        labelText: 'first_name'.tr,
                        showTitle: true,
                        required: true,
                        capitalization: TextCapitalization.words,
                        inputType: TextInputType.name,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'enter_your_first_name'.tr
                                : null,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      CustomTextFieldWidget(
                        controller: _lastNameController,
                        hintText: 'last_name'.tr,
                        labelText: 'last_name'.tr,
                        showTitle: true,
                        capitalization: TextCapitalization.words,
                        inputType: TextInputType.name,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      CustomTextFieldWidget(
                        controller: _phoneController,
                        hintText: 'phone'.tr,
                        labelText: 'phone'.tr,
                        showTitle: true,
                        required: true,
                        inputType: TextInputType.phone,
                        validator: (value) =>
                            value == null || value.trim().length < 7
                                ? 'enter_a_valid_phone_number'.tr
                                : null,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      CustomTextFieldWidget(
                        controller: _emailController,
                        hintText: 'email'.tr,
                        labelText: 'email'.tr,
                        showTitle: true,
                        required: true,
                        inputType: TextInputType.emailAddress,
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) return 'enter_email_address'.tr;
                          if (!GetUtils.isEmail(email)) {
                            return 'enter_a_valid_email_address'.tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text('employee_role'.tr, style: robotoMedium),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      if (controller.isLoadingRoles)
                        const Center(
                            child: Padding(
                                padding: EdgeInsets.all(
                                    Dimensions.paddingSizeDefault),
                                child: CircularProgressIndicator()))
                      else if (controller.roles.isEmpty)
                        DetailsCustomCard(
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeDefault),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('no_roles_yet'.tr,
                                  style: robotoRegular.copyWith(
                                      color: Theme.of(context).hintColor)),
                              TextButton.icon(
                                onPressed: () async {
                                  final result = await Get.toNamed(
                                      RouteHelper.getAddEmployeeRoleRoute());
                                  if (result == true) controller.loadRoles();
                                },
                                icon: const Icon(Icons.add),
                                label: Text('create_role'.tr),
                              ),
                            ],
                          ),
                        )
                      else
                        DropdownButtonFormField<int>(
                          initialValue: controller.roles
                                  .any((role) => role.id == _selectedRoleId)
                              ? _selectedRoleId
                              : null,
                          isExpanded: true,
                          decoration: InputDecoration(
                            hintText: 'select_role'.tr,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                                vertical: Dimensions.paddingSizeDefault),
                          ),
                          items: controller.roles
                              .map((EmployeeRoleOptionModel role) =>
                                  DropdownMenuItem<int>(
                                      value: role.id,
                                      child: Text(role.name,
                                          overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedRoleId = value),
                          validator: (value) =>
                              value == null ? 'select_role'.tr : null,
                        ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      CustomTextFieldWidget(
                        controller: _passwordController,
                        hintText: _isEditing
                            ? 'new_password_optional'.tr
                            : 'password'.tr,
                        labelText: _isEditing
                            ? 'new_password_optional'.tr
                            : 'password'.tr,
                        showTitle: true,
                        required: !_isEditing,
                        isPassword: true,
                        inputType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (!_isEditing && (value == null || value.isEmpty)) {
                            return 'enter_password'.tr;
                          }
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length < 8) {
                            return 'password_should_be'.tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      CustomTextFieldWidget(
                        controller: _confirmPasswordController,
                        hintText: 'confirm_password'.tr,
                        labelText: 'confirm_password'.tr,
                        showTitle: true,
                        required:
                            !_isEditing || _passwordController.text.isNotEmpty,
                        isPassword: true,
                        inputType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (!_isEditing ||
                              _passwordController.text.isNotEmpty) {
                            if (value == null || value.isEmpty) {
                              return 'confirm_password'.tr;
                            }
                            if (value != _passwordController.text) {
                              return 'password_does_not_matched'.tr;
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                    ]),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: CustomButtonWidget(
                  buttonText: _isEditing ? 'update'.tr : 'add_employee'.tr,
                  isLoading: controller.isLoading,
                  onPressed: controller.roles.isEmpty || controller.isLoading
                      ? null
                      : _submit,
                ),
              ),
            ),
          ]),
        );
      }),
    );
  }

  Widget _imagePicker(EmployeeManagementController controller) {
    return Center(
      child: Column(children: [
        Text('employee_photo'.tr, style: robotoMedium),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        InkWell(
          onTap: controller.isLoading ? null : controller.pickImage,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          child: Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.35),
                  width: 2),
            ),
            child: ClipOval(
              child: controller.pickedImage != null
                  ? GetPlatform.isWeb
                      ? Image.network(controller.pickedImage!.path,
                          fit: BoxFit.cover)
                      : Image.file(File(controller.pickedImage!.path),
                          fit: BoxFit.cover)
                  : _isEditing
                      ? CustomImageWidget(
                          image: widget.employee!.image,
                          width: 112,
                          height: 112,
                          fit: BoxFit.cover)
                      : Icon(Icons.add_a_photo_outlined,
                          size: 32, color: Theme.of(context).primaryColor),
            ),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(_isEditing ? 'tap_to_change_photo'.tr : 'upload_employee_photo'.tr,
            style: robotoRegular.copyWith(
                color: Theme.of(context).hintColor,
                fontSize: Dimensions.fontSizeSmall)),
      ]),
    );
  }
}
