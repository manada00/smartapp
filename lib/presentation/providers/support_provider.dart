import 'dart:async';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import 'auth_provider.dart';

class SupportContactConfig {
  final String phone;
  final String email;
  final String whatsapp;

  const SupportContactConfig({
    required this.phone,
    required this.email,
    required this.whatsapp,
  });

  factory SupportContactConfig.fromMap(Map<String, dynamic> json) {
    return SupportContactConfig(
      phone: (json['phone'] as String? ?? '01552785430').trim(),
      email: (json['email'] as String? ?? 'support@smartfood.app').trim(),
      whatsapp: (json['whatsapp'] as String? ?? json['phone'] as String? ?? '01552785430').trim(),
    );
  }
}

class SupportMessageModel {
  final String senderType;
  final String channel;
  final String content;
  final DateTime createdAt;

  const SupportMessageModel({
    required this.senderType,
    required this.channel,
    required this.content,
    required this.createdAt,
  });

  factory SupportMessageModel.fromMap(Map<String, dynamic> json) {
    return SupportMessageModel(
      senderType: (json['senderType'] as String? ?? 'user').toLowerCase(),
      channel: (json['channel'] as String? ?? 'message').toLowerCase(),
      content: (json['content'] as String? ?? '').trim(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class SupportTicketModel {
  final String id;
  final String subject;
  final String status;
  final String priority;
  final List<SupportMessageModel> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupportTicketModel({
    required this.id,
    required this.subject,
    required this.status,
    required this.priority,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportTicketModel.fromMap(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: (json['_id'] as String? ?? '').trim(),
      subject: (json['subject'] as String? ?? '').trim(),
      status: (json['status'] as String? ?? 'open').trim(),
      priority: (json['priority'] as String? ?? 'medium').trim(),
      messages: (json['messages'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(SupportMessageModel.fromMap)
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class SupportReplyPreview {
  final String ticketId;
  final String subject;
  final String message;
  final DateTime createdAt;
  final String key;

  const SupportReplyPreview({
    required this.ticketId,
    required this.subject,
    required this.message,
    required this.createdAt,
    required this.key,
  });
}

class SupportInboxState {
  final int unreadCount;
  final DateTime? lastSeenAt;
  final SupportReplyPreview? latestUnreadPreview;
  final bool initialized;
  final String? lastNotifiedMessageKey;

  const SupportInboxState({
    this.unreadCount = 0,
    this.lastSeenAt,
    this.latestUnreadPreview,
    this.initialized = false,
    this.lastNotifiedMessageKey,
  });

  SupportInboxState copyWith({
    int? unreadCount,
    DateTime? lastSeenAt,
    SupportReplyPreview? latestUnreadPreview,
    bool? initialized,
    String? lastNotifiedMessageKey,
    bool clearLatestUnreadPreview = false,
  }) {
    return SupportInboxState(
      unreadCount: unreadCount ?? this.unreadCount,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      latestUnreadPreview: clearLatestUnreadPreview
          ? null
          : (latestUnreadPreview ?? this.latestUnreadPreview),
      initialized: initialized ?? this.initialized,
      lastNotifiedMessageKey: lastNotifiedMessageKey ?? this.lastNotifiedMessageKey,
    );
  }
}

final supportConfigProvider = FutureProvider<SupportContactConfig>((ref) async {
  final dio = ref.watch(dioClientProvider);
  final response = await dio.get(ApiConstants.supportConfig);
  final data = response.data['data'] as Map<String, dynamic>? ?? {};
  return SupportContactConfig.fromMap(data);
});

final supportTicketsProvider = StateNotifierProvider<SupportTicketsNotifier, AsyncValue<List<SupportTicketModel>>>(
  (ref) => SupportTicketsNotifier(ref.watch(dioClientProvider))..load(),
);

final supportInboxProvider = StateNotifierProvider<SupportInboxNotifier, SupportInboxState>(
  (ref) => SupportInboxNotifier(ref.watch(dioClientProvider)),
);

class SupportTicketsNotifier extends StateNotifier<AsyncValue<List<SupportTicketModel>>> {
  SupportTicketsNotifier(this._dio) : super(const AsyncValue.loading());

  final DioClient _dio;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get(ApiConstants.supportTickets);
      final items = (response.data['data'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(SupportTicketModel.fromMap)
          .toList();
      state = AsyncValue.data(items);
    } on DioException catch (error, st) {
      state = AsyncValue.error(ApiException.fromDioException(error), st);
    } catch (error, st) {
      state = AsyncValue.error(error, st);
    }
  }

  Future<void> createTicket({
    required String subject,
    required String message,
    String channel = 'message',
  }) async {
    await _dio.post(
      ApiConstants.supportTickets,
      data: {
        'subject': subject,
        'message': message,
        'channel': channel,
      },
    );
    await load();
  }

  Future<void> reply({
    required String ticketId,
    required String message,
    String channel = 'message',
  }) async {
    await _dio.post(
      '${ApiConstants.supportTickets}/$ticketId/reply',
      data: {
        'message': message,
        'channel': channel,
      },
    );
    await load();
  }
}

class SupportInboxNotifier extends StateNotifier<SupportInboxState> {
  SupportInboxNotifier(this._dio) : super(const SupportInboxState());

  final DioClient _dio;
  Timer? _timer;
  bool _refreshing = false;

  void startPolling() {
    if (_timer != null) return;

    _checkForNewReplies();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      _checkForNewReplies();
    });
  }

  Future<void> refreshNow() async {
    await _checkForNewReplies();
  }

  void markAllSeen() {
    state = state.copyWith(
      unreadCount: 0,
      lastSeenAt: DateTime.now().toUtc(),
      clearLatestUnreadPreview: true,
    );
  }

  Future<void> _checkForNewReplies() async {
    if (_refreshing) return;

    if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
      if (!Hive.isBoxOpen('secure_storage')) {
        return;
      }
    }

    _refreshing = true;

    try {
      final response = await _dio.get(ApiConstants.supportTickets);
      final tickets = (response.data['data'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(SupportTicketModel.fromMap)
          .toList();

      final adminMessages = <SupportReplyPreview>[];
      for (final ticket in tickets) {
        for (final message in ticket.messages) {
          if (message.senderType == 'admin') {
            adminMessages.add(
              SupportReplyPreview(
                ticketId: ticket.id,
                subject: ticket.subject,
                message: message.content,
                createdAt: message.createdAt.toUtc(),
                key: '${ticket.id}:${message.createdAt.toUtc().millisecondsSinceEpoch}:${message.content}',
              ),
            );
          }
        }
      }

      adminMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (!state.initialized) {
        state = state.copyWith(
          initialized: true,
          unreadCount: 0,
          lastSeenAt: adminMessages.isNotEmpty
              ? adminMessages.first.createdAt
              : DateTime.now().toUtc(),
          clearLatestUnreadPreview: true,
        );
        return;
      }

      final seenThreshold = state.lastSeenAt ?? DateTime.now().toUtc();
      final unread = adminMessages.where((message) => message.createdAt.isAfter(seenThreshold)).toList();

      final latestUnread = unread.isNotEmpty ? unread.first : null;
      final shouldNotify = latestUnread != null && latestUnread.key != state.lastNotifiedMessageKey;

      state = state.copyWith(
        unreadCount: unread.length,
        latestUnreadPreview: shouldNotify ? latestUnread : null,
        lastNotifiedMessageKey: shouldNotify ? latestUnread.key : state.lastNotifiedMessageKey,
      );
    } on DioException catch (_) {
    } catch (_) {
    } finally {
      _refreshing = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
