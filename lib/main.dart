import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/trip_service.dart';
import 'services/trip_store.dart';
import 'services/checklist_store.dart';
import 'services/api_config_store.dart';
import 'services/ai_config_store.dart';
import 'services/openrouter_service.dart';
import 'services/chat_store.dart';
import 'services/community_store.dart';
import 'providers/auth_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/home_provider.dart';
import 'screens/login_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/travelers_screen.dart';
import 'screens/destination_screen.dart';
import 'screens/style_screen.dart';
import 'screens/trip_summary_screen.dart';
import 'screens/home_screen.dart';
import 'screens/budget_detail_screen.dart';
import 'screens/budget_management_screen.dart';
import 'screens/my_trips_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/flight_search_screen.dart';
import 'screens/hotel_search_screen.dart';
import 'screens/documents_checklist_screen.dart';
import 'screens/community_screen.dart';
import 'screens/restaurant_screen.dart';
import 'screens/api_settings_screen.dart';
import 'screens/chat_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 예산 등 현재 여행 데이터를 앱 재실행 후에도 유지하기 위한 저장소.
  final prefs = await SharedPreferences.getInstance();

  // 실제 서버 주소. (프로필 → API 연결 설정에서 저장하면 이 값을 덮어씁니다.)
  final api = ApiService(baseUrl: 'https://api.withact.xyz');

  // AI 요약(온보딩) 전용 OpenRouter 키. 기기 보안 저장소에서 불러옵니다.
  // 키는 코드에 넣지 말고 앱 실행 후 프로필 > API 연결 설정에서 입력하세요.
  final aiConfig = AiConfigStore();
  await aiConfig.load();

  runApp(BudgetTripApp(api: api, prefs: prefs, aiConfig: aiConfig));
}

class BudgetTripApp extends StatelessWidget {
  final ApiService api;
  final SharedPreferences prefs;
  final AiConfigStore aiConfig;
  const BudgetTripApp({
    super.key,
    required this.api,
    required this.prefs,
    required this.aiConfig,
  });

  @override
  Widget build(BuildContext context) {
    // AI 요약(온보딩)과 홈 대시보드가 같은 TripService 인스턴스를 공유.
    final tripService = TripService(api, OpenRouterService(aiConfig));

    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: api),
        Provider<SharedPreferences>.value(value: prefs),
        // 백엔드 연결 설정(Base URL · API 키). 저장값을 시작 시 api 에 적용.
        ChangeNotifierProvider(
          create: (_) => ApiConfigStore(prefs, api),
        ),
        // OpenRouter(AI 요약) 키 설정. 값은 기기 보안 저장소에 저장됩니다.
        ChangeNotifierProvider.value(value: aiConfig),
        // 예산의 단일 진실 공급원. 설정 화면과 홈 카드가 함께 구독합니다.
        ChangeNotifierProvider(
          create: (_) => TripStore(prefs),
        ),
        // 여행 서류/체크리스트 저장소.
        ChangeNotifierProvider(
          create: (_) => ChecklistStore(prefs),
        ),
        // 톡(채팅) 데모 저장소. 실제 서버 연동 전까지 세션 내 메모리에만 보관.
        ChangeNotifierProvider(
          create: (_) => ChatStore(),
        ),
        // 게시판 데모 저장소(글/좋아요/댓글/사진). 실제 서버 연동 전까지 세션 내 메모리에만 보관.
        ChangeNotifierProvider(
          create: (_) => CommunityStore(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService(api)),
        ),
        ChangeNotifierProvider(
          create: (_) => OnboardingProvider(tripService),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(tripService),
        ),
      ],
      child: MaterialApp(
        title: 'Met U',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        builder: (context, child) => MobileAppShell(child: child),
        initialRoute: LoginScreen.route,
        routes: {
          LoginScreen.route: (_) => const LoginScreen(),
          BudgetScreen.route: (_) => const BudgetScreen(),
          TravelersScreen.route: (_) => const TravelersScreen(),
          DestinationScreen.route: (_) => const DestinationScreen(),
          StyleScreen.route: (_) => const StyleScreen(),
          TripSummaryScreen.route: (_) => const TripSummaryScreen(),
          HomeScreen.route: (_) => const HomeScreen(),
          BudgetDetailScreen.route: (_) => const BudgetDetailScreen(),
          BudgetManagementScreen.route: (_) => const BudgetManagementScreen(),
          MyTripsScreen.route: (_) => const MyTripsScreen(),
          ProfileScreen.route: (_) => const ProfileScreen(),
          FlightSearchScreen.route: (_) => const FlightSearchScreen(),
          HotelSearchScreen.route: (_) => const HotelSearchScreen(),
          DocumentsChecklistScreen.route: (_) =>
              const DocumentsChecklistScreen(),
          CommunityScreen.route: (_) => const CommunityScreen(),
          RestaurantScreen.route: (_) => const RestaurantScreen(),
          ApiSettingsScreen.route: (_) => const ApiSettingsScreen(),
          ChatListScreen.route: (_) => const ChatListScreen(),
        },
      ),
    );
  }
}

class MobileAppShell extends StatelessWidget {
  final Widget? child;

  const MobileAppShell({super.key, required this.child});

  static const double iphoneWidth = 393;
  static const double iphoneHeight = 852;
  static const double mobileBreakpoint = 480;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > mobileBreakpoint;
        if (!isWide) {
          return child ?? const SizedBox.shrink();
        }

        final frameHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight.clamp(640.0, iphoneHeight)
            : iphoneHeight;
        final framedChild = MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: Size(iphoneWidth, frameHeight),
          ),
          child: child ?? const SizedBox.shrink(),
        );

        return ColoredBox(
          color: AppColors.canvasBlue,
          child: Center(
            child: SizedBox(
              width: iphoneWidth,
              height: frameHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    border: Border.all(color: Colors.white, width: 6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: framedChild,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
