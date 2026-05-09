import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main_shell.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/dashboard/presentation/splash_screen.dart';
import '../features/dashboard/presentation/onboarding_screen.dart';
import '../features/dashboard/presentation/permission_setup_screen.dart';
import '../features/dashboard/presentation/calendar_screen.dart';
import '../features/dashboard/presentation/timeline_screen.dart';
import '../features/dashboard/presentation/stats_screen.dart';
import '../features/dashboard/presentation/archive_screen.dart';
import '../features/promises/presentation/promises_screen.dart';
import '../features/promises/presentation/add_promise_screen.dart';
import '../features/promises/presentation/promise_detail_screen.dart';
import '../features/promises/presentation/promise_provider.dart';
import '../features/borrow/presentation/borrow_screen.dart';
import '../features/borrow/presentation/add_item_screen.dart';
import '../features/borrow/presentation/borrow_item_detail_screen.dart';
import '../features/borrow/presentation/item_provider.dart';
import '../features/money/presentation/money_screen.dart';
import '../features/money/presentation/add_money_record_screen.dart';
import '../features/money/presentation/money_record_detail_screen.dart';
import '../features/money/presentation/money_provider.dart';
import '../features/people/presentation/people_screen.dart';
import '../features/people/presentation/add_person_screen.dart';
import '../features/people/presentation/person_detail_screen.dart';
import '../features/people/presentation/person_provider.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/permissions',
      builder: (context, state) => const PermissionSetupScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/timeline',
          builder: (context, state) => const TimelineScreen(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const StatsScreen(),
        ),
        GoRoute(
          path: '/archive',
          builder: (context, state) => const ArchiveScreen(),
        ),
        GoRoute(
          path: '/promises',
          builder: (context, state) => const PromisesScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const AddPromiseScreen(),
            ),
            GoRoute(
              path: 'edit/:id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return Consumer(
                  builder: (context, ref, _) {
                    final promiseAsync = ref.watch(promiseDetailProvider(id));
                    return promiseAsync.when(
                      data: (promise) => AddPromiseScreen(promise: promise),
                      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
                      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
                    );
                  },
                );
              },
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => PromiseDetailScreen(
                id: int.parse(state.pathParameters['id']!),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/borrow',
          builder: (context, state) => const BorrowScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const AddItemScreen(),
            ),
            GoRoute(
              path: 'edit/:id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return Consumer(
                  builder: (context, ref, _) {
                    final itemAsync = ref.watch(borrowItemDetailProvider(id));
                    return itemAsync.when(
                      data: (item) => AddItemScreen(item: item),
                      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
                      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
                    );
                  },
                );
              },
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => BorrowItemDetailScreen(
                id: int.parse(state.pathParameters['id']!),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/money',
          builder: (context, state) => const MoneyScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const AddMoneyRecordScreen(),
            ),
            GoRoute(
              path: 'edit/:id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return Consumer(
                  builder: (context, ref, _) {
                    final recordAsync = ref.watch(moneyRecordDetailProvider(id));
                    return recordAsync.when(
                      data: (record) => AddMoneyRecordScreen(record: record),
                      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
                      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
                    );
                  },
                );
              },
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => MoneyRecordDetailScreen(
                id: int.parse(state.pathParameters['id']!),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/people',
          builder: (context, state) => const PeopleScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const AddPersonScreen(),
            ),
            GoRoute(
              path: 'edit/:id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return Consumer(
                  builder: (context, ref, _) {
                    final personAsync = ref.watch(personDetailProvider(id));
                    return personAsync.when(
                      data: (person) => AddPersonScreen(person: person),
                      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
                      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
                    );
                  },
                );
              },
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => PersonDetailScreen(
                id: int.parse(state.pathParameters['id']!),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
