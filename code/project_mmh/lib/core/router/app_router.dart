import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/screens/clinicas_metas_screen.dart';
import 'package:project_mmh/features/pacientes/presentation/screens/patients_screen.dart';
import 'package:project_mmh/features/pacientes/presentation/screens/add_patient_screen.dart';
import 'package:project_mmh/features/pacientes/presentation/screens/edit_patient_screen.dart';
import 'package:project_mmh/features/odontograma/presentation/screens/odontograma_screen.dart';
import 'package:project_mmh/features/agenda/presentation/screens/agenda_screen.dart';
import 'package:project_mmh/features/agenda/presentation/screens/treatments_screen.dart';
import 'package:project_mmh/features/agenda/presentation/screens/treatment_detail_screen.dart';
import 'package:project_mmh/shared/widgets/scaffold_with_navbar.dart';
import 'package:project_mmh/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:project_mmh/features/pacientes/presentation/screens/patient_detail_screen.dart';
import 'package:project_mmh/features/agenda/presentation/screens/appointment_create_screen.dart';
import 'package:project_mmh/features/settings/presentation/screens/settings_screen.dart';
import 'package:project_mmh/features/settings/presentation/screens/reminders_settings_screen.dart';
import 'package:project_mmh/features/diagnosis/presentation/screens/diagnosis_wizard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  debugLogDiagnostics: kDebugMode,
  errorBuilder: (context, state) => _RouteErrorScreen(error: state.error),
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
                    final id = int.tryParse(state.pathParameters['id'] ?? '');
                    if (id == null) {
                      return const _RouteErrorScreen(
                        message: 'Tratamiento no válido',
                      );
                    }
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
                      builder: (context, state) => EditPatientScreen(
                        patientId: state.pathParameters['id']!,
                      ),
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
                GoRoute(
                  path: 'recordatorios',
                  builder: (context, state) => const RemindersSettingsScreen(),
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
      builder: (context, state) => const AppointmentCreateScreen(),
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

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen({this.error, this.message});

  final Exception? error;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Klinik')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                message ?? 'No se encontró la pantalla solicitada.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (kDebugMode && error != null) ...[
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
