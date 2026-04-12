import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sixam_mart_store/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_store/features/home/widgets/ads_section_widget.dart';
import 'package:sixam_mart_store/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart_store/features/order/controllers/order_controller.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_store/features/order/domain/models/order_model.dart';
import 'package:sixam_mart_store/helper/price_converter_helper.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/app_constants.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:sixam_mart_store/common/widgets/confirmation_dialog_widget.dart';
import 'package:sixam_mart_store/common/widgets/order_shimmer_widget.dart';
import 'package:sixam_mart_store/common/widgets/order_widget.dart';
import 'package:sixam_mart_store/features/home/widgets/order_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AppLifecycleListener _listener;
  bool _isNotificationPermissionGranted = true;
  bool _isBatteryOptimizationGranted = true;

  @override
  void initState() {
    super.initState();

    _checkSystemNotification();

    // Initialize the AppLifecycleListener class and pass callbacks
    _listener = AppLifecycleListener(
      onStateChange: _onStateChanged,
    );

    _loadData();

    Future.delayed(const Duration(milliseconds: 200), () {
      checkPermission();
    });
  }

  Future<void> _loadData() async {
    await Get.find<ProfileController>().getProfile();
    await Get.find<OrderController>().getCurrentOrders();
    await Get.find<NotificationController>().getNotificationList();
  }

  Future<void> _checkSystemNotification() async {
    if (await Permission.notification.status.isDenied ||
        await Permission.notification.status.isPermanentlyDenied) {
      await Get.find<AuthController>().setNotificationActive(false);
    }
  }

  // Listen to the app lifecycle state changes
  void _onStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        Future.delayed(const Duration(milliseconds: 200), () {
          checkPermission();
        });
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  Future<void> checkPermission() async {
    var notificationStatus = await Permission.notification.status;
    var batteryStatus = await Permission.ignoreBatteryOptimizations.status;

    if (notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
      setState(() {
        _isNotificationPermissionGranted = false;
        _isBatteryOptimizationGranted = true;
      });

      await Get.find<AuthController>()
          .setNotificationActive(!notificationStatus.isDenied);
    } else if (batteryStatus.isDenied) {
      setState(() {
        _isBatteryOptimizationGranted = false;
        _isNotificationPermissionGranted = true;
      });
    } else {
      setState(() {
        _isNotificationPermissionGranted = true;
        _isBatteryOptimizationGranted = true;
      });
      Get.find<ProfileController>().setBackgroundNotificationActive(true);
    }

    if (batteryStatus.isDenied) {
      Get.find<ProfileController>().setBackgroundNotificationActive(false);
    }
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.request().isGranted) {
      return;
    } else {
      await openAppSettings();
    }

    checkPermission();
  }

  void requestBatteryOptimization() async {
    var status = await Permission.ignoreBatteryOptimizations.status;

    if (status.isGranted) {
      return;
    } else if (status.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    } else {
      openAppSettings();
    }

    checkPermission();
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: Theme.of(context).cardColor,
        elevation: 0, // Remove heavy shadow

        // Custom bottom border for a cleaner "Modern" look
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
            height: 1.0,
          ),
        ),

        // 1. Better Logo Spacing
        leadingWidth: 60, // Give the logo breathing room
        leading: Container(
          margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Image.asset(Images.logo, fit: BoxFit.contain),
        ),

        titleSpacing: 0,

        // 2. Premium Typography
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.appName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoBold.copyWith(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                fontSize: Dimensions.fontSizeLarge,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'vendor_panel'.tr, // Optional: add a tiny subtitle for context
              style: robotoRegular.copyWith(
                fontSize: 10,
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),

        actions: [
          // 3. Modern Notification Icon
          Padding(
            padding:
                const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
            child: GetBuilder<NotificationController>(
                builder: (notificationController) {
              return InkWell(
                onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
                borderRadius: BorderRadius.circular(50),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context)
                            .disabledColor
                            .withValues(alpha: 0.05),
                      ),
                      child: Icon(
                        Icons
                            .notifications_none_rounded, // Outlined looks cleaner
                        size: 24,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    if (notificationController.hasNotification)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                                width: 1.5, color: Theme.of(context).cardColor),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadData();
        },
        child: GetBuilder<ProfileController>(builder: (profileController) {
          return GetBuilder<OrderController>(builder: (orderController) {
            bool isEnableTemporarilyClosed = false;

            if (orderController.runningOrders != null) {
              for (int i = 0; i < orderController.runningOrders!.length; i++) {
                if (orderController.runningOrders?[i].status == 'confirmed' ||
                    orderController.runningOrders?[i].status == 'cooking' ||
                    orderController.runningOrders?[i].status ==
                        'ready_for_handover' ||
                    orderController.runningOrders?[i].status ==
                        'food_on_the_way') {
                  if (orderController.runningOrders![i].orderList.isNotEmpty) {
                    isEnableTemporarilyClosed = true;
                    break;
                  } else {
                    isEnableTemporarilyClosed = false;
                  }
                }
              }
            }

            List<OrderModel> orderList = [];
            if (orderController.runningOrders != null) {
              orderList = orderController
                  .runningOrders![orderController.orderIndex].orderList;
            }

            return CustomScrollView(
              slivers: [
                GetPlatform.isAndroid
                    ? SliverToBoxAdapter(
                        child: Column(children: [
                          if (!_isNotificationPermissionGranted)
                            permissionWarning(
                                isBatteryPermission: false,
                                onTap: requestNotificationPermission,
                                closeOnTap: () {
                                  setState(() {
                                    _isNotificationPermissionGranted = true;
                                  });
                                }),
                          if (!_isBatteryOptimizationGranted)
                            permissionWarning(
                                isBatteryPermission: true,
                                onTap: requestBatteryOptimization,
                                closeOnTap: () {
                                  setState(() {
                                    _isBatteryOptimizationGranted = true;
                                  });
                                }),
                          SizedBox(
                              height: !_isNotificationPermissionGranted ||
                                      !_isBatteryOptimizationGranted
                                  ? Dimensions.paddingSizeDefault
                                  : 0),
                        ]),
                      )
                    : const SliverToBoxAdapter(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                        right: Dimensions.paddingSizeDefault,
                        top: GetPlatform.isAndroid
                            ? 0
                            : Dimensions.paddingSizeDefault),
                    child: Column(children: [
                      profileController.modulePermission != null &&
                              profileController.modulePermission!.storeSetup!
                          ? Container(
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall - 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .disabledColor
                                        .withValues(alpha: 0.3),
                                    width: 1),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault),
                                  border: Border.all(
                                    color: (profileController.profileModel
                                                ?.stores?[0].active ??
                                            false)
                                        ? Theme.of(context)
                                            .primaryColor
                                            .withValues(alpha: 0.1)
                                        : Theme.of(context)
                                            .disabledColor
                                            .withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Row(children: [
                                  // 1. Status Icon Indicator
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: ((profileController.profileModel
                                                      ?.stores?[0].active ??
                                                  false)
                                              ? Colors.green
                                              : Colors.red)
                                          .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      (profileController.profileModel
                                                  ?.stores?[0].active ??
                                              false)
                                          ? Icons.check_circle_rounded
                                          : Icons.pause_circle_filled_rounded,
                                      color: (profileController.profileModel
                                                  ?.stores?[0].active ??
                                              false)
                                          ? Colors.green
                                          : Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeSmall),

                                  // 2. Text Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          (profileController.profileModel
                                                      ?.stores?[0].active ??
                                                  false)
                                              ? 'online'.tr
                                              : 'offline'.tr,
                                          style: robotoBold.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color: (profileController
                                                        .profileModel
                                                        ?.stores?[0]
                                                        .active ??
                                                    false)
                                                ? Colors.green
                                                : Theme.of(context)
                                                    .disabledColor,
                                          ),
                                        ),
                                        Text(
                                          Get.find<SplashController>()
                                                  .configModel!
                                                  .moduleConfig!
                                                  .module!
                                                  .showRestaurantText!
                                              ? 'restaurant_temporarily_closed'
                                                  .tr
                                              : 'store_temporarily_closed'.tr,
                                          style: robotoRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeExtraSmall,
                                            color:
                                                Theme.of(context).disabledColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 3. Status Toggle / Shimmer
                                  profileController.profileModel != null
                                      ? Transform.scale(
                                          scale: 0.8,
                                          child: CupertinoSwitch(
                                            value: !profileController
                                                .profileModel!
                                                .stores![0]
                                                .active!,
                                            activeTrackColor:
                                                Theme.of(context).primaryColor,
                                            inactiveTrackColor:
                                                Theme.of(context)
                                                    .primaryColor
                                                    .withValues(alpha: 0.4),
                                            onChanged: (bool isActive) {
                                              if (isEnableTemporarilyClosed) {
                                                Get.dialog(
                                                    ConfirmationDialogWidget(
                                                  icon: Images.warning,
                                                  isOnNoPressedShow: false,
                                                  onYesButtonText: 'ok'.tr,
                                                  description:
                                                      'you_can_not_close_the_store_because_you_already_have_running_orders'
                                                          .tr,
                                                  onYesPressed: () =>
                                                      Get.back(),
                                                ));
                                              } else {
                                                Get.dialog(
                                                    ConfirmationDialogWidget(
                                                  icon: Images.warning,
                                                  description: isActive
                                                      ? (Get.find<SplashController>()
                                                              .configModel!
                                                              .moduleConfig!
                                                              .module!
                                                              .showRestaurantText!
                                                          ? 'are_you_sure_to_close_restaurant'
                                                              .tr
                                                          : 'are_you_sure_to_close_store'
                                                              .tr)
                                                      : (Get.find<SplashController>()
                                                              .configModel!
                                                              .moduleConfig!
                                                              .module!
                                                              .showRestaurantText!
                                                          ? 'are_you_sure_to_open_restaurant'
                                                              .tr
                                                          : 'are_you_sure_to_open_store'
                                                              .tr),
                                                  onYesPressed: () {
                                                    Get.back();
                                                    Get.find<AuthController>()
                                                        .toggleStoreClosedStatus();
                                                  },
                                                ));
                                              }
                                            },
                                          ),
                                        )
                                      : Shimmer(
                                          duration: const Duration(seconds: 2),
                                          child: Container(
                                            height: 30,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                ]),
                              ))
                          : const SizedBox(),
                      SizedBox(
                          height: profileController.modulePermission != null &&
                                  profileController
                                      .modulePermission!.storeSetup!
                              ? Dimensions.paddingSizeDefault
                              : 0),
                      profileController.modulePermission != null &&
                              profileController.modulePermission!.wallet!
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeDefault),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Theme.of(context).primaryColor.withValues(
                                        alpha: 0.8), // Your brand gradient
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(children: [
                                // Top Row: Today's Big Number
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'today_earnings'.tr,
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: Theme.of(context)
                                                    .cardColor
                                                    .withValues(alpha: 0.8),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              profileController.profileModel !=
                                                      null
                                                  ? PriceConverterHelper
                                                      .convertPrice(
                                                          profileController
                                                              .profileModel!
                                                              .todaysEarning)
                                                  : '0',
                                              style: robotoBold.copyWith(
                                                fontSize: 30,
                                                color:
                                                    Theme.of(context).cardColor,
                                                letterSpacing: -1,
                                              ),
                                            ),
                                          ]),

                                      // Floating Icon Background Effect
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .cardColor
                                              .withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                            Icons.account_balance_wallet,
                                            color: Theme.of(context).cardColor,
                                            size: 28),
                                      ),
                                    ]),

                                const SizedBox(
                                    height: Dimensions.paddingSizeLarge),

                                // Bottom Stats: Transparent Pill Design
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(
                                        alpha: 0.1), // Subtle contrast "glass"
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall),
                                  ),
                                  child: Row(children: [
                                    // Week Stat
                                    Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('this_week'.tr,
                                                style: robotoRegular.copyWith(
                                                  fontSize: 10,
                                                  color: Theme.of(context)
                                                      .cardColor
                                                      .withValues(alpha: 0.6),
                                                )),
                                            Text(
                                              profileController.profileModel !=
                                                      null
                                                  ? PriceConverterHelper
                                                      .convertPrice(
                                                          profileController
                                                              .profileModel!
                                                              .thisWeekEarning)
                                                  : '0',
                                              style: robotoMedium.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeDefault,
                                                  color: Theme.of(context)
                                                      .cardColor),
                                            ),
                                          ]),
                                    ),

                                    // Minimalist Divider
                                    Container(
                                        height: 20,
                                        width: 1,
                                        color: Theme.of(context)
                                            .cardColor
                                            .withValues(alpha: 0.2)),
                                    const SizedBox(width: 20),

                                    // Month Stat
                                    Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('this_month'.tr,
                                                style: robotoRegular.copyWith(
                                                  fontSize: 10,
                                                  color: Theme.of(context)
                                                      .cardColor
                                                      .withValues(alpha: 0.6),
                                                )),
                                            Text(
                                              profileController.profileModel !=
                                                      null
                                                  ? PriceConverterHelper
                                                      .convertPrice(
                                                          profileController
                                                              .profileModel!
                                                              .thisMonthEarning)
                                                  : '0',
                                              style: robotoMedium.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeDefault,
                                                  color: Theme.of(context)
                                                      .cardColor),
                                            ),
                                          ]),
                                    ),
                                  ]),
                                ),
                              ]),
                            )
                          : const SizedBox(),
                      SizedBox(
                          height: profileController.modulePermission != null &&
                                  profileController.modulePermission!.wallet!
                              ? Dimensions.paddingSizeExtraLarge
                              : 0),
                      profileController.modulePermission != null &&
                              profileController.modulePermission!.advertisement!
                          ? const AdsSectionWidget()
                          : const SizedBox(),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault),
                    child: Column(children: [
                      profileController.modulePermission != null
                          ? Get.find<ProfileController>()
                                  .modulePermission!
                                  .order!
                              ? Column(children: [
                                  orderController.runningOrders != null
                                      ? Container(
                                          height: 60,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withValues(alpha: 0.2),
                                                width: 1),
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusDefault),
                                          ),
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: orderController
                                                .runningOrders!.length,
                                            itemBuilder: (context, index) {
                                              return OrderButtonWidget(
                                                title: orderController
                                                    .runningOrders![index]
                                                    .status
                                                    .tr,
                                                index: index,
                                                orderController:
                                                    orderController,
                                                fromHistory: false,
                                              );
                                            },
                                          ),
                                        )
                                      : const SizedBox(),
                                  orderController.runningOrders != null
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top:
                                                  Dimensions.paddingSizeDefault,
                                              bottom:
                                                  Dimensions.paddingSizeSmall),
                                          child: InkWell(
                                            onTap: () => orderController
                                                .toggleCampaignOnly(),
                                            child: Row(children: [
                                              SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: Checkbox(
                                                  side: BorderSide(
                                                      color: Theme.of(context)
                                                          .disabledColor,
                                                      width: 1),
                                                  activeColor: Theme.of(context)
                                                      .primaryColor,
                                                  value: orderController
                                                      .campaignOnly,
                                                  onChanged: (isActive) =>
                                                      orderController
                                                          .toggleCampaignOnly(),
                                                ),
                                              ),
                                              const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeSmall),
                                              Text(
                                                'campaign_order'.tr,
                                                style: robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color: Theme.of(context)
                                                        .disabledColor),
                                              ),
                                            ]),
                                          ),
                                        )
                                      : const SizedBox(),
                                  orderController.runningOrders != null
                                      ? orderList.isNotEmpty
                                          ? ListView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: orderList.length,
                                              itemBuilder: (context, index) {
                                                return OrderWidget(
                                                    orderModel:
                                                        orderList[index],
                                                    hasDivider: index !=
                                                        orderList.length - 1,
                                                    isRunning: true);
                                              },
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10,
                                                  bottom: Dimensions
                                                      .paddingSizeLarge),
                                              child: Center(
                                                  child: Text(
                                                      'no_order_found'.tr)),
                                            )
                                      : ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: 10,
                                          itemBuilder: (context, index) {
                                            return OrderShimmerWidget(
                                                isEnabled: orderController
                                                        .runningOrders ==
                                                    null);
                                          },
                                        ),
                                ])
                              : Center(
                                  child: Padding(
                                  padding: const EdgeInsets.only(top: 100),
                                  child: Text(
                                      'you_have_no_permission_to_access_this_feature'
                                          .tr,
                                      style: robotoMedium),
                                ))
                          : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: 10,
                              itemBuilder: (context, index) {
                                return OrderShimmerWidget(
                                    isEnabled:
                                        orderController.runningOrders == null);
                              },
                            ),
                    ]),
                  ),
                ),
              ],
            );
          });
        }),
      ),
    );
  }

  Widget permissionWarning({
    required bool isBatteryPermission,
    required Function() onTap,
    required Function() closeOnTap,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      // 1. Premium Glassmorphic Design
      decoration: BoxDecoration(
        color: isBatteryPermission
            ? Colors.orangeAccent.withValues(alpha: 0.1)
            : Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: (isBatteryPermission ? Colors.orangeAccent : Colors.redAccent)
              .withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Row(
                  children: [
                    // 2. Animated-style Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isBatteryPermission
                                ? Colors.orangeAccent
                                : Colors.redAccent)
                            .withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isBatteryPermission
                            ? Icons.battery_alert_rounded
                            : Icons.notifications_off_rounded,
                        color: isBatteryPermission
                            ? Colors.orange
                            : Colors.redAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    // 3. Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isBatteryPermission
                                ? 'Optimization'.tr
                                : 'permission_required'.tr,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          Text(
                            isBatteryPermission
                                ? 'for_better_performance_allow_notification_to_run_in_background'
                                    .tr
                                : 'notification_is_disabled_please_allow_notification'
                                    .tr,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 4. Action Arrow
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Theme.of(context)
                          .disabledColor
                          .withValues(alpha: 0.5),
                      size: 16,
                    ),
                    const SizedBox(width: 25), // Space for close icon
                  ],
                ),
              ),

              // 5. Minimalist Close Button
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: closeOnTap,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .disabledColor
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withValues(alpha: 0.5),
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
