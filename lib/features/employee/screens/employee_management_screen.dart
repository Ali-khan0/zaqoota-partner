import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/confirmation_dialog_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_text_field_widget.dart';
import 'package:sixam_mart_store/common/widgets/details_custom_card.dart';
import 'package:sixam_mart_store/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_store/features/employee/controllers/employee_management_controller.dart';
import 'package:sixam_mart_store/features/employee/domain/models/vendor_employee_model.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() =>
      _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    if (Get.find<AuthController>().getUserType() == 'owner') {
      Get.find<EmployeeManagementController>().loadEmployees();
      Get.find<EmployeeManagementController>().loadRoles();
    }
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openEmployeeForm([VendorEmployeeModel? employee]) async {
    final result = await Get.toNamed(RouteHelper.getAddEmployeeRoute(),
        arguments: employee);
    if (result == true) {
      Get.find<EmployeeManagementController>()
          .loadEmployees(search: _searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwner = Get.find<AuthController>().getUserType() == 'owner';
    if (!isOwner) {
      return Scaffold(
        appBar: CustomAppBarWidget(title: 'employee_management'.tr),
        body: Center(
            child: Text('you_have_no_permission_to_access_this_feature'.tr,
                style: robotoMedium)),
      );
    }

    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'employees'.tr,
        menuWidget: TextButton.icon(
          onPressed: () => Get.toNamed(RouteHelper.getEmployeeRolesRoute()),
          icon: const Icon(Icons.admin_panel_settings_outlined),
          label: Text('roles'.tr),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEmployeeForm(),
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.person_add_alt_1, color: Theme.of(context).cardColor),
      ),
      body: GetBuilder<EmployeeManagementController>(builder: (controller) {
        return Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeSmall),
            child: CustomTextFieldWidget(
              controller: _searchController,
              hintText: 'search_employee'.tr,
              labelText: 'search_employee'.tr,
              prefixIcon: Icons.search,
              inputAction: TextInputAction.search,
              onChanged: (_) {
                _searchTimer?.cancel();
                _searchTimer = Timer(const Duration(milliseconds: 350), () {
                  controller.loadEmployees(search: _searchController.text);
                });
              },
            ),
          ),
          Expanded(
            child: controller.employees == null
                ? const Center(child: CircularProgressIndicator())
                : controller.employees!.isEmpty
                    ? Center(
                        child: Text(_searchController.text.isEmpty
                            ? 'no_employees_found'.tr
                            : 'no_matching_employees'.tr))
                    : RefreshIndicator(
                        onRefresh: () => controller.loadEmployees(
                            search: _searchController.text),
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification.metrics.pixels >=
                                notification.metrics.maxScrollExtent - 150) {
                              controller.loadMoreEmployees();
                            }
                            return false;
                          },
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                                Dimensions.paddingSizeDefault,
                                Dimensions.paddingSizeSmall,
                                Dimensions.paddingSizeDefault,
                                90),
                            itemCount: controller.employees!.length +
                                (controller.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == controller.employees!.length) {
                                return const Padding(
                                    padding: EdgeInsets.all(
                                        Dimensions.paddingSizeDefault),
                                    child: Center(
                                        child: CircularProgressIndicator()));
                              }
                              return _employeeCard(
                                  controller.employees![index], index);
                            },
                          ),
                        ),
                      ),
          ),
        ]);
      }),
    );
  }

  Widget _employeeCard(VendorEmployeeModel employee, int index) {
    final controller = Get.find<EmployeeManagementController>();
    return DetailsCustomCard(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Row(children: [
        ClipOval(
          child: CustomImageWidget(
              image: employee.image, width: 54, height: 54, fit: BoxFit.cover),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${employee.firstName} ${employee.lastName ?? ''}'.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: robotoMedium),
            const SizedBox(height: 3),
            Text(employee.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    robotoRegular.copyWith(color: Theme.of(context).hintColor)),
            Text(employee.roleName ?? 'role_not_assigned'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).primaryColor)),
          ]),
        ),
        IconButton(
          tooltip: 'edit'.tr,
          onPressed: () => _openEmployeeForm(employee),
          icon:
              Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor),
        ),
        IconButton(
          tooltip: 'delete'.tr,
          onPressed: controller.isLoading
              ? null
              : () {
                  Get.dialog(ConfirmationDialogWidget(
                    icon: Images.warning,
                    title: 'delete_employee'.tr,
                    description: 'are_you_sure_to_delete_this_employee'.tr,
                    onYesPressed: () => controller.deleteEmployee(employee.id),
                  ));
                },
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
        ),
      ]),
    );
  }
}
