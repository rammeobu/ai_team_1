import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/community_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// 게시글 상세 화면. 게시판 목록에서 카드를 탭하면 진입합니다.
/// 좋아요, (동행 구하기·여행지 추천이면) 댓글, (리뷰면) 사진을 보여주고,
/// 내가 쓴 글이면 수정·삭제도 여기서 합니다.
class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  String _timeLabel(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return '방금';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  Future<void> _edit(BuildContext context, Post post) async {
    final titleCtrl = TextEditingController(text: post.title);
    final bodyCtrl = TextEditingController(text: post.body);
    final photoPaths = List<String>.from(post.photoPaths);

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
              Text('글 수정', style: AppText.h3),
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
              if (post.board == BoardType.review) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in photoPaths)
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(File(p),
                                  width: 64, height: 64, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: -8,
                              right: -8,
                              child: IconButton(
                                onPressed: () => setSheetState(
                                    () => photoPaths.remove(p)),
                                icon: const Icon(Icons.cancel,
                                    size: 18, color: AppColors.danger),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
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
                label: '저장',
                trailingIcon: Icons.check,
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        ),
      ),
    );

    if (ok == true && context.mounted && titleCtrl.text.trim().isNotEmpty) {
      context.read<CommunityStore>().updatePost(
            post.id,
            title: titleCtrl.text,
            body: bodyCtrl.text,
            photoPaths: photoPaths,
          );
    }
  }

  Future<void> _delete(BuildContext context, Post post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('게시글 삭제', style: AppText.h3),
        content: const Text('이 게시글을 삭제할까요? 되돌릴 수 없어요.', style: AppText.body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<CommunityStore>().deletePost(post.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = context.watch<CommunityStore>().postById(widget.postId);

    if (post == null) {
      return Scaffold(
        appBar: const BrandAppBar(showBack: true),
        body: const EmptyState('게시글을 찾을 수 없어요(삭제되었을 수 있어요).'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        title: Text(post.board.label, style: AppText.h3),
        actions: post.isMine
            ? [
                IconButton(
                  onPressed: () => _edit(context, post),
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.primary),
                  tooltip: '수정하기',
                ),
                IconButton(
                  onPressed: () => _delete(context, post),
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.danger),
                  tooltip: '삭제하기',
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        post.author.characters.first,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.author,
                              style: AppText.body.copyWith(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          Text(_timeLabel(post.createdAt),
                              style: AppText.caption),
                        ],
                      ),
                    ),
                    if (post.recruiting)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
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
                const SizedBox(height: 16),
                Text(post.title, style: AppText.h2),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TagChip('#${post.tag}'),
                    if (post.rating != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.star, size: 15, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text('${post.rating}',
                          style: AppText.caption
                              .copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Text(post.body, style: AppText.body),
                if (post.photoPaths.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      for (final p in post.photoPaths)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(p), fit: BoxFit.cover),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                InkWell(
                  onTap: () =>
                      context.read<CommunityStore>().toggleLike(post.id),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: (post.likedByMe
                              ? AppColors.danger
                              : AppColors.subtleText)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          post.likedByMe
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                          color: post.likedByMe
                              ? AppColors.danger
                              : AppColors.subtleText,
                        ),
                        const SizedBox(width: 6),
                        Text('좋아요 ${post.likeCount}',
                            style: AppText.label.copyWith(
                              color: post.likedByMe
                                  ? AppColors.danger
                                  : AppColors.bodyText,
                            )),
                      ],
                    ),
                  ),
                ),
                if (post.board != BoardType.review) ...[
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.track),
                  const SizedBox(height: 12),
                  Text('댓글 ${post.comments.length}', style: AppText.h3),
                  const SizedBox(height: 12),
                  for (final c in post.comments)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(c.author,
                                  style: AppText.label
                                      .copyWith(color: AppColors.ink)),
                              const SizedBox(width: 6),
                              Text(_timeLabel(c.createdAt),
                                  style: AppText.caption),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(c.text, style: AppText.body),
                        ],
                      ),
                    ),
                  if (post.comments.isEmpty)
                    Text('첫 댓글을 남겨보세요.',
                        style: AppText.caption
                            .copyWith(color: AppColors.subtleText)),
                ],
              ],
            ),
          ),
          if (post.board != BoardType.review)
            _CommentInputBar(
              controller: _commentCtrl,
              onSend: () {
                context.read<CommunityStore>().addComment(
                    post.id, _commentCtrl.text);
                _commentCtrl.clear();
              },
            ),
        ],
      ),
    );
  }
}

class _CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _CommentInputBar({required this.controller, required this.onSend});

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
                  hintText: '댓글을 남겨보세요',
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
