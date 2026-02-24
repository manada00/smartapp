import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../widgets/common/app_button.dart';
import 'widgets/setup_progress_indicator.dart';

class DailyRoutineScreen extends ConsumerStatefulWidget {
  const DailyRoutineScreen({super.key});

  @override
  ConsumerState<DailyRoutineScreen> createState() => _DailyRoutineScreenState();
}

class _DailyRoutineScreenState extends ConsumerState<DailyRoutineScreen> {
  TimeOfDay _workStartTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _workEndTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 0);

  final Set<String> _trainingDays = {};
  String? _trainingTime;

  static const _days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  static const _trainingTimes = ['Morning', 'Afternoon', 'Evening'];

  Future<void> _selectTime(
    String label,
    TimeOfDay initialTime,
    ValueChanged<TimeOfDay> onSelect,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      onSelect(time);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _toggleDay(String day) {
    setState(() {
      if (_trainingDays.contains(day)) {
        _trainingDays.remove(day);
      } else {
        _trainingDays.add(day);
      }
      if (_trainingDays.isEmpty) {
        _trainingTime = null;
      }
    });
  }

  void _finishSetup() {
    context.go(Routes.addAddress);
  }

  void _skip() {
    context.go(Routes.addAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your Daily Routine'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SetupProgressIndicator(currentStep: 4, totalSteps: 4),
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
                          Text('Work Schedule', style: AppTextStyles.h6),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _TimePicker(
                                  label: 'Start Time',
                                  time: _workStartTime,
                                  formattedTime: _formatTime(_workStartTime),
                                  onTap: () => _selectTime(
                                    'Work Start',
                                    _workStartTime,
                                    (t) => setState(() => _workStartTime = t),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _TimePicker(
                                  label: 'End Time',
                                  time: _workEndTime,
                                  formattedTime: _formatTime(_workEndTime),
                                  onTap: () => _selectTime(
                                    'Work End',
                                    _workEndTime,
                                    (t) => setState(() => _workEndTime = t),
                                  ),
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
                          Text('Training Days', style: AppTextStyles.h6),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _days.map((day) {
                              final isSelected = _trainingDays.contains(day);
                              return ChoiceChip(
                                label: Text(day),
                                selected: isSelected,
                                onSelected: (_) => _toggleDay(day),
                                selectedColor: AppColors.primary,
                                backgroundColor: AppColors.surfaceWarm,
                                labelStyle: TextStyle(
                                  color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isSelected ? AppColors.primary : AppColors.divider,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          if (_trainingDays.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Divider(color: AppColors.divider),
                            const SizedBox(height: 16),
                            Text('Training Time', style: AppTextStyles.h6),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              children: _trainingTimes.map((time) {
                                final isSelected = _trainingTime == time;
                                return ChoiceChip(
                                  label: Text(time),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    setState(() => _trainingTime = time);
                                  },
                                  selectedColor: AppColors.primary,
                                  backgroundColor: AppColors.surfaceWarm,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? AppColors.textOnPrimary
                                        : AppColors.textPrimary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: isSelected ? AppColors.primary : AppColors.divider,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
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
                          Text('Sleep Time', style: AppTextStyles.h6),
                          const SizedBox(height: 16),
                          _TimePicker(
                            label: 'Bedtime',
                            time: _sleepTime,
                            formattedTime: _formatTime(_sleepTime),
                            onTap: () => _selectTime(
                              'Sleep',
                              _sleepTime,
                              (t) => setState(() => _sleepTime = t),
                            ),
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
                    text: 'Finish Setup',
                    onPressed: _finishSetup,
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

class _TimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final String formattedTime;
  final VoidCallback onTap;

  const _TimePicker({
    required this.label,
    required this.time,
    required this.formattedTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceWarm,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  formattedTime,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
