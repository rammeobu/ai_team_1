import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/community_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'post_detail_screen.dart';

/// 게시판 — 여행 커뮤니티.
/// 하단 네비게이션의 "게시판" 탭에서 진입합니다.
/// 게시판 3종: 동행 구하기 · 여행지 추천 · 리뷰.
class CommunityScreen extends StatefulWidget {
  static const route = '/community';
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  static const _boards = BoardType.values;

  // 게시판(탭)마다 독립적인 정렬 상태.
  final Map<BoardType, SortOption> _sorts = {
    for (final b in BoardType.values) b: SortOption.recommended,
  };

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _boards.length, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _compose() async {
    final board = _boards[_tab.index];
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final photoPaths = <String>[];

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${board.label} 글쓰기', style: AppText.h3),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: '제목'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '내용',
                  alignLabelWithHint: true,
                ),
              ),
              if (board == BoardType.review) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in photoPaths)
                      _PhotoThumb(
                        path: p,
                        onRemove: () =>
                            setSheetState(() => photoPaths.remove(p)),
                      ),
                    InkWell(
                      onTap: () async {
                        final res = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: true,
                        );
                        if (res == null) return;
                        setSheetState(() => photoPaths.addAll(
                            res.files.map((f) => f.path).whereType<String>()));
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add_a_photo_outlined,
                            color: AppColors.subtleText),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              PrimaryButton(
                label: '등록',
                trailingIcon: Icons.send,
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        ),
      ),
    );

    if (ok == true && titleCtrl.text.trim().isNotEmpty && mounted) {
      context.read<CommunityStore>().addPost(
            board: board,
            title: titleCtrl.text,
            body: bodyCtrl.text,
            photoPaths: photoPaths,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글이 등록되었어요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        toolbarHeight: 64,
        titleSpacing: 16,
        title: Row(
          children: [
            const Icon(Icons.forum_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('게시판', style: AppText.logo),
          ],
        ),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.subtleText,
          indicatorColor: AppColors.primary,
          labelStyle: AppText.label,
          tabs: [for (final b in _boards) Tab(text: b.label)],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _compose,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: Text('글쓰기', style: AppText.label.copyWith(color: Colors.white)),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          for (final b in _boards)
            _BoardView(
              board: b,
              sort: _sorts[b]!,
              onSortChanged: (s) => setState(() => _sorts[b] = s),
            ),
        ],
      ),
    );
  }
}

class _BoardView extends StatelessWidget {
  final BoardType board;
  final SortOption sort;
  final ValueChanged<SortOption> onSortChanged;
  const _BoardView({
    required this.board,
    required this.sort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<CommunityStore>().postsFor(board, sort);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: SortOption.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final option = SortOption.values[i];
                final active = option == sort;
                return ChoiceChip(
                  label: Text(option.label),
                  selected: active,
                  showCheckmark: false,
                  onSelected: (_) => onSortChanged(option),
                  labelStyle: AppText.caption.copyWith(
                    color: active ? Colors.white : AppColors.bodyText,
                    fontWeight: FontWeight.w600,
                  ),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    side: const BorderSide(color: AppColors.border),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: posts.isEmpty
              ? const EmptyState('아직 게시글이 없어요.')
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _PostCard(post: posts[i]),
                ),
        ),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  const _PostCard({required this.post});

  String _timeLabel(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return '방금';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.id)),
      ),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 작성자
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    post.author.characters.first,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(post.author,
                    style: AppText.body
                        .copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(width: 6),
                Text('· ${_timeLabel(post.createdAt)}', style: AppText.caption),
                const Spacer(),
                if (post.recruiting)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text('모집중',
                        style: AppText.caption
                            .copyWith(color: AppColors.success)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // 제목
            Row(
              children: [
                Expanded(
                  child: Text(post.title,
                      style: AppText.body.copyWith(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                if (post.rating != null) ...[
                  const Icon(Icons.star, size: 15, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text('${post.rating}',
                      style: AppText.caption
                          .copyWith(fontWeight: FontWeight.w600)),
                ],
              ],
            ),
            if (post.body.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(post.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body
                      .copyWith(fontSize: 14, color: AppColors.bodyText)),
            ],
            if (post.photoPaths.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.photoPaths.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(post.photoPaths[i]),
                        width: 64, height: 64, fit: BoxFit.cover),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                TagChip('#${post.tag}'),
                const Spacer(),
                InkWell(
                  onTap: () =>
                      context.read<CommunityStore>().toggleLike(post.id),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          post.likedByMe
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 16,
                          color: post.likedByMe
                              ? AppColors.danger
                              : AppColors.subtleText,
                        ),
                        const SizedBox(width: 4),
                        Text('${post.likeCount}', style: AppText.caption),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.chat_bubble_outline,
                    size: 16, color: AppColors.subtleText),
                const SizedBox(width: 4),
                Text('${post.comments.length}', style: AppText.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;
  const _PhotoThumb({required this.path, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(File(path),
                width: 64, height: 64, fit: BoxFit.cover),
          ),
          Positioned(
            top: -8,
            right: -8,
            child: IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.cancel,
                  size: 18, color: AppColors.danger),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}
