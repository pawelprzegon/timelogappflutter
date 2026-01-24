import 'package:go_router/go_router.dart';
import 'package:timelogappflutter/features/logging/ui/logger_screen.dart';
import '../features/admin/ui/admin_rfid_writer_screen.dart';
import '../features/home/ui/home_screen.dart';
import '../features/admin/ui/admin_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_,__) => const HomeScreen()),
    GoRoute(path: '/admin', builder: (_,__) => const AdminScreen()),
    GoRoute(path: '/logger', builder: (_,__) => const LogsScreen()),
    GoRoute(path: '/rfid-writer', builder: (_,__) => const RfidWriterScreen()),
  ],
);