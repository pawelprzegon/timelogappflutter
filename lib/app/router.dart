import 'package:go_router/go_router.dart';
import '../features/home/ui/home_screen.dart';
import '../features/admin/ui/admin_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_,__) => const HomeScreen()),
    GoRoute(path: '/admin', builder: (_,__) => const AdminScreen()),
  ],
);