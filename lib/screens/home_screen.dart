import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../services/trip_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'flight_search_screen.dart';
import 'hotel_search_screen.dart';
import 'documents_checklist_screen.dart';
import 'community_screen.dart';
import 'restaurant_screen.dart';
import 'budget_detail_screen.dart';
import 'chat_list_screen.dart';
import 'my_trips_screen.dart';
import 'profile_screen.dart';
import 'budget_screen.dart';

/// 홈 대시보드.
class HomeScreen extends StatefulWidget {
  static const route = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _won = NumberFormat.decimalPattern('ko');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final user = context.watch<AuthProvider>().user;
    final trip = context.watch<TripStore>();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: AppColors.canvas,
        toolbarHeight: 64,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: const [
            BrandLogoMark(size: 24),
            SizedBox(width: 8),
            Text('Met U', style: AppText.logo),
          ],
        ),
        actions: const [
          Icon(Icons.notifications_none, color: AppColors.bodyText),
          SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<HomeProvider>().load(),
        child: home.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Text('안녕하세요 ${user?.name ?? 'ㅇㅇ'}님,\n다음 여행은 어디로 떠날까요?',
                      style: AppText.h1),
                  const SizedBox(height: 24),
                  if (home.error != null) ...[
                    InfoBadge(
                      icon: Icons.error_outline,
                      iconColor: AppColors.danger,
                      background: AppColors.danger.withOpacity(0.08),
                      title: '데이터를 불러오지 못했어요',
                      body: home.error,
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (trip.hasTrip) _ActiveTripCard(trip: trip, won: _won),
                  const SizedBox(height: 24),
                  _quickActions(),
                  const SizedBox(height: 24),
                  const Text('예산별 AI 추천 여행지', style: AppText.h3),
                  const SizedBox(height: 16),
                  _recommendGrid(home.themes),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(BudgetScreen.route),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _quickActions() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text('AI 스마트 팁', style: AppText.h3),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _quickTile(Icons.flight, '항공권',
                  onTap: () => Navigator.of(context)
                      .pushNamed(FlightSearchScreen.route)),
              _quickTile(Icons.hotel, '숙소',
                  onTap: () =>
                      Navigator.of(context).pushNamed(HotelSearchScreen.route)),
              _quickTile(Icons.restaurant, '맛집',
                  onTap: () =>
                      Navigator.of(context).pushNamed(RestaurantScreen.route)),
              _quickTile(Icons.description_outlined, '서류',
                  onTap: () => Navigator.of(context)
                      .pushNamed(DocumentsChecklistScreen.route)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickTile(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: AppText.label.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              )),
        ],
      ),
    );
  }

  Widget _recommendGrid(List<RecommendedTheme> themes) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: themes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (_, i) => _ThemeCard(theme: themes[i]),
    );
  }

  Widget _bottomNav() {
    // 아이콘(20) + 간격(4) + 라벨(약 16) + 세로 패딩(6*2)의 실제 필요 높이에
    // 여유를 두고, 기기별 하단 안전영역(제스처 내비게이션 바 등)만큼 더해줍니다.
    // 이 값을 반영하지 않고 고정 높이만 쓰면 기기에 따라 내용이 넘칠 수 있습니다.
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const contentHeight = 58.0;
    final barHeight = contentHeight + bottomInset;

    return SizedBox(
      height: barHeight + 16, // 가운데 홈 버튼이 위로 튀어나올 여유
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // 하단 바 (좌: 내 여행·게시판, 우: 톡·내정보)
          Container(
            height: barHeight,
            padding: EdgeInsets.only(bottom: bottomInset),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              boxShadow: AppShadow.card,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _navTab(
                            Icons.card_travel, '내 여행', MyTripsScreen.route),
                        _navTab(Icons.forum_outlined, '게시판',
                            CommunityScreen.route),
                      ],
                    ),
                  ),
                  const SizedBox(width: 64), // 가운데 홈 버튼 자리
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _navTab(Icons.chat_bubble_outline, '톡',
                            ChatListScreen.route),
                        _navTab(Icons.person, '내정보', ProfileScreen.route),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 가운데 돌출 원형 홈 버튼
          Positioned(top: 0, child: _homeButton()),
        ],
      ),
    );
  }

  /// 현재 화면이 이미 홈이므로 탭 동작 없이 표시만 합니다.
  Widget _homeButton() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.home, color: Colors.white, size: 26),
    );
  }

  Widget _navTab(IconData icon, String label, String route) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(route),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppColors.bodyText),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bodyText,
                )),
          ],
        ),
      ),
    );
  }
}

class _ActiveTripCard extends StatelessWidget {
  final TripStore trip;
  final NumberFormat won;
  const _ActiveTripCard({required this.trip, required this.won});

  @override
  Widget build(BuildContext context) {
    // 예산 값은 모두 TripStore(단일 진실 공급원)에서 파생됩니다.
    final used = trip.usedBudget;
    final total = trip.totalBudget;
    final remaining = trip.remaining;
    final percent = trip.progressPercent;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.check_circle, size: 15, color: AppColors.success),
              SizedBox(width: 8),
              Text('진행 중인 여행',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  )),
            ],
          ),
          const SizedBox(height: 4),
          Text(trip.title, style: AppText.h3),
          const SizedBox(height: 4),
          Text(trip.dateRange, style: AppText.body.copyWith(fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('사용 예산', style: AppText.body.copyWith(fontSize: 14)),
              Text('${won.format(used)} / ${won.format(total)}원',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.ink,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: trip.progress,
              minHeight: 8,
              backgroundColor: AppColors.trackAlt,
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$percent% 사용', style: AppText.caption),
              Text('잔여 ${won.format(remaining)}원', style: AppText.caption),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(BudgetDetailScreen.route),
              child: Text('자세히 보기',
                  style: AppText.label.copyWith(color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final RecommendedTheme theme;
  const _ThemeCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFC97A4A), Color(0xFF3E2A22)],
        ),
        boxShadow: AppShadow.card,
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(theme.title,
                    style: AppText.label.copyWith(color: Colors.white)),
                const SizedBox(height: 3),
                Text(theme.subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.8),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
