import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/checkout_provider.dart';
import '../../domain/entities/delivery_address.dart';

class DeliveryStepWidget extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const DeliveryStepWidget({
    super.key,
    required this.onNext,
  });

  @override
  ConsumerState<DeliveryStepWidget> createState() => _DeliveryStepWidgetState();
}

class _DeliveryStepWidgetState extends ConsumerState<DeliveryStepWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingAddress();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _landmarkController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _loadExistingAddress() {
    final checkoutState = ref.read(checkoutProvider);
    final address = checkoutState.deliveryAddress;
    
    if (address != null) {
      _nameController.text = address.recipientName;
      _phoneController.text = address.phoneNumber;
      _addressController.text = address.address;
      _addressLine2Controller.text = address.addressLine2 ?? '';
      _cityController.text = address.city;
      _regionController.text = address.region;
      _landmarkController.text = address.landmark ?? '';
      _instructionsController.text = address.specialInstructions ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final checkoutState = ref.watch(checkoutProvider);

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add your delivery address',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Please provide your delivery details',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Recipient Name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Recipient Name',
                      hint: 'Enter full name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value?.trim().isEmpty == true) {
                          return 'Please enter recipient name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Phone Number
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: '+255 XXX XXX XXX',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value?.trim().isEmpty == true) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Address
                    _buildTextField(
                      controller: _addressController,
                      label: 'Street Address',
                      hint: 'Enter your street address',
                      icon: Icons.location_on_outlined,
                      validator: (value) {
                        if (value?.trim().isEmpty == true) {
                          return 'Please enter street address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Address Line 2 (Optional)
                    _buildTextField(
                      controller: _addressLine2Controller,
                      label: 'Apartment, suite, etc. (Optional)',
                      hint: 'Apartment, suite, unit, building, floor, etc.',
                      icon: Icons.home_outlined,
                    ),
                    SizedBox(height: 16.h),

                    // City and Region
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _cityController,
                            label: 'City',
                            hint: 'Enter city',
                            icon: Icons.location_city_outlined,
                            validator: (value) {
                              if (value?.trim().isEmpty == true) {
                                return 'Please enter city';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildTextField(
                            controller: _regionController,
                            label: 'Region',
                            hint: 'Enter region',
                            icon: Icons.map_outlined,
                            validator: (value) {
                              if (value?.trim().isEmpty == true) {
                                return 'Please enter region';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Landmark (Optional)
                    _buildTextField(
                      controller: _landmarkController,
                      label: 'Landmark (Optional)',
                      hint: 'Nearby landmark for easy location',
                      icon: Icons.place_outlined,
                    ),
                    SizedBox(height: 16.h),

                    // Special Instructions (Optional)
                    _buildTextField(
                      controller: _instructionsController,
                      label: 'Special Instructions (Optional)',
                      hint: 'Any special delivery instructions',
                      icon: Icons.note_outlined,
                      maxLines: 3,
                    ),
                    SizedBox(height: 24.h),

                    // Use Current Location Button
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement location picker
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Location picker coming soon!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.my_location),
                      label: const Text('Use Current Location'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48.h),
                      ),
                    ),
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
                  onPressed: checkoutState.isLoading ? null : _handleNext,
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _handleNext() {
    if (_formKey.currentState?.validate() == true) {
      final address = DeliveryAddress(
        recipientName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        addressLine2: _addressLine2Controller.text.trim().isEmpty 
            ? null 
            : _addressLine2Controller.text.trim(),
        city: _cityController.text.trim(),
        region: _regionController.text.trim(),
        landmark: _landmarkController.text.trim().isEmpty 
            ? null 
            : _landmarkController.text.trim(),
        specialInstructions: _instructionsController.text.trim().isEmpty 
            ? null 
            : _instructionsController.text.trim(),
      );

      ref.read(checkoutProvider.notifier).setDeliveryAddress(address);
      widget.onNext();
    }
  }
}
