import 'package:animate_do/animate_do.dart';
import 'package:sixam_mart_store/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_store/features/auth/widgets/store_registartion_success_bottom_sheet.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_store/features/rental_module/profile/controllers/taxi_profile_controller.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/helper/validate_check.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  GlobalKey<FormState>? _formKeyLogin;

  @override
  void initState() {
    super.initState();
    _formKeyLogin = GlobalKey<FormState>();
    _emailController.text = Get.find<AuthController>().getUserNumber();
    _passwordController.text = Get.find<AuthController>().getUserPassword();
    if (Get.find<AuthController>().getUserType() == 'employee') {
      Get.find<AuthController>().changeVendorType(1, isUpdate: false);
    } else {
      Get.find<AuthController>().changeVendorType(0, isUpdate: false);
    }

    _showRegistrationSuccessBottomSheet();
  }

  void _showRegistrationSuccessBottomSheet() {
    bool canShowBottomSheet =
        Get.find<AuthController>().getIsStoreRegistrationSharedPref();
    if (canShowBottomSheet) {
      Future.delayed(const Duration(seconds: 1), () {
        showModalBottomSheet(
          context: Get.context!,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (con) => const StoreRegistrationSuccessBottomSheet(),
        ).then((value) {
          Get.find<AuthController>().saveIsStoreRegistrationSharedPref(false);
          setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A soft gradient background for depth
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // image: DecorationImage(
          //   // image: AssetImage("assets/image/background.png"),
          //   fit: BoxFit.cover,
          //   colorFilter: ColorFilter.mode(
          //       Colors.black.withValues(alpha: 0.05), BlendMode.dstATop)
          // ),
          gradient: RadialGradient(
            center: const Alignment(-0.5, -0.7),
            radius: 1.5,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.03),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
              child: GetBuilder<AuthController>(builder: (authController) {
                return Column(
                  children: [
                    // --- Brand Header ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      // decoration: BoxDecoration(
                      //   // shape: BoxShape.circle,
                      //   color: Theme.of(context).cardColor,
                      //   boxShadow: [
                      //     BoxShadow(
                      //       color: Colors.black.withValues(alpha: 0.03),
                      //       blurRadius: 20,
                      //       offset: const Offset(0, 10),
                      //     )
                      //   ],
                      // ),
                      child: Image.asset(Images.logo,
                          width: 150), // Scaled for aesthetic balance
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                    Text(
                      'sign_in'.tr.toUpperCase(),
                      style: robotoBold.copyWith(
                        fontSize: 20,
                        letterSpacing: 2,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- Main Glass Card ---
                    Container(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeLarge),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault * 2),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          // 2. Animated Sliding Tab Selector
                          Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .disabledColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault),
                            ),
                            child: Stack(
                              children: [
                                // The Sliding Background Pill
                                AnimatedAlign(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  alignment: authController.vendorTypeIndex == 0
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.42, // Adjust based on padding
                                    margin: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusDefault - 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // The Tab Labels
                                Row(children: [
                                  _buildTabLabel(context, authController, 0,
                                      'vendor_owner'.tr),
                                  _buildTabLabel(context, authController, 1,
                                      'vendor_employee'.tr),
                                ]),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Input Fields
                          Form(
                            key: _formKeyLogin,
                            child: Column(children: [
                              CustomTextFieldWidget(
                                labelText: 'email'.tr,
                                hintText: 'enter_email'.tr,
                                controller: _emailController,
                                inputType: TextInputType.emailAddress,
                                prefixImage: Images.mail,
                                required: true,
                                validator: (value) =>
                                    ValidateCheck.validateEmail(value),
                              ),
                              const SizedBox(height: 20),
                              CustomTextFieldWidget(
                                labelText: 'password'.tr,
                                hintText: '8+characters'.tr,
                                controller: _passwordController,
                                isPassword: true,
                                prefixIcon: Icons.lock_outline_rounded,
                                required: true,
                                validator: (value) =>
                                    ValidateCheck.validatePassword(value, null),
                              ),
                            ]),
                          ),

                          const SizedBox(height: 10),

                          // Remember & Forgot Password
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () =>
                                      authController.toggleRememberMe(),
                                  child: Row(children: [
                                    Checkbox(
                                      activeColor:
                                          Theme.of(context).primaryColor,
                                      value: authController.isActiveRememberMe,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      onChanged: (v) =>
                                          authController.toggleRememberMe(),
                                    ),
                                    Text('remember_me'.tr,
                                        style: robotoRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeSmall)),
                                  ]),
                                ),
                                if (authController.vendorTypeIndex != 1)
                                  TextButton(
                                    onPressed: () => Get.toNamed(
                                        RouteHelper.getForgotPassRoute()),
                                    child: Text('${'forgot_password'.tr}?',
                                        style: robotoMedium.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeSmall)),
                                  ),
                              ]),

                          const SizedBox(height: 30),

                          // Primary Action
                          CustomButtonWidget(
                            isLoading: authController.isLoading,
                            buttonText: 'sign_in'.tr,
                            radius: Dimensions.radiusDefault,
                            onPressed: () => _login(authController),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Footer Registration
                    if (Get.find<SplashController>()
                            .configModel
                            ?.toggleStoreRegistration ??
                        false)
                      FadeInUp(
                        // If you have simple_animations or similar, otherwise just use regular text
                        child: TextButton(
                          onPressed: () => Get.toNamed(
                              RouteHelper.getRestaurantRegistrationRoute()),
                          child: RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: '${'join_as'.tr} ',
                                style: robotoRegular.copyWith(
                                    color: Theme.of(context).disabledColor)),
                            TextSpan(
                              text: 'vendor'.tr,
                              style: robotoBold.copyWith(
                                color: Theme.of(context).primaryColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ])),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

// Helper for the Animated Labels
  Widget _buildTabLabel(BuildContext context, AuthController authController,
      int index, String title) {
    bool isSelected = authController.vendorTypeIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => authController.changeVendorType(index),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Center(
          child: Text(
            title,
            style: robotoMedium.copyWith(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
        ),
      ),
    );
  }

  void _login(AuthController authController) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String type = authController.vendorTypeIndex == 0 ? 'owner' : 'employee';

    if (_formKeyLogin!.currentState!.validate()) {
      if (email.isEmpty) {
        showCustomSnackBar('enter_email_address'.tr);
      } else if (!GetUtils.isEmail(email)) {
        showCustomSnackBar('enter_a_valid_email_address'.tr);
      } else if (password.isEmpty) {
        showCustomSnackBar('enter_password'.tr);
      } else if (password.length < 6) {
        showCustomSnackBar('password_should_be'.tr);
      } else {
        authController.login(email, password, type).then((status) async {
          if (status != null) {
            if (status.isSuccess) {
              if (authController.isActiveRememberMe) {
                authController.saveUserNumberAndPassword(email, password, type);
              } else {
                authController.clearUserNumberAndPassword();
              }
              authController.getModuleType() == 'rental'
                  ? await Get.find<TaxiProfileController>().getProfile()
                  : await Get.find<ProfileController>().getProfile();
              Get.find<ProfileController>().initTrialWidgetNotShow();
              Get.offAllNamed(RouteHelper.getInitialRoute());
            } else {
              showCustomSnackBar(status.message);
            }
          }
        });
      }
    }
  }
}
