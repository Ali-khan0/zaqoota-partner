import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/confirmation_dialog_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/details_custom_card.dart';
import 'package:sixam_mart_store/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_store/features/employee/controllers/employee_management_controller.dart';
import 'package:sixam_mart_store/features/employee/domain/models/employee_role_option_model.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';

class RoleManagementScreen extends StatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  @override
  void initState() {
    super.initState();
    if (Get.find<AuthController>().getUserType() == 'owner') {
      Get.find<EmployeeManagementController>().loadRoles();
    }
  }

  Future<void> _openRoleForm([EmployeeRoleOptionModel? role]) async {
    final result = await Get.toNamed(RouteHelper.getAddEmployeeRoleRoute(),
        arguments: role);
    if (result == true) Get.find<EmployeeManagementController>().loadRoles();
  }

  @override
  Widget build(BuildContext context) {
    if (Get.find<AuthController>().getUserType() != 'owner') {
      return Scaffold(
        appBar: CustomAppBarWidget(title: 'role_management'.tr),
        body: Center(
            child: Text('you_have_no_permission_to_access_this_feature'.tr,
                style: robotoMedium)),
      );
    }
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'roles'.tr),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openRoleForm(),
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add, color: Theme.of(context).cardColor),
      ),
      body: GetBuilder<EmployeeManagementController>(builder: (controller) {
        if (controller.isLoadingRoles) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.roles.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      controller.rolesLoadFailed
                          ? 'roles_load_failed'.tr
                          : 'no_roles_yet'.tr,
                      textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor)),
                  if (controller.rolesLoadFailed)
                    TextButton.icon(
                      onPressed: controller.loadRoles,
                      icon: const Icon(Icons.refresh),
                      label: Text('retry'.tr),
                    ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.loadRoles,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            itemCount: controller.roles.length,
            itemBuilder: (context, index) => _roleCard(controller.roles[index]),
          ),
        );
      }),
    );
  }

  Widget _roleCard(EmployeeRoleOptionModel role) {
    final controller = Get.find<EmployeeManagementController>();
    return DetailsCustomCard(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Row(children: [
        Icon(Icons.admin_panel_settings_outlined,
            color: Theme.of(context).primaryColor, size: 28),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(role.name, style: robotoMedium),
            const SizedBox(height: 4),
            Text(
              '${role.modules.length} ${'permissions'.tr} · ${role.employeesCount} ${'employees'.tr}',
              style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor),
            ),
          ]),
        ),
        IconButton(
          tooltip: 'edit'.tr,
          onPressed: () => _openRoleForm(role),
          icon:
              Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor),
        ),
        IconButton(
          tooltip: 'delete'.tr,
          onPressed: controller.isSavingRole
              ? null
              : () => Get.dialog(ConfirmationDialogWidget(
                    icon: Images.warning,
                    title: 'delete_role'.tr,
                    description: role.employeesCount > 0
                        ? 'role_delete_assigned_hint'.tr
                        : 'are_you_sure_to_delete_this_role'.tr,
                    onYesPressed: () => controller.deleteRole(role.id),
                  )),
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
        ),
      ]),
    );
  }
}
