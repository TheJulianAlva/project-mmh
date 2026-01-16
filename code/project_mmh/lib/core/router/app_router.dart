import 'package:go_router/go_router.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/screens/clinicas_metas_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/clinicas-metas', // Start here for now as per Block 2 focus
  routes: [
    GoRoute(
      path: '/clinicas-metas',
      builder: (context, state) => const ClinicasMetasScreen(),
    ),
  ],
);
