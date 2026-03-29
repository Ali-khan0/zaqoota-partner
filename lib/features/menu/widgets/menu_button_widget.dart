import 'package:sixam_mart_store/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_store/features/language/controllers/language_controller.dart';
import 'package:sixam_mart_store/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/features/menu/domain/models/menu_model.dart';
import 'package:sixam_mart_store/features/subscription/controllers/subscription_controller.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:sixam_mart_store/common/widgets/confirmation_dialog_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuButtonWidget extends StatelessWidget {
  final MenuModel menu;
  final bool isProfile;
  final bool isLogout;
  const MenuButtonWidget(
      {super.key,
      required this.menu,
      required this.isProfile,
      required this.isLogout});

  @override
  Widget build(BuildContext context) {
    double size = (context.width / 4) - Dimensions.paddingSizeDefault;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        // Aligned with User App Border
        border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            width: 1),
        // Aligned with User App Shadow
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              spreadRadius: 0,
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: InkWell(
        onTap: () async {
          if (menu.isBlocked) {
            showCustomSnackBar('this_feature_is_blocked_by_admin'.tr);
          } else if (menu.isNotSubscribe) {
            showCustomSnackBar('you_have_no_available_subscription'.tr);
          } else if (menu.isLanguage) {
            Get.back();
            _manageLanguageFunctionality();
          } else {
            if (isLogout) {
              Get.back();
              if (Get.find<AuthController>().isLoggedIn()) {
                Get.dialog(
                    ConfirmationDialogWidget(
                        icon: Images.support,
                        description: 'are_you_sure_to_logout'.tr,
                        isLogOut: true,
                        onYesPressed: () async {
                          Get.find<AuthController>().clearSharedData();
                          await Get.find<ProfileController>()
                              .trialWidgetShow(route: RouteHelper.payment);
                          Get.offAllNamed(RouteHelper.getSignInRoute());
                        }),
                    useSafeArea: false);
              } else {
                await Get.find<ProfileController>()
                    .trialWidgetShow(route: RouteHelper.payment);
                Get.find<AuthController>().clearSharedData();
                Get.toNamed(RouteHelper.getSignInRoute());
              }
            } else {
              if (menu.route == RouteHelper.mySubscription) {
                Get.offNamed(menu.route);
              } else {
                if (!Get.find<SubscriptionController>().isTrialEndModalShown) {
                  Get.find<SubscriptionController>()
                      .trialEndBottomSheet()
                      .then((trialEnd) {
                    if (trialEnd) {
                      Get.offNamed(menu.route);
                    } else {
                      Get.find<SubscriptionController>()
                          .setTrialEndModalShown(true);
                    }
                  });
                }
              }
            }
          }
        },
        radius: Dimensions.radiusDefault,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Floating Icon Effect (Circle background inside the block)
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: isLogout
                  ? Colors.red.withValues(alpha: 0.05)
                  : Theme.of(context).primaryColor.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: isProfile
                ? ProfileImageWidget(size: size * 0.45)
                : Image.asset(
                    menu.icon,
                    width: size * 0.45,
                    height: size * 0.45,
                    color: isLogout ? Colors.redAccent : menu.iconColor,
                  ),
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Title Text now inside the block (User App Style)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              menu.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: isLogout
                    ? Colors.redAccent
                    : Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withValues(alpha: 0.8),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _manageLanguageFunctionality() {
    Get.find<LocalizationController>().saveCacheLanguage(null);
    Get.find<LocalizationController>().searchSelectedLanguage();

    showModalBottomSheet(
      isScrollControlled: true,
      useRootNavigator: true,
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusExtraLarge),
            topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const LanguageBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<LocalizationController>().setLanguage(
        Get.find<LocalizationController>().getCacheLocaleFromSharedPref()));
  }
}

class ProfileImageWidget extends StatelessWidget {
  final double size;
  const ProfileImageWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    bool isOwner = Get.find<AuthController>().getUserType() == 'owner';

    return GetBuilder<ProfileController>(builder: (profileController) {
      return Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 2, color: Colors.white)),
        child: ClipOval(
          child: CustomImageWidget(
            image: isOwner
                ? profileController.profileModel?.imageFullUrl ?? ''
                : profileController.profileModel?.employeeInfo?.imageFullUrl ??
                    '',
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      );
    });
  }
}
