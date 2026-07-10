import 'package:flutter/foundation.dart';

/// 게시판 종류.
enum BoardType { companion, recommend, review }

extension BoardTypeLabel on BoardType {
  String get label {
    switch (this) {
      case BoardType.companion:
        return '동행 구하기';
      case BoardType.recommend:
        return '여행지 추천';
      case BoardType.review:
        return '리뷰';
    }
  }
}

/// 정렬 기준.
enum SortOption { recommended, mostLiked, leastLiked, newest }

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.recommended:
        return '추천';
      case SortOption.mostLiked:
        return '좋아요 많은순';
      case SortOption.leastLiked:
        return '좋아요 적은순';
      case SortOption.newest:
        return '최신순';
    }
  }
}

/// 게시글 댓글 한 건.
class Comment {
  final String author;
  final String text;
  final DateTime createdAt;
  const Comment({
    required this.author,
    required this.text,
    required this.createdAt,
  });
}

/// 게시판 글 한 건.
class Post {
  final String id;
  final BoardType board;
  final String author;
  final String title;
  final String body;
  final String tag;
  final DateTime createdAt;
  final bool recruiting; // companion 전용: 모집중 배지
  final double? rating; // review 전용: 별점
  final int likeCount;
  final bool likedByMe;
  final List<Comment> comments;
  final List<String> photoPaths; // review 전용: 로컬에서 고른 사진 경로

  const Post({
    required this.id,
    required this.board,
    required this.author,
    required this.title,
    required this.body,
    required this.tag,
    required this.createdAt,
    this.recruiting = false,
    this.rating,
    this.likeCount = 0,
    this.likedByMe = false,
    this.comments = const [],
    this.photoPaths = const [],
  });

  bool get isMine => author == '나';

  /// 추천순 정렬용 점수(좋아요 가중 + 댓글).
  int get score => likeCount * 2 + comments.length;

  Post copyWith({
    String? title,
    String? body,
    List<String>? photoPaths,
    int? likeCount,
    bool? likedByMe,
    List<Comment>? comments,
  }) {
    return Post(
      id: id,
      board: board,
      author: author,
      title: title ?? this.title,
      body: body ?? this.body,
      tag: tag,
      createdAt: createdAt,
      recruiting: recruiting,
      rating: rating,
      likeCount: likeCount ?? this.likeCount,
      likedByMe: likedByMe ?? this.likedByMe,
      comments: comments ?? this.comments,
      photoPaths: photoPaths ?? this.photoPaths,
    );
  }
}

/// 게시판 데모 스토어. 실제 백엔드 연동 전까지 세션 내 메모리에만 보관합니다.
class CommunityStore extends ChangeNotifier {
  int _seq = 0;

  final List<Post> _posts = [
    Post(
      id: 'seed_1',
      board: BoardType.companion,
      author: '여행러버',
      title: '오사카 3박4일 같이 가실 20대 구해요',
      body: '8월 12-15일 일정이에요. 미식 위주로 다닐 예정이고 2명 더 모집합니다!',
      tag: '오사카',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      recruiting: true,
      likeCount: 12,
      comments: [
        Comment(
            author: '쩡',
            text: '저도 관심있어요! 일정 더 알 수 있을까요?',
            createdAt: DateTime.now().subtract(const Duration(minutes: 5))),
      ],
    ),
    Post(
      id: 'seed_2',
      board: BoardType.companion,
      author: '쩡',
      title: '다낭 힐링 여행 동행 구합니다',
      body: '9월 초 리조트 쉐어해서 비용 절약해요. 편하게 쉬는 여행 원하시는 분!',
      tag: '다낭',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      recruiting: true,
      likeCount: 8,
    ),
    Post(
      id: 'seed_3',
      board: BoardType.recommend,
      author: '카페홀릭',
      title: '가성비 최고 방콕 카페거리 추천',
      body: '통로 지역 카페거리 진짜 예쁘고 커피도 저렴해요. 사진 맛집!',
      tag: '방콕',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      likeCount: 24,
      comments: [
        Comment(
            author: '단풍러',
            text: '다음 방콕 여행 때 꼭 가볼게요!',
            createdAt: DateTime.now().subtract(const Duration(minutes: 20))),
      ],
    ),
    Post(
      id: 'seed_4',
      board: BoardType.recommend,
      author: '단풍러',
      title: '교토 단풍 명소 5곳 정리',
      body: '11월 중순이 절정이에요. 아라시야마·도후쿠지 강추합니다.',
      tag: '교토',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      likeCount: 40,
    ),
    Post(
      id: 'seed_5',
      board: BoardType.review,
      author: 'hj',
      title: '오사카 시티 센트럴 호텔 후기',
      body: '난바역 도보 5분, 방 깨끗하고 조식 훌륭했어요. 가성비 최고!',
      tag: '숙소',
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      rating: 4.5,
      likeCount: 6,
    ),
    Post(
      id: 'seed_6',
      board: BoardType.review,
      author: '제주러버',
      title: '제주 게스트하우스 솔직 리뷰',
      body: '가격은 저렴한데 방음이 약했어요. 위치는 좋습니다.',
      tag: '제주',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      rating: 3.5,
      likeCount: 11,
    ),
  ];

  List<Post> postsFor(BoardType board, SortOption sort) {
    final list = _posts.where((p) => p.board == board).toList();
    switch (sort) {
      case SortOption.recommended:
        list.sort((a, b) => b.score.compareTo(a.score));
        break;
      case SortOption.mostLiked:
        list.sort((a, b) => b.likeCount.compareTo(a.likeCount));
        break;
      case SortOption.leastLiked:
        list.sort((a, b) => a.likeCount.compareTo(b.likeCount));
        break;
      case SortOption.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return list;
  }

  Post? postById(String id) {
    for (final p in _posts) {
      if (p.id == id) return p;
    }
    return null;
  }

  void addPost({
    required BoardType board,
    required String title,
    required String body,
    String tag = '여행',
    List<String> photoPaths = const [],
  }) {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return;
    _posts.insert(
      0,
      Post(
        id: 'u${DateTime.now().microsecondsSinceEpoch}_${_seq++}',
        board: board,
        author: '나',
        title: trimmedTitle,
        body: body.trim(),
        tag: board == BoardType.review ? '리뷰' : tag,
        createdAt: DateTime.now(),
        recruiting: board == BoardType.companion,
        photoPaths: photoPaths,
      ),
    );
    notifyListeners();
  }

  void updatePost(
    String id, {
    String? title,
    String? body,
    List<String>? photoPaths,
  }) {
    final idx = _posts.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    _posts[idx] = _posts[idx].copyWith(
      title: title,
      body: body,
      photoPaths: photoPaths,
    );
    notifyListeners();
  }

  void deletePost(String id) {
    _posts.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void toggleLike(String id) {
    final idx = _posts.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final post = _posts[idx];
    final liked = !post.likedByMe;
    _posts[idx] = post.copyWith(
      likedByMe: liked,
      likeCount: post.likeCount + (liked ? 1 : -1),
    );
    notifyListeners();
  }

  void addComment(String id, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final idx = _posts.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final post = _posts[idx];
    _posts[idx] = post.copyWith(
      comments: [
        ...post.comments,
        Comment(author: '나', text: trimmed, createdAt: DateTime.now()),
      ],
    );
    notifyListeners();
  }
}
