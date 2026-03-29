import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';

class AdsSectionWidget extends StatelessWidget {
  const AdsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110, // Sleeker, more compact height
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        // LUXURY DARK GRADIENT
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A), // Deep Charcoal
            Color(0xFF2D2D2D), // Lighter Onyx
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
      ),
      child: Stack(children: [
        // 1. Aesthetic Background Glow
        Positioned(
          right: -30,
          top: -20,
          child: Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
              boxShadow: [
                BoxShadow(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    blurRadius: 40,
                    spreadRadius: 20)
              ],
            ),
          ),
        ),

        // 2. Premium "LIVE" Status Badge
        Positioned(
          top: 12,
          left: 15,
          child: Row(children: [
            const Icon(Icons.fiber_manual_record,
                color: Colors.amber, size: 10), // Warm Gold Dot
            const SizedBox(width: 6),
            Text(
              'active_ad'.tr.toUpperCase(),
              style: robotoMedium.copyWith(
                fontSize: 9,
                color: Colors.white.withValues(alpha: 0.6),
                letterSpacing: 1.2,
              ),
            ),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(15, 35, 15, 10),
          child: Row(children: [
            // 3. Image with "Neon" Border
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3), width: 1),
              ),
              child: const CustomAssetImageWidget(Images.adsImage,
                  height: 55, width: 55),
            ),

            const SizedBox(width: Dimensions.paddingSizeDefault),

            // 4. Content with High-End Typography
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'maximize_reach'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    'premium_ad_placement'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            // 5. Luxury "Gold" CTA Button
            InkWell(
              onTap: () =>
                  Get.toNamed(RouteHelper.getCreateAdvertisementRoute()),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFD700),
                      Color(0xFFFFA500)
                    ], // Gold Gradient
                  ),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Text(
                  'get_started'.tr,
                  style: robotoBold.copyWith(
                    fontSize: 11,
                    color: Colors.black, // High contrast on gold
                  ),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
