import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/chat_store.dart';
import '../theme/app_theme.dart';

/// 1:1 DM 또는 그룹채팅 대화 화면. 채팅 목록에서 대화방을 선택하면 진입합니다.
class ChatConversationScreen extends StatefulWidget {
  final ChatConversation conversation;
  const ChatConversationScreen({super.key, required this.conversation});

  @override
  State<ChatConversationScreen> createState() =>
      _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send(BuildContext context) {
    final text = _inputCtrl.text;
    if (text.trim().isEmpty) return;
    context.read<ChatStore>().sendMessage(widget.conversation.id, text);
    _inputCtrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatStore>();
    final messages = chat.messagesFor(widget.conversation.id);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        title: Text(
          widget.conversation.isGroup
              ? '${widget.conversation.title} (${widget.conversation.participants.length})'
              : widget.conversation.title,
          style: AppText.h3,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (_, i) => _MessageBubble(
                message: messages[i],
                showAuthor: widget.conversation.isGroup,
              ),
            ),
          ),
          _InputBar(controller: _inputCtrl, onSend: () => _send(context)),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAuthor;
  const _MessageBubble({required this.message, required this.showAuthor});

  @override
  Widget build(BuildContext context) {
    final align =
        message.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: align,
        children: [
          if (showAuthor && !message.isMine)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(message.authorName, style: AppText.caption),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: message.isMine ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Text(
              message.text,
              style: AppText.body.copyWith(
                fontSize: 14,
                color: message.isMine ? Colors.white : AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.trackAlt)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: '메시지 보내기',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onSend,
              icon: const Icon(Icons.send, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
