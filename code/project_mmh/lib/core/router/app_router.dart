import 'package:go_router/go_router.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/screens/clinicas_metas_screen.dart';
import 'package:project_mmh/features/pacientes/presentation/screens/patients_screen.dart';
import 'package:project_mmh/features/pacientes/presentation/screens/add_patient_screen.dart';
import 'package:project_mmh/features/pacientes/presentation/screens/edit_patient_screen.dart';
import 'package:project_mmh/features/pacientes/domain/patient.dart';
import 'package:project_mmh/features/odontograma/presentation/screens/odontograma_screen.dart';
import 'package:project_mmh/features/agenda/presentation/screens/agenda_screen.dart';
import 'package:project_mmh/features/agenda/presentation/screens/treatments_screen.dart';
import 'package:project_mmh/features/agenda/presentation/screens/treatment_detail_screen.dart';
import 'package:project_mmh/shared/widgets/scaffold_with_navbar.dart';
import 'package:project_mmh/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:project_mmh/features/pacientes/presentation/screens/patient_detail_screen.dart';
import 'package:project_mmh/features/agenda/presentation/widgets/appointment_form.dart';
import 'package:project_mmh/features/settings/presentation/screens/settings_screen.dart';
import 'package:project_mmh/features/diagnosis/presentation/screens/diagnosis_wizard_screen.dart';

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
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return TreatmentDetailScreen(tratamientoId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        // Branch 4: Pacientes
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pacientes',
              builder: (context, state) => const PatientsScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return PatientDetailScreen(patientId: id);
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) {
                        final patient = state.extra as Patient;
                        return EditPatientScreen(patient: patient);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Branch 5: Configuración
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'clinicas-metas',
                  builder: (context, state) => const ClinicasMetasScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // ROOTS (No Navbar) - Overlays or screens that take over the full display
    GoRoute(
      path: '/treatment-create',
      builder: (context, state) => AppointmentForm(initialDate: DateTime.now()),
    ),
    GoRoute(
      path: '/patient-create',
      builder: (context, state) => const AddPatientScreen(),
    ),
    GoRoute(
      path: '/patient-odontograma/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return OdontogramaScreen(pacienteId: id);
      },
    ),
    GoRoute(
      path: '/diagnosis',
      builder: (context, state) => const DiagnosisWizardScreen(),
    ),
  ],
);
