import 'package:go_router/go_router.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/screens/clinicas_metas_screen.dart';
import 'package:project_mmh/features/pacientes/presentation/screens/patients_screen.dart';
import 'package:project_mmh/features/pacientes/presentation/screens/add_patient_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/pacientes', // Changed to test Block 3
  routes: [
    GoRoute(
      path: '/clinicas-metas',
      builder: (context, state) => const ClinicasMetasScreen(),
    ),
    GoRoute(
      path: '/pacientes',
      builder: (context, state) => const PatientsScreen(),
      routes: [
        GoRoute(
          path: 'nuevo',
          builder: (context, state) => const AddPatientScreen(),
        ),
      ],
    ),
  ],
);
