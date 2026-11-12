import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/bloc/auth_cubit.dart';
import '../../features/profile/profile_page.dart';
import '../../features/auth/getstarted_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/otp_page.dart';
import '../../features/auth/user_details_page.dart';
import '../../features/dashboard/presentation/pages/dash_board.dart';
import '../../features/manager/presentation/pages/manager_dashboard.dart';
import '../../features/manager/presentation/pages/analytics_page.dart';
import '../../features/manager/data/models/manager_filter_models.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              if (authState is AuthLoading) {
                return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))));
              }
              if (authState is AuthSuccess && !authState.isNewUser) {
                return authState.role.trim().toLowerCase() == 'manager'
                    ? const ManagerDashboardPage()
                    : const DashboardPage();
              }
              return const GetStartedPage();
            },
          );
        },
      ),
      GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
      GoRoute(path: '/dashboard', builder: (context, state) => const DashboardPage()),
      GoRoute(path: '/login', builder: (context, state) => const login_page()),
      GoRoute(
        path: '/otp',
        builder: (context, state) => otp_page(verificationId: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: '/user_details',
        builder: (context, state) => UserDetailsPage(
          existingData: state.extra as Map<String, dynamic>? ?? {},
          isEditing: false,
        ),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => AnalyticsPage(selectedGun: state.extra as GunModel),
      ),
    ],
  );
}