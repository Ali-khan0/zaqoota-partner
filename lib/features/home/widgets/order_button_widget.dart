import 'package:sixam_mart_store/features/order/controllers/order_controller.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:flutter/material.dart';

class OrderButtonWidget extends StatelessWidget {
  final String title;
  final int index;
  final OrderController orderController;
  final bool fromHistory;
  const OrderButtonWidget(
      {super.key,
      required this.title,
      required this.index,
      required this.orderController,
      required this.fromHistory});

  @override
  Widget build(BuildContext context) {
    int selectedIndex;
    int length = 0;

    if (fromHistory) {
      selectedIndex = orderController.historyIndex;
    } else {
      selectedIndex = orderController.orderIndex;
      length = orderController.runningOrders![index].orderList.length;
    }

    bool isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => fromHistory
          ? orderController.setHistoryIndex(index)
          : orderController.setOrderIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault, vertical: 8),
        decoration: BoxDecoration(
          // Using a soft version of primary color instead of hardcoded blue
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(
              Dimensions.radiusLarge), // Fully rounded pills
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              maxLines: 1,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor,
              ),
            ),

            // Modern Badge for order count
            if (!fromHistory && length > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor.withValues(alpha: 0.2),
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusExtraLarge),
                ),
                child: Text(
                  '$length',
                  style: robotoBold.copyWith(
                    fontSize: 10,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).disabledColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
