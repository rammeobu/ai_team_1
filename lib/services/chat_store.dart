import 'package:flutter/foundation.dart';

/// 채팅 메시지 한 건.
class ChatMessage {
  final String authorName;
  final String text;
  final DateTime sentAt;
  final bool isMine;

  const ChatMessage({
    required this.authorName,
    required this.text,
    required this.sentAt,
    this.isMine = false,
  });
}

/// 대화방 메타 정보(1:1 DM 또는 여러 명이 참여하는 그룹채팅).
class ChatConversation {
  final String id;
  final String title;
  final bool isGroup;
  final List<String> participants; // 그룹채팅일 때만 사용.

  const ChatConversation({
    required this.id,
    required this.title,
    this.isGroup = false,
    this.participants = const [],
  });
}

/// 채팅 데모 스토어. 실제 서버 연동 전까지 세션 내 메모리에만 보관합니다.
/// 게시판(커뮤니티) 글 작성자에게 "채팅하기"를 누르면 여기서 DM을 찾거나 새로 만듭니다.
class ChatStore extends ChangeNotifier {
  final List<ChatConversation> _conversations = [
    const ChatConversation(
      id: 'dm_travellover',
      title: '여행러버',
    ),
    const ChatConversation(
      id: 'group_osaka',
      title: '오사카 동행 모임',
      isGroup: true,
      participants: ['나', '여행러버', '쩡', 'hj'],
    ),
    const ChatConversation(
      id: 'dm_cafeholic',
      title: '카페홀릭',
    ),
  ];

  final Map<String, List<ChatMessage>> _messages = {
    'dm_travellover': [
      ChatMessage(
        authorName: '여행러버',
        text: '오사카 3박4일 같이 가실 분 찾고 있어요!',
        sentAt: DateTime.now().subtract(const Duration(minutes: 42)),
      ),
      ChatMessage(
        authorName: '나',
        text: '안녕하세요! 저도 8월에 오사카 갈 예정이에요.',
        sentAt: DateTime.now().subtract(const Duration(minutes: 40)),
        isMine: true,
      ),
    ],
    'group_osaka': [
      ChatMessage(
        authorName: '쩡',
        text: '숙소는 난바역 근처로 예약했어요~',
        sentAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ChatMessage(
        authorName: 'hj',
        text: '좋아요! 첫날 저녁은 타코야키 골목 어때요?',
        sentAt: DateTime.now().subtract(const Duration(minutes: 50)),
      ),
    ],
    'dm_cafeholic': [
      ChatMessage(
        authorName: '카페홀릭',
        text: '통로 카페거리 후기 남겨주셔서 감사해요!',
        sentAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ],
  };

  /// 마지막 메시지 시간 기준 최신순으로 정렬된 대화방 목록.
  List<ChatConversation> get conversations {
    final list = List<ChatConversation>.from(_conversations);
    list.sort((a, b) {
      final aTime = lastMessage(a.id)?.sentAt ?? DateTime(0);
      final bTime = lastMessage(b.id)?.sentAt ?? DateTime(0);
      return bTime.compareTo(aTime);
    });
    return list;
  }

  List<ChatMessage> messagesFor(String conversationId) =>
      List.unmodifiable(_messages[conversationId] ?? const []);

  ChatMessage? lastMessage(String conversationId) {
    final msgs = _messages[conversationId];
    return (msgs == null || msgs.isEmpty) ? null : msgs.last;
  }

  Future<void> sendMessage(String conversationId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _messages
        .putIfAbsent(conversationId, () => [])
        .add(ChatMessage(
          authorName: '나',
          text: trimmed,
          sentAt: DateTime.now(),
          isMine: true,
        ));
    notifyListeners();
  }

  /// [authorName]과의 1:1 DM을 찾거나(게시판 글 작성자에게 "채팅하기"), 없으면 새로 만들고
  /// 대화방을 반환합니다.
  ChatConversation startDirectMessage(String authorName) {
    final existing = _conversations.firstWhere(
      (c) => !c.isGroup && c.title == authorName,
      orElse: () => const ChatConversation(id: '', title: ''),
    );
    if (existing.id.isNotEmpty) return existing;

    final created = ChatConversation(
      id: 'dm_${DateTime.now().microsecondsSinceEpoch}',
      title: authorName,
    );
    _conversations.add(created);
    notifyListeners();
    return created;
  }
}
