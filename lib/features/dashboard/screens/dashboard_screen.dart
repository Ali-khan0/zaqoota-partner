import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:sixam_mart_store/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_store/features/dashboard/widgets/out_of_stock_warning_bottom_sheet.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/features/subscription/controllers/subscription_controller.dart';
import 'package:sixam_mart_store/features/disbursement/helper/disbursement_helper.dart';
import 'package:sixam_mart_store/features/rental_module/home/screens/taxi_home_screen.dart';
import 'package:sixam_mart_store/features/rental_module/menu/screens/taxi_menu_screen.dart';
import 'package:sixam_mart_store/features/rental_module/provider/screens/provider_screen.dart';
import 'package:sixam_mart_store/features/rental_module/trips/screens/trip_history_screen.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/features/payment/screens/wallet_screen.dart';
import 'package:sixam_mart_store/features/dashboard/widgets/bottom_nav_item_widget.dart';
import 'package:sixam_mart_store/features/home/screens/home_screen.dart';
import 'package:sixam_mart_store/features/menu/screens/menu_screen.dart';
import 'package:sixam_mart_store/features/order/screens/order_history_screen.dart';
import 'package:sixam_mart_store/features/store/screens/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  const DashboardScreen({super.key, required this.pageIndex});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  DisbursementHelper disbursementHelper = DisbursementHelper();
  bool _canExit = false;

  @override
  void initState() {
    super.initState();
    AuthController authController = Get.find<AuthController>();

    _pageIndex = widget.pageIndex;
    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      authController.getModuleType() == 'rental'
          ? const TaxiHomeScreen()
          : const HomeScreen(),
      authController.getModuleType() == 'rental'
          ? const TripHistoryScreen()
          : const OrderHistoryScreen(),
      authController.getModuleType() == 'rental'
          ? const ProviderScreen()
          : const StoreScreen(),
      const WalletScreen(),
      Container(),
    ];

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });

    showDisbursementWarningMessage();

    if (Get.find<SubscriptionController>().isTrialEndModalShown) {
      Get.find<SubscriptionController>().trialEndBottomSheet();
    }

    outOfStockBottomSheet();
  }

  Future<void> showDisbursementWarningMessage() async {
    disbursementHelper.enableDisbursementWarningMessage(true);
  }

  Future<void> outOfStockBottomSheet() async {
    Future.delayed(const Duration(seconds: 1), () {
      if (Get.find<ProfileController>().profileModel != null &&
          Get.find<ProfileController>().profileModel!.outOfStockCount! > 0 &&
          Get.find<ProfileController>().showLowStockWarning) {
        showModalBottomSheet(
          context: Get.context!,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (con) => const OutOfStockWarningBottomSheet(),
        ).then((v) {
          Get.find<ProfileController>().hideLowStockWarning();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (_pageIndex != 0) {
          _setPage(0);
        } else {
          if (_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('back_press_again_to_exit'.tr,
                style: const TextStyle(color: Colors.white)),
            behavior: SnackBarBehavior.floating,
            backgroundColor:
                Theme.of(context).primaryColor, // Matching your primary theme
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          ));
          _canExit = true;
          Timer(const Duration(seconds: 2), () {
            _canExit = false;
          });
        }
      },
      child: Scaffold(
        // 1. Bottom Navigation Bar (Salomon Style)
        bottomNavigationBar: (keyboardVisible || !GetPlatform.isMobile)
            ? const SizedBox()
            : Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: SalomonBottomBar(
                      currentIndex: _pageIndex,
                      onTap: (index) {
                        if (index == 4) {
                          // Menu Logic
                          Get.bottomSheet(
                            Get.find<AuthController>().getModuleType() ==
                                    'rental'
                                ? const TaxiMenuScreen()
                                : const MenuScreen(),
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                          );
                        } else {
                          _setPage(index);
                        }
                      },
                      items: [
                        /// Home
                        SalomonBottomBarItem(
                          icon: const Icon(Icons.home_outlined),
                          title: Text("home".tr),
                          selectedColor: Theme.of(context).primaryColor,
                          unselectedColor: Theme.of(context).disabledColor,
                        ),

                        /// Orders / Trips
                        SalomonBottomBarItem(
                          icon: const Icon(Icons.shopping_bag_outlined),
                          title: Text(
                              Get.find<AuthController>().getModuleType() ==
                                      'rental'
                                  ? 'trips'.tr
                                  : 'orders'.tr),
                          selectedColor: Theme.of(context).primaryColor,
                          unselectedColor: Theme.of(context).disabledColor,
                        ),

                        /// Center Action (Replacing the Floating Button)
                        SalomonBottomBarItem(
                          icon: Image.asset(
                            Get.find<AuthController>().getModuleType() ==
                                    'rental'
                                ? Images.taxiHome
                                : Images.restaurant,
                            height: 22,
                            width: 22,
                            color: _pageIndex == 2
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).disabledColor,
                          ),
                          title: Text("My Store"
                              .tr), // Or whatever your center action represents
                          selectedColor: Theme.of(context).primaryColor,
                          unselectedColor: Theme.of(context).disabledColor,
                        ),

                        /// Wallet
                        SalomonBottomBarItem(
                          icon:
                              const Icon(Icons.account_balance_wallet_outlined),
                          title: Text("wallet".tr),
                          selectedColor: Theme.of(context).primaryColor,
                          unselectedColor: Theme.of(context).disabledColor,
                        ),

                        /// Menu
                        SalomonBottomBarItem(
                          icon: const Icon(Icons.menu),
                          title: Text("menu".tr),
                          selectedColor: Theme.of(context).primaryColor,
                          unselectedColor: Theme.of(context).disabledColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

        body: PageView.builder(
          controller: _pageController,
          itemCount: _screens.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _screens[index];
          },
        ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    if (!Get.find<SubscriptionController>().isTrialEndModalShown) {
      Get.find<SubscriptionController>().trialEndBottomSheet().then((trialEnd) {
        if (trialEnd) {
          setState(() {
            _pageController!.jumpToPage(pageIndex);
            _pageIndex = pageIndex;
          });
        } else {
          Get.find<SubscriptionController>().setTrialEndModalShown(true);
        }
      });
    }
  }
}
