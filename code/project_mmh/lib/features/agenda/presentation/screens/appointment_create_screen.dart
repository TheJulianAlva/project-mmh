import 'package:flutter/material.dart';
import 'package:project_mmh/core/constants/app_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:project_mmh/features/agenda/domain/sesion.dart';
import 'package:project_mmh/features/agenda/domain/tratamiento.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:project_mmh/features/pacientes/domain/patient.dart';
import 'package:project_mmh/features/pacientes/presentation/providers/patients_provider.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/objetivos_providers.dart'
    as obj_prov;
import 'package:project_mmh/features/core/presentation/providers/preferences_provider.dart';
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
  Objetivo? _selectedObjetivo;
  bool _isSaving = false;

  // Sesiones adicionales con clave estable (no depende del índice en la lista).
  final List<_SessionDraft> _additionalSessions = [];
  int _sessionKeyCounter = 0;

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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Nuevo Tratamiento'),
            backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
            trailing: TextButton(
              onPressed: _isSaving ? null : _saveAppointment,
              child: Text(
                _isSaving ? 'Guardando…' : 'Guardar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ),
            previousPageTitle: 'Atrás',
          ),
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
                                            : Periodo(
                                              nombrePeriodo: 'Sin Periodos',
                                            ),
                              );
                              return _buildSelectorRow(
                                context,
                                label: 'Periodo',
                                value: selected.nombrePeriodo,
                                icon: CupertinoIcons.calendar,
                                onTap:
                                    () => _showPeriodPicker(context, periodos),
                              );
                            },
                            loading:
                                () => _buildLoadingRow(
                                  context,
                                  'Cargando periodos...',
                                ),
                            error:
                                (_, __) => _buildErrorRow(
                                  context,
                                  'Error en periodos',
                                ),
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

                            return _buildGroupedSection(
                              context,
                              children: [
                                _buildSelectorRow(
                                  context,
                                  label: 'Clínica',
                                  value: displayValue,
                                  isPlaceholder: _selectedClinicaId == null,
                                  icon: CupertinoIcons.building_2_fill,
                                  onTap:
                                      () =>
                                          _showClinicPicker(context, clinicas),
                                ),
                                _buildDivider(context),
                                // Objetivo / Tratamiento Selector
                                if (_selectedClinicaId != null) ...[
                                  Consumer(
                                    builder: (context, ref, _) {
                                      final objetivosAsync = ref.watch(
                                        obj_prov.objetivosByClinicaProvider(
                                          _selectedClinicaId!,
                                        ),
                                      );
                                      return objetivosAsync.when(
                                        data: (objetivos) {
                                          // We need to store a custom treatment name if "Custom" is selected
                                          // For now, let's keep it simple: Treatment Name Input
                                          // Ideally detailed picker for "Existing Goal" vs "Custom"
                                          return Column(
                                            children: [
                                              _buildSelectorRow(
                                                context,
                                                label: 'Objetivo',
                                                value:
                                                    _selectedObjetivo
                                                        ?.nombreTratamiento ??
                                                    'Ninguno (Personalizado)',
                                                icon: CupertinoIcons.scope,
                                                onTap:
                                                    () => _showObjetivoPicker(
                                                      context,
                                                      objetivos,
                                                    ),
                                              ),
                                              _buildDivider(context),
                                              _buildTextFieldRow(
                                                context,
                                                name: 'nombre_tratamiento',
                                                label: 'Nombre',
                                                placeholder: 'Ej. Endodoncia',
                                                icon:
                                                    CupertinoIcons
                                                        .doc_text_fill,
                                                maxLength: kMaxNombreTratamiento,
                                                validator: (val) {
                                                  if (val == null ||
                                                      val.trim().isEmpty) {
                                                    return 'Nombre inválido';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                        loading:
                                            () => _buildLoadingRow(
                                              context,
                                              'Cargando objetivos...',
                                            ),
                                        error:
                                            (_, __) => _buildErrorRow(
                                              context,
                                              'Error al cargar objetivos',
                                            ),
                                      );
                                    },
                                  ),
                                ] else ...[
                                  _buildDisabledRow(
                                    context,
                                    'Seleccione una clínica primero',
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
                        initialValue: (widget.initialDate ?? DateTime.now())
                            .add(const Duration(hours: 1)),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                              onTap: () => _pickDraftDate(
                                draft.inicio,
                                (val) => setState(() {
                                  draft.inicio = val;
                                  if (!draft.fin.isAfter(val)) {
                                    draft.fin = val.add(kDuracionSesionDefault);
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
                              onTap: () => _pickDraftDate(
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
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(CupertinoIcons.add, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Agregar Sesión',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          // Límite: 1 sesión inicial + adicionales.
                          if (1 + _additionalSessions.length >= kMaxSesionesPorTratamiento) {
                            showCupertinoDialog(
                              context: context,
                              builder:
                                  (ctx) => CupertinoAlertDialog(
                                    title: const Text('Límite Alcanzado'),
                                    content: Text(
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
                            final base = _additionalSessions.isNotEmpty
                                ? _additionalSessions.last.inicio
                                : (_formKey.currentState
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
      ),
    );
  }

  // ─── WIDGET BUILDERS ───

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
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

  Widget _buildTextFieldRow(
    BuildContext context, {
    required String name,
    required String label,
    String? placeholder,
    IconData? icon,
    int maxLines = 1,
    int? maxLength,
    FormFieldValidator<String>? validator,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 12),
          ] else ...[
            const SizedBox(width: 34),
          ],
          SizedBox(
            width: 80,
            child: Text(label, style: theme.textTheme.bodyLarge),
          ),
          Expanded(
            child: FormBuilderTextField(
              name: name,
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                fillColor: Colors.transparent,
              ),
              maxLines: maxLines,
              maxLength: maxLength,
              validator: validator,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
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

  void _showPatientPicker(
    BuildContext context,
    AsyncValue<List<Patient>> patientsAsync,
  ) {
    patientsAsync.whenData((patients) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              String query = '';
              return StatefulBuilder(
                builder: (context, setModalState) {
                  final filtered = query.trim().isEmpty
                      ? patients
                      : patients.where((p) {
                          final q = query.toLowerCase();
                          return '${p.nombre} ${p.primerApellido} '
                                      '${p.segundoApellido ?? ''}'
                                  .toLowerCase()
                                  .contains(q) ||
                              p.idExpediente.toLowerCase().contains(q);
                        }).toList();
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Seleccionar Paciente',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CupertinoSearchTextField(
                          placeholder: 'Buscar paciente...',
                          onChanged: (val) =>
                              setModalState(() => query = val),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(
                                child: Text('Sin coincidencias'),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final p = filtered[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text(p.nombre[0]),
                                    ),
                                    title: Text(
                                      '${p.nombre} ${p.primerApellido}',
                                    ),
                                    subtitle: Text(p.idExpediente),
                                    onTap: () {
                                      setState(() {
                                        _selectedPatient = p;
                                        _selectedPatientId = p.idExpediente;
                                        _formKey
                                            .currentState
                                            ?.fields['id_expediente']
                                            ?.didChange(p.idExpediente);
                                      });
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      );
    });
  }

  void _showPeriodPicker(BuildContext context, List<Periodo> periodos) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 250,
          child: CupertinoPicker(
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              setState(() {
                _selectedPeriodId = periodos[index].idPeriodo;
                _selectedClinicaId = null; // Reset clinic on period change
              });
            },
            children:
                periodos
                    .map((p) => Center(child: Text(p.nombrePeriodo)))
                    .toList(),
          ),
        );
      },
    );
  }

  void _showClinicPicker(BuildContext context, List<dynamic> clinicas) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 250,
          child: CupertinoPicker(
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              setState(() {
                _selectedClinicaId = clinicas[index].idClinica;
              });
            },
            children:
                clinicas
                    .map((c) => Center(child: Text(c.nombreClinica)))
                    .toList(),
          ),
        );
      },
    );
  }

  void _showObjetivoPicker(BuildContext context, List<Objetivo> objetivos) {
    // Add "None" option
    final options = [
      null,
      ...objetivos,
    ]; // null represents "Ninguno / Personalizado"

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 250,
          child: CupertinoPicker(
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              final selected = options[index];
              setState(() {
                _selectedObjetivo = selected;
                if (selected != null) {
                  // Auto-fill name logic if desired
                  _formKey.currentState?.fields['nombre_tratamiento']
                      ?.didChange(selected.nombreTratamiento);
                }
              });
            },
            children:
                options.map((o) {
                  return Center(
                    child: Text(
                      o?.nombreTratamiento ?? 'Ninguno (Personalizado)',
                      style:
                          o == null
                              ? TextStyle(
                                color: Theme.of(context).disabledColor,
                                fontStyle: FontStyle.italic,
                              )
                              : null,
                    ),
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  void _showDateTimePicker(
    BuildContext context,
    FormFieldState<DateTime> field,
  ) {
    _pickDraftDate(field.value ?? DateTime.now(), field.didChange);
  }

  void _pickDraftDate(DateTime initial, ValueChanged<DateTime> onChanged) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 300,
          child: CupertinoDatePicker(
            initialDateTime: initial,
            mode: CupertinoDatePickerMode.dateAndTime,
            use24hFormat: true,
            onDateTimeChanged: onChanged,
          ),
        );
      },
    );
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
    final nombre = values['nombre_tratamiento'];
    if (nombre == null || nombre.toString().trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese un nombre válido del tratamiento'),
        ),
      );
      return;
    }

    // Sesión inicial: validar que termina después de que empieza.
    final s0Start = values['fecha_inicio'] as DateTime? ?? DateTime.now();
    final s0End =
        values['fecha_fin'] as DateTime? ??
        s0Start.add(kDuracionSesionDefault);
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

    final nuevoTratamiento = Tratamiento(
      idClinica: _selectedClinicaId!,
      idExpediente: _selectedPatientId!,
      idObjetivo: _selectedObjetivo?.idObjetivo,
      nombreTratamiento:
          nombre.toString().trim(), // Ensure trimmed value is saved
      fechaCreacion: DateTime.now().toIso8601String(),
      estado: 'pendiente',
    );

    try {
      final idTratamiento = await repo.createTratamiento(nuevoTratamiento);

      await repo.createSesion(
        Sesion(
          idTratamiento: idTratamiento,
          fechaInicio: s0Start.toIso8601String(),
          fechaFin: s0End.toIso8601String(),
          estadoAsistencia: 'programada',
        ),
      );

      for (final d in _additionalSessions) {
        await repo.createSesion(
          Sesion(
            idTratamiento: idTratamiento,
            fechaInicio: d.inicio.toIso8601String(),
            fechaFin: d.fin.toIso8601String(),
            estadoAsistencia: 'programada',
          ),
        );
      }

      ref.invalidate(allSesionesProvider);
      ref.invalidate(allTratamientosRichProvider);
      ref.invalidate(enrichedSesionesProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tratamiento creado exitosamente')),
        );
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
