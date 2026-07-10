import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/chat_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'chat_conversation_screen.dart';

/// 톡 — 게시판(커뮤니티)에서 만난 사람과의 1:1 DM, 여러 명이 함께 쓰는 그룹채팅 목록.
/// 하단 네비게이션의 "톡" 탭에서 진입합니다.
class ChatListScreen extends StatelessWidget {
  static const route = '/chat';
  const ChatListScreen({super.key});

  String _timeLabel(DateTime? t) {
    if (t == null) return '';
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return '방금';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatStore>();
    final conversations = chat.conversations;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const BrandAppBar(showBack: true),
      body: conversations.isEmpty
          ? const EmptyState('아직 대화가 없어요.')
          : ListView.separated(
              padding: AppSpacing.screenPadding,
              itemCount: conversations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final convo = conversations[i];
                final last = chat.lastMessage(convo.id);
                return _ConversationTile(
                  conversation: convo,
                  lastMessage: last,
                  timeLabel: _timeLabel(last?.sentAt),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ChatConversationScreen(conversation: convo),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final ChatMessage? lastMessage;
  final String timeLabel;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.lastMessage,
    required this.timeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: AppCard(
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: SizedBox(
                width: 48,
                height: 48,
                child: conversation.isGroup
                    ? const ColoredBox(
                        color: AppColors.canvasBlue,
                        child: Icon(Icons.groups, color: AppColors.primary),
                      )
                    : NetworkPhoto.seeded(conversation.title,
                        fallbackIcon: Icons.person),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(conversation.title,
                            style: AppText.body.copyWith(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                      if (conversation.isGroup)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text('${conversation.participants.length}명',
                              style: AppText.caption),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lastMessage == null
                        ? '대화를 시작해보세요'
                        : '${lastMessage!.isMine ? '나: ' : ''}${lastMessage!.text}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(timeLabel, style: AppText.caption),
          ],
        ),
      ),
    );
  }
}
