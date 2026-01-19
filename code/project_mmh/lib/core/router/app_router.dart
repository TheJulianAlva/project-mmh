import 'package:go_router/go_router.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/screens/clinicas_metas_screen.dart';
import 'package:project_mmh/features/pacientes/presentation/screens/patients_screen.dart';
import 'package:project_mmh/features/pacientes/presentation/screens/add_patient_screen.dart';
import 'package:project_mmh/features/odontograma/presentation/screens/odontograma_screen.dart';
import 'package:project_mmh/features/agenda/presentation/screens/agenda_screen.dart';
import 'package:project_mmh/features/agenda/presentation/screens/treatments_screen.dart';
import 'package:project_mmh/shared/widgets/scaffold_with_navbar.dart';
import 'package:project_mmh/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:project_mmh/features/pacientes/presentation/screens/patient_detail_screen.dart';
import 'package:project_mmh/features/agenda/presentation/widgets/appointment_form.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Branch 1: Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        // Branch 2: Agenda
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/agenda',
              builder: (context, state) => const AgendaScreen(),
            ),
          ],
        ),
        // Branch 3: Tratamientos
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tratamientos',
              builder: (context, state) {
                final patientId = state.uri.queryParameters['patientId'];
                return TreatmentsScreen(initialPatientId: patientId);
              },
            ),
          ],
        ),
        // Branch 4: Pacientes
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pacientes',
              builder: (context, state) => const PatientsScreen(),
            ),
          ],
        ),
        // Branch 5: Configuración (Clinicas y Metas)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/clinicas-metas',
              builder: (context, state) => const ClinicasMetasScreen(),
            ),
          ],
        ),
      ],
    ),
    // ROOTS (No Navbar)
    GoRoute(
      path: '/tratamientos/new',
      builder: (context, state) => AppointmentForm(initialDate: DateTime.now()),
    ),
    GoRoute(
      path: '/pacientes/nuevo',
      builder: (context, state) => const AddPatientScreen(),
    ),
    GoRoute(
      path: '/pacientes/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PatientDetailScreen(patientId: id);
      },
      routes: [
        GoRoute(
          path: 'odontograma',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return OdontogramaScreen(pacienteId: id);
          },
        ),
      ],
    ),
  ],
);
