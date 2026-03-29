import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:tagme/core/constants/app_colors.dart';
import 'package:tagme/core/constants/app_spacing.dart';
import 'package:tagme/core/constants/transport_types.dart';
import 'package:tagme/features/chat/data/models/conversation.dart';
import 'package:tagme/features/chat/data/models/message.dart';
import 'package:tagme/features/chat/data/repositories/chat_repository.dart';
import 'package:tagme/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:tagme/features/chat/presentation/widgets/message_bubble.dart';
import 'package:tagme/features/chat/presentation/widgets/phone_share_card.dart';
import 'package:tagme/features/chat/providers/chat_providers.dart';
import 'package:tagme/features/location_sharing/data/repositories/live_location_repository.dart';
import 'package:tagme/features/location_sharing/presentation/widgets/embedded_live_map.dart';
import 'package:tagme/features/location_sharing/presentation/widgets/live_sharing_banner.dart';
import 'package:tagme/features/location_sharing/presentation/widgets/location_attachment_sheet.dart';
import 'package:tagme/features/location_sharing/presentation/widgets/location_share_card.dart';
import 'package:tagme/features/location_sharing/providers/live_location_providers.dart';
import 'package:tagme/features/map/providers/location_provider.dart';
import 'package:tagme/features/profile/providers/profile_provider.dart';
import 'package:tagme/features/rides/data/services/route_service.dart';
import 'package:tagme/features/rides/presentation/widgets/route_visualization.dart';

/// Full-screen chat conversation with ride context header,
/// real-time messages, input bar, and phone share dialog.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {
  /// Messages being sent optimistically (not yet confirmed by Firestore).
  final List<Message> _pendingMessages = [];
  bool _markedAsRead = false;

  // Live location sharing state
  bool _isLiveSharing = false;
  DateTime? _liveSharingStartTime;
  Timer? _countdownTimer;
  ThrottledLocationWriter? _locationWriter;
  StreamSubscription<Position>? _locationSubscription;
  static const _liveSharingDuration = Duration(minutes: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Mark as read on init (deferred to after first build to have ref).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markAsRead();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLiveSharing(sendStopToFirestore: false);
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (_isLiveSharing) {
        _stopLiveSharing();
      }
    }
  }

  void _markAsRead() {
    if (_markedAsRead) return;
    final currentUserId = ref.read(profileProvider).value?.id ?? '';
    if (currentUserId.isNotEmpty) {
      _markedAsRead = true;
      ref
          .read(chatRepositoryProvider)
          .markAsRead(widget.conversationId, currentUserId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final profileAsync = ref.watch(profileProvider);
    final currentUserId = profileAsync.value?.id ?? '';
    final currentUserName = profileAsync.value?.name ?? '';

    final messagesAsync =
        ref.watch(chatMessagesProvider(widget.conversationId));
    final conversationAsync =
        ref.watch(conversationDetailProvider(widget.conversationId));

    // Derive other participant info
    final conversation = conversationAsync.value;
    final otherId = conversation?.participantIds
            .where((id) => id != currentUserId)
            .firstOrNull ??
        '';
    final otherName =
        conversation?.participantNames[otherId] ?? 'Chat';
    final otherUniversity =
        conversation?.participantUniversities[otherId] ?? '';
    final universityColor = AppColors.getUniversityColor(otherUniversity);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: universityColor, width: 2),
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: cs.surfaceContainerHighest,
                child: Text(
                  otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherName,
                    style: theme.textTheme.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (otherUniversity.isNotEmpty)
                    Text(
                      otherUniversity,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Ride context header
          if (conversation != null)
            _buildRideContextHeader(context, theme, conversation),

          // Live sharing banner
          if (_isLiveSharing && _liveSharingStartTime != null)
            LiveSharingBanner(
              remainingDuration: _computeRemainingDuration(),
              onStop: _stopLiveSharing,
            ),

          // Embedded live map (show when any participant is sharing)
          Builder(builder: (context) {
            final liveLocationsAsync = ref.watch(
              activeLiveLocationsProvider(widget.conversationId),
            );
            final hasActiveLiveLocations =
                liveLocationsAsync.value?.isNotEmpty ?? false;
            if (!hasActiveLiveLocations && !_isLiveSharing) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: EmbeddedLiveMap(
                conversationId: widget.conversationId,
                currentUserId: currentUserId,
              ),
            );
          }),

          // Message area
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (_, __) => Center(
                child: Text(
                  'Could not load messages.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              data: (messages) {
                // Combine confirmed messages with pending ones
                final allMessages = [
                  ..._pendingMessages,
                  ...messages,
                ];

                if (allMessages.isEmpty) {
                  return Center(
                    child: Text(
                      'Say hello to start the conversation',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: allMessages.length,
                  itemBuilder: (context, index) {
                    final message = allMessages[index];
                    final isSent = message.senderId == currentUserId;
                    final isPending = _pendingMessages.contains(message);

                    // Date separator logic
                    Widget? dateSeparator;
                    if (index < allMessages.length - 1) {
                      final nextMessage = allMessages[index + 1];
                      if (message.createdAt != null &&
                          nextMessage.createdAt != null) {
                        final msgDay = DateTime(
                          message.createdAt!.year,
                          message.createdAt!.month,
                          message.createdAt!.day,
                        );
                        final nextDay = DateTime(
                          nextMessage.createdAt!.year,
                          nextMessage.createdAt!.month,
                          nextMessage.createdAt!.day,
                        );
                        if (msgDay != nextDay) {
                          dateSeparator =
                              _buildDateSeparator(context, nextMessage.createdAt!);
                        }
                      }
                    } else if (message.createdAt != null) {
                      // First message (oldest) gets a separator
                      dateSeparator =
                          _buildDateSeparator(context, message.createdAt!);
                    }

                    // Spacing logic
                    final spacing = _getSpacing(allMessages, index);

                    // Build message widget
                    Widget messageWidget;
                    if (message.type == 'phone_shared') {
                      messageWidget = PhoneShareCard(
                        message: message,
                        isSent: isSent,
                      );
                    } else if (message.type == 'location_shared') {
                      messageWidget = LocationShareCard(
                        message: message,
                        isSent: isSent,
                      );
                    } else {
                      messageWidget = MessageBubble(
                        message: message,
                        isSent: isSent,
                      );
                    }

                    // Apply opacity for pending messages
                    if (isPending) {
                      messageWidget = Opacity(
                        opacity: 0.6,
                        child: messageWidget,
                      );
                    }

                    return Column(
                      children: [
                        if (dateSeparator != null) dateSeparator,
                        Padding(
                          padding: EdgeInsets.only(top: spacing),
                          child: messageWidget,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Input bar
          ChatInputBar(
            onSend: (text) => _handleSend(
              text,
              currentUserId,
              currentUserName,
            ),
            onSharePhone: () => _showPhoneShareDialog(
              context,
              currentUserId,
              currentUserName,
              otherName,
            ),
            onShareLocation: () => _showLocationAttachmentSheet(
              context,
              currentUserId,
              currentUserName,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideContextHeader(
    BuildContext context,
    ThemeData theme,
    Conversation conversation,
  ) {
    // Resolve transport icon
    var transportIcon = Icons.directions;
    final idx = TransportType.values.indexWhere(
      (t) => t.name == conversation.rideTransportType,
    );
    if (idx >= 0) {
      transportIcon = TransportType.values[idx].icon;
    }

    final departureText = conversation.rideDepartureTime != null
        ? DateFormat.jm().format(conversation.rideDepartureTime!)
        : '';

    return GestureDetector(
      onTap: () => context.push('/rides/${conversation.rideId}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: RouteVisualization(
                originAddress: conversation.rideOrigin,
                destinationAddress: conversation.rideDestination,
                compact: true,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(transportIcon, size: 16, color: theme.colorScheme.onSurfaceVariant),
                if (departureText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    departureText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSeparator(BuildContext context, DateTime date) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDay = DateTime(date.year, date.month, date.day);

    String label;
    if (messageDay == today) {
      label = 'Today';
    } else if (messageDay == yesterday) {
      label = 'Yesterday';
    } else {
      label = DateFormat('EEE, MMM d').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
        ],
      ),
    );
  }

  double _getSpacing(List<Message> messages, int index) {
    if (index >= messages.length - 1) return 0;
    final current = messages[index];
    final next = messages[index + 1];
    // Same sender: 8px, different sender: 16px
    return current.senderId == next.senderId
        ? AppSpacing.sm
        : AppSpacing.md;
  }

  Future<void> _handleSend(
    String text,
    String currentUserId,
    String currentUserName,
  ) async {
    // Optimistic: add pending message
    final pendingMsg = Message(
      senderId: currentUserId,
      senderName: currentUserName,
      text: text,
      createdAt: DateTime.now(),
    );
    setState(() => _pendingMessages.insert(0, pendingMsg));

    try {
      await ref.read(chatRepositoryProvider).sendMessage(
            conversationId: widget.conversationId,
            senderId: currentUserId,
            senderName: currentUserName,
            text: text,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Message not sent. Check your connection.')),
        );
      }
    } finally {
      // Remove pending message once stream delivers the confirmed one
      if (mounted) {
        setState(() => _pendingMessages.remove(pendingMsg));
      }
    }
  }

  void _showLocationAttachmentSheet(
    BuildContext context,
    String currentUserId,
    String currentUserName,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationAttachmentSheet(
        onShareStatic: () {
          Navigator.of(context).pop(); // Dismiss sheet
          _sendStaticLocation(currentUserId, currentUserName);
        },
        onShareLive: () {
          Navigator.of(context).pop(); // Dismiss sheet
          final userId = ref.read(profileProvider).value?.id ?? '';
          if (userId.isNotEmpty) {
            _startLiveSharing(userId);
          }
        },
      ),
    );
  }

  Future<void> _sendStaticLocation(
    String currentUserId,
    String currentUserName,
  ) async {
    final locationAsync = ref.read(currentLocationProvider);
    final position = locationAsync.value;
    if (position == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not get your location. Check that location is enabled.',
            ),
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          ),
        );
      }
      return;
    }

    // Reverse geocode for a label (best-effort, fallback to coordinates)
    String label =
        '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
    try {
      final routeService = ref.read(routeServiceProvider);
      final geocoded = await routeService.reverseGeocode(
        LatLng(position.latitude, position.longitude),
      );
      if (geocoded != 'Unknown location') {
        label = geocoded;
      }
    } catch (_) {
      // Use coordinate fallback
    }

    try {
      await ref.read(chatRepositoryProvider).sendMessage(
            conversationId: widget.conversationId,
            senderId: currentUserId,
            senderName: currentUserName,
            text: label,
            type: 'location_shared',
            latitude: position.latitude,
            longitude: position.longitude,
            locationLabel: label,
          );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not share location. Try again.'),
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Live location sharing
  // ---------------------------------------------------------------------------

  Duration _computeRemainingDuration() {
    if (_liveSharingStartTime == null) return Duration.zero;
    final elapsed = DateTime.now().difference(_liveSharingStartTime!);
    final remaining = _liveSharingDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void _startLiveSharing(String currentUserId) {
    final repo = ref.read(liveLocationRepositoryProvider);
    _locationWriter = ThrottledLocationWriter(repository: repo);
    _liveSharingStartTime = DateTime.now();

    // Start GPS stream with distanceFilter: 10m
    final locationStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
    _locationSubscription = locationStream.listen((position) {
      _locationWriter?.onPositionUpdate(
        position,
        conversationId: widget.conversationId,
        userId: currentUserId,
      );
    });

    // Start countdown timer (updates every second for banner display)
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final elapsed = DateTime.now().difference(_liveSharingStartTime!);
      if (elapsed >= _liveSharingDuration) {
        _stopLiveSharing();
      } else {
        setState(() {}); // Rebuild to update countdown
      }
    });

    setState(() => _isLiveSharing = true);
  }

  Future<void> _stopLiveSharing({bool sendStopToFirestore = true}) async {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _locationWriter?.dispose();
    _locationWriter = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;

    if (sendStopToFirestore) {
      final currentUserId = ref.read(profileProvider).value?.id ?? '';
      if (currentUserId.isNotEmpty) {
        try {
          await ref.read(liveLocationRepositoryProvider).stopSharing(
                conversationId: widget.conversationId,
                userId: currentUserId,
              );
        } catch (_) {
          // Best-effort cleanup
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLiveSharing = false;
        _liveSharingStartTime = null;
      });
    }
  }

  void _showPhoneShareDialog(
    BuildContext context,
    String currentUserId,
    String currentUserName,
    String otherName,
  ) {
    final phoneController = TextEditingController();
    final theme = Theme.of(context);
    var isSending = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Share Your Phone Number'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your phone number will be visible to $otherName '
                  'in this chat. This cannot be undone.',
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter your phone number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  "Don't Share",
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              FilledButton(
                onPressed: isSending
                    ? null
                    : () async {
                        final phone = phoneController.text.trim();
                        if (phone.isEmpty) return;

                        setDialogState(() => isSending = true);
                        try {
                          await ref
                              .read(chatRepositoryProvider)
                              .sendMessage(
                                conversationId: widget.conversationId,
                                senderId: currentUserId,
                                senderName: currentUserName,
                                text: 'Shared phone number',
                                type: 'phone_shared',
                                phoneNumber: phone,
                              );
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        } catch (_) {
                          setDialogState(() => isSending = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not share your number. Try again.')),
                            );
                          }
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
                child: isSending
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Share Number'),
              ),
            ],
          );
        },
      ),
    );
  }
}
