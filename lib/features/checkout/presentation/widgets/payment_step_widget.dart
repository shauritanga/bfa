import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/checkout_provider.dart';
import '../../domain/entities/payment_method.dart';

class PaymentStepWidget extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const PaymentStepWidget({
    super.key,
    required this.onNext,
  });

  @override
  ConsumerState<PaymentStepWidget> createState() => _PaymentStepWidgetState();
}

class _PaymentStepWidgetState extends ConsumerState<PaymentStepWidget> {
  CheckoutPaymentMethod? _selectedPaymentMethod;
  final _phoneController = TextEditingController();
  final _accountController = TextEditingController();
  final _accountNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingPaymentMethod();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _accountController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  void _loadExistingPaymentMethod() {
    final checkoutState = ref.read(checkoutProvider);
    final paymentMethod = checkoutState.paymentMethod;
    
    if (paymentMethod != null) {
      _selectedPaymentMethod = paymentMethod;
      _phoneController.text = paymentMethod.phoneNumber ?? '';
      _accountController.text = paymentMethod.accountNumber ?? '';
      _accountNameController.text = paymentMethod.accountName ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final checkoutState = ref.watch(checkoutProvider);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose a payment method',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Select your preferred payment option',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Cash on Delivery
                  _buildPaymentOption(
                    title: 'Cash on Delivery',
                    subtitle: 'Pay when you receive your order',
                    icon: Icons.money,
                    isSelected: _selectedPaymentMethod?.type == PaymentMethodType.cashOnDelivery,
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = CheckoutPaymentMethod.cashOnDelivery();
                      });
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Mobile Money
                  _buildPaymentOption(
                    title: 'Mobile Money',
                    subtitle: 'Pay with M-Pesa, Tigo Pesa, Airtel Money',
                    icon: Icons.phone_android,
                    isSelected: _selectedPaymentMethod?.type == PaymentMethodType.mobileMoney,
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = CheckoutPaymentMethod.mobileMoney(
                          provider: PaymentProviderType.mpesa,
                          phoneNumber: _phoneController.text,
                        );
                      });
                    },
                  ),

                  // Mobile Money Details
                  if (_selectedPaymentMethod?.type == PaymentMethodType.mobileMoney) ...[
                    SizedBox(height: 16.h),
                    _buildMobileMoneyDetails(),
                  ],

                  SizedBox(height: 16.h),

                  // Bank Transfer
                  _buildPaymentOption(
                    title: 'Bank Transfer',
                    subtitle: 'Transfer to our bank account',
                    icon: Icons.account_balance,
                    isSelected: _selectedPaymentMethod?.type == PaymentMethodType.bankTransfer,
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = CheckoutPaymentMethod.bankTransfer(
                          accountNumber: _accountController.text,
                          accountName: _accountNameController.text,
                        );
                      });
                    },
                  ),

                  // Bank Transfer Details
                  if (_selectedPaymentMethod?.type == PaymentMethodType.bankTransfer) ...[
                    SizedBox(height: 16.h),
                    _buildBankTransferDetails(),
                  ],
                ],
              ),
            ),
          ),

          // Next Button
          Container(
            padding: EdgeInsets.all(16.w),
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _selectedPaymentMethod != null && !checkoutState.isLoading
                    ? _handleNext
                    : null,
                child: checkoutState.isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Next'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
          color: isSelected 
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: isSelected 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurfaceVariant,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? theme.colorScheme.primary 
                          : null,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileMoneyDetails() {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mobile Money Provider',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          
          // Provider Selection
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: PaymentProviderType.values.map((provider) {
              final isSelected = _selectedPaymentMethod?.provider == provider;
              return ChoiceChip(
                label: Text(_getProviderName(provider)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedPaymentMethod = CheckoutPaymentMethod.mobileMoney(
                        provider: provider,
                        phoneNumber: _phoneController.text,
                      );
                    });
                  }
                },
              );
            }).toList(),
          ),
          
          SizedBox(height: 16.h),
          
          // Phone Number
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '+255 XXX XXX XXX',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (_selectedPaymentMethod?.type == PaymentMethodType.mobileMoney) {
                setState(() {
                  _selectedPaymentMethod = _selectedPaymentMethod!.copyWith(
                    phoneNumber: value,
                  );
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransferDetails() {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bank Account Details',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          
          TextFormField(
            controller: _accountController,
            decoration: const InputDecoration(
              labelText: 'Account Number',
              hintText: 'Enter account number',
              prefixIcon: Icon(Icons.account_balance),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (_selectedPaymentMethod?.type == PaymentMethodType.bankTransfer) {
                setState(() {
                  _selectedPaymentMethod = _selectedPaymentMethod!.copyWith(
                    accountNumber: value,
                  );
                });
              }
            },
          ),
          
          SizedBox(height: 16.h),
          
          TextFormField(
            controller: _accountNameController,
            decoration: const InputDecoration(
              labelText: 'Account Name',
              hintText: 'Enter account holder name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (_selectedPaymentMethod?.type == PaymentMethodType.bankTransfer) {
                setState(() {
                  _selectedPaymentMethod = _selectedPaymentMethod!.copyWith(
                    accountName: value,
                  );
                });
              }
            },
          ),
        ],
      ),
    );
  }

  String _getProviderName(PaymentProviderType provider) {
    switch (provider) {
      case PaymentProviderType.mpesa:
        return 'M-Pesa';
      case PaymentProviderType.tigoPesa:
        return 'Tigo Pesa';
      case PaymentProviderType.airltelMoney:
        return 'Airtel Money';
      case PaymentProviderType.halopesa:
        return 'HaloPesa';
    }
  }

  void _handleNext() {
    if (_selectedPaymentMethod != null) {
      ref.read(checkoutProvider.notifier).setPaymentMethod(_selectedPaymentMethod!);
      widget.onNext();
    }
  }
}
