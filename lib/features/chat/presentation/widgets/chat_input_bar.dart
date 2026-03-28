import 'package:flutter/material.dart';
import 'package:tagme/core/constants/app_colors.dart';

/// Chat input bar with phone share button, text field, and send button.
///
/// Pinned to bottom of chat screen. Text field auto-expands to 4 lines.
/// Send button disabled (38% opacity) when input is empty.
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.onSharePhone,
    required this.onShareLocation,
  });

  final void Function(String text) onSend;
  final VoidCallback onSharePhone;
  final VoidCallback onShareLocation;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        border: Border(
          top: BorderSide(color: Color(0xFFE8EAED)),
        ),
      ),
      child: Row(
        children: [
          // Location share button
          Semantics(
            label: 'Share location',
            child: SizedBox(
              width: 44,
              height: 44,
              child: IconButton(
                onPressed: widget.onShareLocation,
                icon: const Icon(Icons.location_on),
                color: AppColors.onSurfaceDim,
                padding: EdgeInsets.zero,
              ),
            ),
          ),

          // Phone share button
          Semantics(
            label: 'Share your phone number',
            child: SizedBox(
              width: 44,
              height: 44,
              child: IconButton(
                onPressed: widget.onSharePhone,
                icon: const Icon(Icons.phone),
                color: AppColors.onSurfaceDim,
                padding: EdgeInsets.zero,
              ),
            ),
          ),

          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 32),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 4,
                minLines: 1,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceDim,
                      ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  isDense: true,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),

          // Send button
          Semantics(
            label: _hasText
                ? 'Send message'
                : 'Send message, disabled, type a message first',
            child: SizedBox(
              width: 44,
              height: 44,
              child: IconButton(
                onPressed: _hasText ? _handleSend : null,
                icon: Icon(
                  Icons.send,
                  color: AppColors.accent
                      .withValues(alpha: _hasText ? 1.0 : 0.38),
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
