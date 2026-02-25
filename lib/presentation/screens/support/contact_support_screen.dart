import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/support_provider.dart';

class ContactSupportScreen extends ConsumerStatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  ConsumerState<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends ConsumerState<ContactSupportScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _channel = 'message';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supportInboxProvider.notifier).markAllSeen();
      ref.read(supportInboxProvider.notifier).refreshNow();
    });
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final subject = Uri.encodeComponent('Smart Food Support');
    final body = Uri.encodeComponent(_messageController.text.trim());
    final uri = Uri.parse('mailto:$email?subject=$subject&body=$body');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final uri = Uri.parse('https://wa.me/${phone.replaceAll('+', '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _submitTicket() async {
    if (_submitting) return;
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add both subject and message.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(supportTicketsProvider.notifier).createTicket(
            subject: subject,
            message: message,
            channel: _channel,
          );

      _subjectController.clear();
      _messageController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Support request sent successfully.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send support request.')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(supportConfigProvider);
    final ticketsAsync = ref.watch(supportTicketsProvider);

    final supportPhone = configAsync.value?.phone ?? '01552785430';
    final supportEmail = configAsync.value?.email ?? 'support@smartfood.app';
    final supportWhatsapp = configAsync.value?.whatsapp ?? supportPhone;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Contact Us')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('We\'re here to help!', style: AppTextStyles.h4),
          const SizedBox(height: 8),
          Text(
            'Choose your preferred way to reach us',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          _ContactOption(
            icon: Icons.chat_bubble_rounded,
            iconColor: AppColors.primary,
            title: 'Send Message',
            subtitle: 'Your message is delivered to admin support inbox',
            badge: 'Fastest',
            badgeColor: AppColors.success,
            onTap: () {
              setState(() => _channel = 'message');
            },
          ),
          _ContactOption(
            icon: Icons.phone_rounded,
            iconColor: AppColors.info,
            title: 'Call Us',
            subtitle: 'Available 9 AM - 11 PM',
            onTap: () => _launchPhone(supportPhone),
          ),
          _ContactOption(
            icon: Icons.email_rounded,
            iconColor: AppColors.secondary,
            title: 'Send Email',
            subtitle: 'Create email ticket + optional local mail app launch',
            onTap: () {
              setState(() => _channel = 'email');
              _launchEmail(supportEmail);
            },
          ),
          _ContactOption(
            icon: Icons.chat_rounded,
            iconColor: AppColors.success,
            title: 'WhatsApp',
            subtitle: 'Chat with us on WhatsApp',
            onTap: () => _launchWhatsApp(supportWhatsapp),
          ),
          const SizedBox(height: 12),
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
                Text('Send Support Request', style: AppTextStyles.labelLarge),
                const SizedBox(height: 12),
                TextField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _messageController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _channel,
                        decoration: const InputDecoration(
                          labelText: 'Channel',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'message', child: Text('Message (in-app)')),
                          DropdownMenuItem(value: 'email', child: Text('Email')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _channel = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _submitting ? null : _submitTicket,
                      child: Text(_submitting ? 'Sending...' : 'Send'),
                    ),
                  ],
                ),
                if (configAsync.isLoading) ...[
                  const SizedBox(height: 10),
                  Text('Loading support contact settings...', style: AppTextStyles.caption),
                ],
                const SizedBox(height: 10),
                Text('Current support phone: $supportPhone', style: AppTextStyles.caption),
                Text('Current support email: $supportEmail', style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Support Conversations', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                ticketsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Text(
                    error.toString(),
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                  ),
                  data: (tickets) {
                    if (tickets.isEmpty) {
                      return Text('No support conversations yet.', style: AppTextStyles.bodySmall);
                    }

                    return Column(
                      children: tickets.map((ticket) {
                        final lastMessage = ticket.messages.isNotEmpty ? ticket.messages.last : null;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWarm,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ExpansionTile(
                            title: Text(ticket.subject, style: AppTextStyles.bodyMedium),
                            subtitle: Text(
                              'Status: ${ticket.status} · ${ticket.priority}',
                              style: AppTextStyles.caption,
                            ),
                            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            children: [
                              if (lastMessage != null)
                                Text(
                                  'Last message: ${lastMessage.content}',
                                  style: AppTextStyles.bodySmall,
                                ),
                              const SizedBox(height: 8),
                              ...ticket.messages.map((message) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Align(
                                      alignment: message.senderType == 'admin'
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: message.senderType == 'admin'
                                              ? AppColors.surface
                                              : AppColors.primary.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${message.senderType == 'admin' ? 'Admin' : 'You'} · ${message.channel}',
                                              style: AppTextStyles.caption,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(message.content, style: AppTextStyles.bodySmall),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceWarm,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Office Hours', style: AppTextStyles.labelLarge),
                const SizedBox(height: 12),
                _HoursRow(
                  day: 'Saturday - Thursday',
                  hours: '9:00 AM - 11:00 PM',
                ),
                _HoursRow(day: 'Friday', hours: '2:00 PM - 11:00 PM'),
                const SizedBox(height: 12),
                Text(
                  'Note: Live chat and WhatsApp are available 24/7 for urgent issues.',
                  style: AppTextStyles.caption,
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
              border: Border.all(color: AppColors.divider),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Report an Issue', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                Text(
                  'Have a problem with a recent order? Let us know and we\'ll make it right.',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _channel = 'message');
                  },
                  icon: const Icon(Icons.report_rounded),
                  label: const Text('Report Issue'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _ContactOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(title, style: AppTextStyles.labelLarge),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor ?? AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                badge!,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textOnPrimary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(subtitle, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  final String day;
  final String hours;

  const _HoursRow({required this.day, required this.hours});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: AppTextStyles.bodySmall),
          Text(hours, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}
