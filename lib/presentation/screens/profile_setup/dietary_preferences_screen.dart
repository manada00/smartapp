import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import 'widgets/setup_progress_indicator.dart';

class DietaryPreferencesScreen extends ConsumerStatefulWidget {
  const DietaryPreferencesScreen({super.key});

  @override
  ConsumerState<DietaryPreferencesScreen> createState() =>
      _DietaryPreferencesScreenState();
}

class _DietaryPreferencesScreenState
    extends ConsumerState<DietaryPreferencesScreen> {
  final _dislikesController = TextEditingController();
  final _customAllergyController = TextEditingController();

  bool _isVegetarian = false;
  bool _isVegan = false;
  bool _isDairyFree = false;
  bool _isGlutenFree = false;
  bool _isKetoFriendly = false;

  final Set<String> _selectedAllergies = {};
  final List<String> _customAllergies = [];

  static const _allergies = [
    'Nuts',
    'Peanuts',
    'Eggs',
    'Fish',
    'Shellfish',
    'Soy',
    'Sesame',
    'Dairy',
  ];

  void _toggleAllergy(String allergy) {
    setState(() {
      if (_selectedAllergies.contains(allergy)) {
        _selectedAllergies.remove(allergy);
      } else {
        _selectedAllergies.add(allergy);
      }
    });
  }

  void _addCustomAllergy() {
    final allergy = _customAllergyController.text.trim();
    if (allergy.isNotEmpty && !_customAllergies.contains(allergy)) {
      setState(() {
        _customAllergies.add(allergy);
        _customAllergyController.clear();
      });
    }
    Navigator.pop(context);
  }

  void _showAddAllergyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: AppColors.surface,
        title: const Text('Add Allergy'),
        content: TextField(
          controller: _customAllergyController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter allergy name',
            fillColor: AppColors.surfaceWarm,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          onSubmitted: (_) => _addCustomAllergy(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _addCustomAllergy,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _continue() {
    context.push(Routes.dailyRoutine);
  }

  void _skip() {
    context.push(Routes.dailyRoutine);
  }

  @override
  void dispose() {
    _dislikesController.dispose();
    _customAllergyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dietary Preferences'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SetupProgressIndicator(currentStep: 3, totalSteps: 4),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Diet Type', style: AppTextStyles.h6),
                          const SizedBox(height: 16),
                          _DietToggle(
                            label: 'Vegetarian',
                            value: _isVegetarian,
                            onChanged: (v) => setState(() => _isVegetarian = v),
                          ),
                          _DietToggle(
                            label: 'Vegan',
                            value: _isVegan,
                            onChanged: (v) => setState(() => _isVegan = v),
                          ),
                          _DietToggle(
                            label: 'Dairy-Free',
                            value: _isDairyFree,
                            onChanged: (v) => setState(() => _isDairyFree = v),
                          ),
                          _DietToggle(
                            label: 'Gluten-Free',
                            value: _isGlutenFree,
                            onChanged: (v) => setState(() => _isGlutenFree = v),
                          ),
                          _DietToggle(
                            label: 'Keto-Friendly',
                            value: _isKetoFriendly,
                            onChanged: (v) => setState(() => _isKetoFriendly = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Allergies', style: AppTextStyles.h6),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ..._allergies.map((allergy) => FilterChip(
                                    label: Text(allergy),
                                    selected: _selectedAllergies.contains(allergy),
                                    onSelected: (_) => _toggleAllergy(allergy),
                                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                                    backgroundColor: AppColors.surfaceWarm,
                                    checkmarkColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: _selectedAllergies.contains(allergy)
                                            ? AppColors.primary.withValues(alpha: 0.3)
                                            : AppColors.divider,
                                      ),
                                    ),
                                  )),
                              ..._customAllergies.map((allergy) => Chip(
                                    label: Text(allergy),
                                    onDeleted: () {
                                      setState(() => _customAllergies.remove(allergy));
                                    },
                                    backgroundColor: AppColors.surfaceWarm,
                                    deleteIconColor: AppColors.textHint,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(color: AppColors.divider),
                                    ),
                                  )),
                              ActionChip(
                                avatar: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('Add Other'),
                                onPressed: _showAddAllergyDialog,
                                backgroundColor: AppColors.surfaceWarm,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: AppColors.divider),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            controller: _dislikesController,
                            label: 'Foods you don\'t enjoy',
                            hint: 'e.g., cilantro, olives, spicy food',
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7A6B50).withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  AppButton(
                    text: 'Continue',
                    onPressed: _continue,
                    width: double.infinity,
                    gradient: AppColors.primaryGradient,
                  ),
                  const SizedBox(height: 12),
                  AppTextButton(
                    text: 'Skip for now',
                    onPressed: _skip,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DietToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _DietToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: value ? AppColors.primary.withValues(alpha: 0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
