import 'package:flutter/material.dart';
import 'package:project_mmh/core/constants/app_constants.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_date_time_sheet.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/presentation/widgets/app_selection_sheet.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:project_mmh/features/agenda/domain/estado_asistencia.dart';
import 'package:project_mmh/features/agenda/domain/estado_tratamiento.dart';
import 'package:project_mmh/features/agenda/domain/sesion.dart';
import 'package:project_mmh/features/agenda/domain/tratamiento.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:project_mmh/features/pacientes/domain/patient.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/objetivos_providers.dart'
    as obj_prov;
import 'package:project_mmh/features/core/presentation/providers/preferences_provider.dart';
import 'package:project_mmh/features/clinicas_metas/domain/clinica.dart';
import 'package:project_mmh/features/clinicas_metas/domain/periodo.dart';
import 'package:project_mmh/features/clinicas_metas/domain/objetivo.dart';

class AppointmentCreateScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  final String? initialPatientId;
  final int? initialClinicId;

  const AppointmentCreateScreen({
    super.key,
    this.initialDate,
    this.initialPatientId,
    this.initialClinicId,
  });

  @override
  ConsumerState<AppointmentCreateScreen> createState() =>
      _AppointmentCreateScreenState();
}

class _AppointmentCreateScreenState
    extends ConsumerState<AppointmentCreateScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  int? _selectedClinicaId;
  int? _selectedPeriodId;
  String? _selectedPatientId;
  Patient? _selectedPatient;
  bool _isSaving = false;

  // Sesiones adicionales con clave estable (no depende del índice en la lista).
  final List<_SessionDraft> _additionalSessions = [];
  int _sessionKeyCounter = 0;

  // Tratamientos a registrar en este mismo formulario. Comparten paciente,
  // periodo, clínica y planificación de sesiones; se diferencian en nombre y
  // objetivo. Siempre hay al menos uno.
  final List<_TreatmentDraft> _treatments = [];
  int _treatmentKeyCounter = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialPatientId != null) {
      _selectedPatientId = widget.initialPatientId;
    }
    _selectedPeriodId = ref.read(lastViewedPeriodIdProvider);
    if (widget.initialClinicId != null) {
      _selectedClinicaId = widget.initialClinicId;
    }
    _treatments.add(_TreatmentDraft(key: _treatmentKeyCounter++));
  }

  @override
  void dispose() {
    for (final t in _treatments) {
      t.nombre.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Si no hay periodo previo guardado, seleccionar el primero disponible en
    // cuanto la lista esté cargada (funciona tanto si ya estaba en caché como
    // si llega de forma asíncrona).
    final periodosDisponibles =
        ref.watch(periodosProvider).valueOrNull ?? const [];
    if (_selectedPeriodId == null && periodosDisponibles.isNotEmpty) {
      _selectedPeriodId = periodosDisponibles.first.idPeriodo;
    }

    return AppScaffold(
      title: 'Nuevo Tratamiento',
      actions: [
        AppButton.text(
          label: 'Guardar',
          loading: _isSaving,
          onPressed: _saveAppointment,
        ),
      ],
      slivers: [
        SliverToBoxAdapter(
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ─── SECTION 1: QUIÉN & CUÁNDO (PACIENTE & PERIODO) ───
                _buildSectionHeader(context, 'INFORMACIÓN BÁSICA'),
                _buildGroupedSection(
                  context,
                  children: [
                    // Paciente Selector
                    _buildSelectorRow(
                      context,
                      label: 'Paciente',
                      value:
                          _selectedPatient != null
                              ? '${_selectedPatient!.nombre} ${_selectedPatient!.primerApellido}'
                              : _selectedPatientId ?? 'Seleccionar',
                      isPlaceholder:
                          _selectedPatient == null &&
                          _selectedPatientId == null,
                      icon: CupertinoIcons.person_fill,
                      onTap: () => _showPatientPicker(context, patientsAsync),
                    ),
                    _buildDivider(context),
                    // Periodo Selector
                    Consumer(
                      builder: (context, ref, _) {
                        final periodosAsync = ref.watch(periodosProvider);
                        return periodosAsync.when(
                          data: (periodos) {
                            final selected = periodos.firstWhere(
                              (p) => p.idPeriodo == _selectedPeriodId,
                              orElse:
                                  () =>
                                      periodos.isNotEmpty
                                          ? periodos.first
                                          : const Periodo(
                                            nombrePeriodo: 'Sin Periodos',
                                          ),
                            );
                            return _buildSelectorRow(
                              context,
                              label: 'Periodo',
                              value: selected.nombrePeriodo,
                              icon: CupertinoIcons.calendar,
                              onTap: () => _showPeriodPicker(context, periodos),
                            );
                          },
                          loading:
                              () => _buildLoadingRow(
                                context,
                                'Cargando periodos...',
                              ),
                          error:
                              (_, __) =>
                                  _buildErrorRow(context, 'Error en periodos'),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ─── SECTION 2: DÓNDE & QUÉ (CLÍNICA & TRATAMIENTO) ───
                _buildSectionHeader(context, 'TRATAMIENTO'),
                if (_selectedPeriodId != null)
                  Consumer(
                    builder: (context, ref, _) {
                      final clinicasAsync = ref.watch(
                        clinicasByPeriodoProvider(_selectedPeriodId!),
                      );
                      return clinicasAsync.when(
                        data: (clinicas) {
                          // Auto-select if only one or if null
                          if (_selectedClinicaId == null &&
                              clinicas.isNotEmpty) {
                            // Avoid state update during build - handle in logic or just display placeholder
                          }

                          final displayValue =
                              _selectedClinicaId != null
                                  ? clinicas
                                      .firstWhere(
                                        (c) =>
                                            c.idClinica == _selectedClinicaId,
                                        orElse: () => clinicas.first,
                                      )
                                      .nombreClinica
                                  : 'Seleccionar Clínica';

                          return Column(
                            children: [
                              _buildGroupedSection(
                                context,
                                children: [
                                  _buildSelectorRow(
                                    context,
                                    label: 'Clínica',
                                    value: displayValue,
                                    isPlaceholder: _selectedClinicaId == null,
                                    icon: CupertinoIcons.building_2_fill,
                                    onTap:
                                        () => _showClinicPicker(
                                          context,
                                          clinicas,
                                        ),
                                  ),
                                ],
                              ),
                              // Lista de tratamientos a registrar.
                              if (_selectedClinicaId != null) ...[
                                Consumer(
                                  builder: (context, ref, _) {
                                    final objetivosAsync = ref.watch(
                                      obj_prov.objetivosByClinicaProvider(
                                        _selectedClinicaId!,
                                      ),
                                    );
                                    return objetivosAsync.when(
                                      data:
                                          (objetivos) =>
                                              _buildTreatmentsList(
                                                context,
                                                objetivos,
                                              ),
                                      loading:
                                          () => Padding(
                                            padding: const EdgeInsets.only(
                                              top: 12,
                                            ),
                                            child: _buildGroupedSection(
                                              context,
                                              children: [
                                                _buildLoadingRow(
                                                  context,
                                                  'Cargando objetivos...',
                                                ),
                                              ],
                                            ),
                                          ),
                                      error:
                                          (_, __) => Padding(
                                            padding: const EdgeInsets.only(
                                              top: 12,
                                            ),
                                            child: _buildGroupedSection(
                                              context,
                                              children: [
                                                _buildErrorRow(
                                                  context,
                                                  'Error al cargar objetivos',
                                                ),
                                              ],
                                            ),
                                          ),
                                    );
                                  },
                                ),
                              ] else ...[
                                const SizedBox(height: 12),
                                _buildGroupedSection(
                                  context,
                                  children: [
                                    _buildDisabledRow(
                                      context,
                                      'Seleccione una clínica primero',
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          );
                        },
                        loading:
                            () => _buildGroupedSection(
                              context,
                              children: [
                                _buildLoadingRow(
                                  context,
                                  'Cargando clínicas...',
                                ),
                              ],
                            ),
                        error:
                            (_, __) => _buildGroupedSection(
                              context,
                              children: [
                                _buildErrorRow(
                                  context,
                                  'Error al cargar clínicas',
                                ),
                              ],
                            ),
                      );
                    },
                  ),

                const SizedBox(height: 24),

                // ─── SECTION 3: PROGRAMACIÓN (SESIONES) ───
                _buildSectionHeader(context, 'PLANIFICACIÓN'),

                _buildGroupedSection(
                  context,
                  children: [
                    // Session 1 Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      color: Theme.of(context).colorScheme.surface,
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.clock_fill,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Sesión Inicial',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(context),
                    // Date & Time Picker
                    // We need a custom row that opens a date picker
                    FormBuilderField<DateTime>(
                      name: 'fecha_inicio',
                      initialValue: widget.initialDate ?? DateTime.now(),
                      builder: (field) {
                        return _buildLinkRow(
                          context,
                          label: 'Empieza',
                          value: DateFormat(
                            'EEE, d MMM yyyy  HH:mm',
                            'es_ES',
                          ).format(field.value ?? DateTime.now()),
                          onTap: () => _showDateTimePicker(context, field),
                        );
                      },
                    ),
                    _buildDivider(context),
                    FormBuilderField<DateTime>(
                      name: 'fecha_fin',
                      initialValue: (widget.initialDate ?? DateTime.now()).add(
                        const Duration(hours: 1),
                      ),
                      builder: (field) {
                        return _buildLinkRow(
                          context,
                          label: 'Termina',
                          value: DateFormat(
                            'EEE, d MMM yyyy  HH:mm',
                            'es_ES',
                          ).format(field.value ?? DateTime.now()),
                          onTap: () => _showDateTimePicker(context, field),
                        );
                      },
                    ),
                  ],
                ),

                // Additional Sessions
                if (_additionalSessions.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'SESIONES ADICIONALES'),
                  ..._additionalSessions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final draft = entry.value;
                    return Padding(
                      key: ValueKey(draft.key),
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildGroupedSection(
                        context,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sesión ${index + 2}',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _additionalSessions.remove(draft);
                                    });
                                  },
                                  child: Icon(
                                    CupertinoIcons.trash,
                                    color: colorScheme.error,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildDivider(context),
                          _buildLinkRow(
                            context,
                            label: 'Empieza',
                            value: DateFormat(
                              'EEE, d MMM HH:mm',
                              'es_ES',
                            ).format(draft.inicio),
                            onTap:
                                () => _pickDraftDate(
                                  draft.inicio,
                                  (val) => setState(() {
                                    draft.inicio = val;
                                    if (!draft.fin.isAfter(val)) {
                                      draft.fin = val.add(
                                        kDuracionSesionDefault,
                                      );
                                    }
                                  }),
                                ),
                          ),
                          _buildDivider(context),
                          _buildLinkRow(
                            context,
                            label: 'Termina',
                            value: DateFormat(
                              'EEE, d MMM HH:mm',
                              'es_ES',
                            ).format(draft.fin),
                            onTap:
                                () => _pickDraftDate(
                                  draft.fin,
                                  (val) => setState(() => draft.fin = val),
                                ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: AppButton.primary(
                      icon: CupertinoIcons.add,
                      label: 'Agregar Sesión',
                      onPressed: () {
                        // Límite: 1 sesión inicial + adicionales.
                        if (1 + _additionalSessions.length >=
                            kMaxSesionesPorTratamiento) {
                          showCupertinoDialog(
                            context: context,
                            builder:
                                (ctx) => CupertinoAlertDialog(
                                  title: const Text('Límite Alcanzado'),
                                  content: const Text(
                                    'No se pueden agregar más de $kMaxSesionesPorTratamiento '
                                    'sesiones a un tratamiento.',
                                  ),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text('OK'),
                                      onPressed: () => Navigator.pop(ctx),
                                    ),
                                  ],
                                ),
                          );
                          return;
                        }

                        setState(() {
                          final base =
                              _additionalSessions.isNotEmpty
                                  ? _additionalSessions.last.inicio
                                  : (_formKey
                                              .currentState
                                              ?.fields['fecha_inicio']
                                              ?.value
                                          as DateTime? ??
                                      widget.initialDate ??
                                      DateTime.now());
                          final inicio = base.add(const Duration(days: 7));
                          _additionalSessions.add(
                            _SessionDraft(
                              key: _sessionKeyCounter++,
                              inicio: inicio,
                              fin: inicio.add(kDuracionSesionDefault),
                            ),
                          );
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── WIDGET BUILDERS ───

  Widget _buildSectionHeader(BuildContext context, String title) {
    return AppSectionHeader(
      title,
      padding: const EdgeInsets.only(
        left: AppSpacing.xl,
        bottom: AppSpacing.sm,
      ),
    );
  }

  Widget _buildGroupedSection(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10), // iOS style radius
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 50, // Indent to match icon alignment
      color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
    );
  }

  Widget _buildSelectorRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    bool isPlaceholder = false,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    isPlaceholder
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              CupertinoIcons.chevron_up_chevron_down,
              size: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkRow(
    BuildContext context, {
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Indent purely with space to align with icon rows
            const SizedBox(width: 34),
            Text(label, style: theme.textTheme.bodyLarge),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary, // iOS DatePicker style blue
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fila con el campo de nombre de un tratamiento, ligada al controller del
  /// borrador (`draft`). Se gestiona fuera de `FormBuilder` porque la lista de
  /// tratamientos es dinámica (mismo enfoque que `_SessionDraft`).
  Widget _buildNameFieldRow(BuildContext context, _TreatmentDraft draft) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.doc_text_fill,
            color: theme.colorScheme.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text('Nombre', style: theme.textTheme.bodyLarge),
          ),
          Expanded(
            child: TextField(
              controller: draft.nombre,
              textAlign: TextAlign.end,
              maxLength: kMaxNombreTratamiento,
              decoration: InputDecoration(
                hintText: 'Ej. Endodoncia',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero,
                fillColor: Colors.transparent,
              ),
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  /// Lista dinámica de tratamientos a registrar (nombre + objetivo), todos
  /// compartiendo paciente, periodo, clínica y planificación de sesiones.
  Widget _buildTreatmentsList(
    BuildContext context,
    List<Objetivo> objetivos,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ..._treatments.asMap().entries.map((entry) {
          final index = entry.key;
          final draft = entry.value;
          return Padding(
            key: ValueKey(draft.key),
            padding: const EdgeInsets.only(top: 12),
            child: _buildGroupedSection(
              context,
              children: [
                if (_treatments.length > 1) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tratamiento ${index + 1}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (index > 0)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _treatments.remove(draft);
                                draft.nombre.dispose();
                              });
                            },
                            child: Icon(
                              CupertinoIcons.trash,
                              color: theme.colorScheme.error,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildDivider(context),
                ],
                _buildSelectorRow(
                  context,
                  label: 'Objetivo',
                  value:
                      draft.objetivo?.nombreTratamiento ??
                      'Ninguno (Personalizado)',
                  icon: CupertinoIcons.scope,
                  onTap: () => _showObjetivoPicker(context, objetivos, draft),
                ),
                _buildDivider(context),
                _buildNameFieldRow(context, draft),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: SizedBox(
            width: double.infinity,
            child: AppButton.primary(
              icon: CupertinoIcons.add,
              label: 'Agregar otro tratamiento',
              onPressed: () {
                if (_treatments.length >= kMaxTratamientosPorRegistro) {
                  showCupertinoDialog(
                    context: context,
                    builder:
                        (ctx) => CupertinoAlertDialog(
                          title: const Text('Límite Alcanzado'),
                          content: const Text(
                            'No se pueden registrar más de '
                            '$kMaxTratamientosPorRegistro tratamientos a la vez.',
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('OK'),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                  );
                  return;
                }
                setState(() {
                  _treatments.add(
                    _TreatmentDraft(key: _treatmentKeyCounter++),
                  );
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisabledRow(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Theme.of(context).disabledColor),
        ),
      ),
    );
  }

  Widget _buildLoadingRow(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(child: Text(message)),
    );
  }

  Widget _buildErrorRow(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }

  // ─── ACTIONS ───

  Future<void> _showPatientPicker(
    BuildContext context,
    AsyncValue<List<Patient>> patientsAsync,
  ) async {
    final patients = patientsAsync.asData?.value;
    if (patients == null) return;
    final p = await showAppSelectionSheet<Patient>(
      context,
      title: 'Seleccionar Paciente',
      options: patients,
      labelOf: (p) => '${p.nombre} ${p.primerApellido}',
      sublabelOf: (p) => p.idExpediente,
      selected: _selectedPatient,
      searchable: true,
      searchHint: 'Buscar paciente...',
    );
    if (p != null) {
      setState(() {
        _selectedPatient = p;
        _selectedPatientId = p.idExpediente;
        _formKey.currentState?.fields['id_expediente']?.didChange(
          p.idExpediente,
        );
      });
    }
  }

  Future<void> _showPeriodPicker(
    BuildContext context,
    List<Periodo> periodos,
  ) async {
    final actual =
        periodos.where((p) => p.idPeriodo == _selectedPeriodId).firstOrNull;
    final p = await showAppSelectionSheet<Periodo>(
      context,
      title: 'Periodo',
      options: periodos,
      labelOf: (p) => p.nombrePeriodo,
      selected: actual,
    );
    if (p != null && p.idPeriodo != _selectedPeriodId) {
      setState(() {
        _selectedPeriodId = p.idPeriodo;
        _selectedClinicaId = null; // reset de clínica al cambiar periodo
      });
    }
  }

  Future<void> _showClinicPicker(
    BuildContext context,
    List<Clinica> clinicas,
  ) async {
    final actual =
        clinicas.where((c) => c.idClinica == _selectedClinicaId).firstOrNull;
    final c = await showAppSelectionSheet<Clinica>(
      context,
      title: 'Clínica',
      options: clinicas,
      labelOf: (c) => c.nombreClinica,
      selected: actual,
    );
    if (c != null) setState(() => _selectedClinicaId = c.idClinica);
  }

  Future<void> _showObjetivoPicker(
    BuildContext context,
    List<Objetivo> objetivos,
    _TreatmentDraft draft,
  ) async {
    final labels = [
      'Ninguno (Personalizado)',
      ...objetivos.map((o) => o.nombreTratamiento),
    ];
    final objIdx =
        draft.objetivo == null ? -1 : objetivos.indexOf(draft.objetivo!);
    final currentIndex = objIdx < 0 ? 0 : objIdx + 1;
    final idx = await showAppSelectionSheet<int>(
      context,
      title: 'Objetivo',
      options: List.generate(labels.length, (i) => i),
      labelOf: (i) => labels[i],
      selected: currentIndex,
    );
    if (idx == null || !mounted) return; // cerró sin elegir
    setState(() {
      final anterior = draft.objetivo?.nombreTratamiento;
      draft.objetivo = idx == 0 ? null : objetivos[idx - 1];
      // Solo prellenar el nombre si el usuario no lo ha personalizado (campo
      // vacío o aún igual al objetivo elegido antes).
      final actual = draft.nombre.text.trim();
      if (draft.objetivo != null &&
          (actual.isEmpty || actual == anterior)) {
        draft.nombre.text = draft.objetivo!.nombreTratamiento;
      }
    });
  }

  void _showDateTimePicker(
    BuildContext context,
    FormFieldState<DateTime> field,
  ) {
    _pickDraftDate(field.value ?? DateTime.now(), field.didChange);
  }

  void _pickDraftDate(
    DateTime initial,
    ValueChanged<DateTime> onChanged,
  ) async {
    final picked = await AppDateTimeSheet.pick(context, initial: initial);
    if (picked != null) onChanged(picked);
  }

  void _saveAppointment() async {
    if (_isSaving) return;

    // Return if validation fails
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      return;
    }

    // Manual Validation for Custom Selectors
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccione un paciente')));
      return;
    }
    if (_selectedClinicaId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccione una clínica')));
      return;
    }

    final values = _formKey.currentState!.value;

    if (_treatments.every((t) => t.nombre.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese al menos un tratamiento con nombre'),
        ),
      );
      return;
    }
    if (_treatments.any((t) => t.nombre.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hay tratamientos sin nombre; complételos o elimínelos'),
        ),
      );
      return;
    }

    // Sesión inicial: validar que termina después de que empieza.
    final s0Start = values['fecha_inicio'] as DateTime? ?? DateTime.now();
    final s0End =
        values['fecha_fin'] as DateTime? ?? s0Start.add(kDuracionSesionDefault);
    if (!s0End.isAfter(s0Start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La sesión inicial debe terminar después de empezar'),
        ),
      );
      return;
    }
    for (final d in _additionalSessions) {
      if (!d.fin.isAfter(d.inicio)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cada sesión debe terminar después de empezar'),
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    // Logic to save
    final repo = ref.read(agendaRepositoryProvider);

    final fechaCreacion = DateTime.now().toIso8601String();
    final tratamientos = [
      for (final t in _treatments)
        Tratamiento(
          idClinica: _selectedClinicaId!,
          idExpediente: _selectedPatientId!,
          idObjetivo: t.objetivo?.idObjetivo,
          nombreTratamiento: t.nombre.text.trim(),
          fechaCreacion: fechaCreacion,
          estado: EstadoTratamiento.pendiente,
        ),
    ];

    // Plantilla de sesiones compartida por todos los tratamientos. El
    // `idTratamiento` es un marcador; el repositorio lo sustituye por el id
    // real de cada tratamiento.
    final sesionesPlantilla = [
      Sesion(
        idTratamiento: 0,
        fechaInicio: s0Start.toIso8601String(),
        fechaFin: s0End.toIso8601String(),
        estadoAsistencia: EstadoAsistencia.programada,
      ),
      for (final d in _additionalSessions)
        Sesion(
          idTratamiento: 0,
          fechaInicio: d.inicio.toIso8601String(),
          fechaFin: d.fin.toIso8601String(),
          estadoAsistencia: EstadoAsistencia.programada,
        ),
    ];

    try {
      await repo.createTratamientosEnLote(tratamientos, sesionesPlantilla);

      ref.invalidate(allSesionesProvider);
      ref.invalidate(allTratamientosRichProvider);
      ref.invalidate(enrichedSesionesProvider);

      if (mounted) {
        context.pop();
        final msg =
            tratamientos.length == 1
                ? 'Tratamiento creado exitosamente'
                : '${tratamientos.length} tratamientos creados exitosamente';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $message')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

/// Borrador de una sesión adicional. La `key` es estable y no depende del
/// índice en la lista, de modo que eliminar una sesión del medio no corrompe
/// las demás.
class _SessionDraft {
  _SessionDraft({required this.key, required this.inicio, required this.fin});

  final int key;
  DateTime inicio;
  DateTime fin;
}

/// Borrador de un tratamiento dentro del formulario. La `key` es estable y no
/// depende del índice, de modo que eliminar un tratamiento del medio no
/// corrompe los demás.
class _TreatmentDraft {
  _TreatmentDraft({required this.key});

  final int key;
  Objetivo? objetivo;
  final TextEditingController nombre = TextEditingController();
}
