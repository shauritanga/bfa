import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../providers/checkout_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../widgets/delivery_step_widget.dart';
import '../widgets/payment_step_widget.dart';
import '../widgets/review_step_widget.dart';
import '../widgets/confirmation_step_widget.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutProvider);
    final cartState = ref.watch(cartProvider);
    final theme = Theme.of(context);

    // If cart is empty, redirect back
    if (cartState.cart?.isEmpty != false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pop();
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (checkoutState.currentStep > 0) {
              ref.read(checkoutProvider.notifier).previousStep();
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              context.pop();
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(theme, checkoutState.currentStep),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                DeliveryStepWidget(onNext: () => _nextStep()),
                PaymentStepWidget(onNext: () => _nextStep()),
                ReviewStepWidget(
                  cart: cartState.cart!,
                  onPlaceOrder: () => _placeOrder(),
                ),
                ConfirmationStepWidget(
                  onContinueShopping: () => _continueShopping(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme, int currentStep) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Delivery', currentStep, theme),
          _buildStepConnector(currentStep >= 1, theme),
          _buildStepIndicator(1, 'Payment', currentStep, theme),
          _buildStepConnector(currentStep >= 2, theme),
          _buildStepIndicator(2, 'Review', currentStep, theme),
          _buildStepConnector(currentStep >= 3, theme),
          _buildStepIndicator(3, 'Done', currentStep, theme),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
    int step,
    String label,
    int currentStep,
    ThemeData theme,
  ) {
    final isActive = step == currentStep;
    final isCompleted = step < currentStep;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? theme.colorScheme.primary
                  : isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: isActive || isCompleted
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      color: theme.colorScheme.onPrimary,
                      size: 16.sp,
                    )
                  : Text(
                      '${step + 1}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isActive
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isActive || isCompleted
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool isCompleted, ThemeData theme) {
    return Expanded(
      child: Container(
        height: 2.h,
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isCompleted
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(1.r),
        ),
      ),
    );
  }

  void _nextStep() {
    ref.read(checkoutProvider.notifier).nextStep();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _placeOrder() {
    // This will be implemented in the review step widget
    _nextStep();
  }

  void _continueShopping() {
    // Reset checkout and navigate to home
    ref.read(checkoutProvider.notifier).reset();
    context.go('/home');
  }
}
