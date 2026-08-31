import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mmh/core/presentation/widgets/app_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_confirm.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_switch.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/odontograma/domain/models/pieza_dental.dart';
import 'package:project_mmh/features/odontograma/presentation/controllers/odontograma_controller.dart';
import 'package:project_mmh/features/odontograma/presentation/widgets/tooth_widget.dart';

class OdontogramaScreen extends ConsumerStatefulWidget {
  final String pacienteId;

  const OdontogramaScreen({super.key, required this.pacienteId});

  @override
  ConsumerState<OdontogramaScreen> createState() => _OdontogramaScreenState();
}

class _OdontogramaScreenState extends ConsumerState<OdontogramaScreen> {
  bool _showPediatric = false;
  bool _isEditing = false;
  // Bridge Selection State
  PiezaDental? _bridgeStartPiece;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final odontogramaState = ref.watch(
      odontogramaControllerProvider(widget.pacienteId),
    );
    final selectedTool = ref.watch(selectedToolProvider);
    final palette = ToothPalette.of(context);

    return AppScaffold(
      title: 'Odontograma',
      actions: [
        IconButton(
          icon: Icon(_isEditing ? Icons.check : Icons.edit),
          tooltip: _isEditing ? 'Terminar edición' : 'Editar odontograma',
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
              // If exiting edit mode, we might want to clear any temporary selection like bridge start
              if (!_isEditing) {
                _bridgeStartPiece = null;
              }
            });
          },
        ),
        const SizedBox(width: AppSpacing.lg),
        AppSwitch(
          value: _showPediatric,
          onChanged: (v) => _onPediatricToggled(v),
        ),
        const SizedBox(width: AppSpacing.sm),
        const Text("Pediátrico"),
        const SizedBox(width: AppSpacing.lg),
      ],
      slivers: [
        SliverFillRemaining(
          child: Column(
            children: [
              Expanded(
                child: odontogramaState.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (e, st) => AppErrorView(
                        message: 'No se pudo cargar el odontograma.',
                        onRetry:
                            () =>
                                ref
                                    .read(
                                      odontogramaControllerProvider(
                                        widget.pacienteId,
                                      ).notifier,
                                    )
                                    .loadOdontograma(),
                      ),
                  data: (piezas) {
                    return SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 64,
                            vertical: 32,
                          ),
                          child: Column(
                            children: [
                              if (_bridgeStartPiece != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.sm,
                                  ),
                                  child: AppCard(
                                    accentColor:
                                        Theme.of(context).colorScheme.tertiary,
                                    padding: const EdgeInsets.all(
                                      AppSpacing.sm,
                                    ),
                                    child: Text(
                                      "Seleccione el diente final del puente (Inicio: ${_bridgeStartPiece?.iso})",
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  ),
                                ),

                              // 1. Permanent Upper (18-11 | 21-28)
                              _buildTeethRow(
                                piezas,
                                [18, 17, 16, 15, 14, 13, 12, 11],
                                [21, 22, 23, 24, 25, 26, 27, 28],
                                isUpper: true,
                              ),

                              if (_showPediatric) ...[
                                const SizedBox(height: 16),
                                // 2. Pediatric Upper (55-51 | 61-65)
                                _buildTeethRow(
                                  piezas,
                                  [55, 54, 53, 52, 51],
                                  [61, 62, 63, 64, 65],
                                  isUpper: true,
                                  scale: 0.8,
                                ),
                                const SizedBox(height: 16),
                                // 3. Pediatric Lower (85-81 | 71-75)
                                _buildTeethRow(
                                  piezas,
                                  [85, 84, 83, 82, 81],
                                  [71, 72, 73, 74, 75],
                                  isUpper: false,
                                  scale: 0.8,
                                ),
                                const SizedBox(height: 16),
                              ] else ...[
                                const SizedBox(height: 32),
                              ],

                              // 4. Permanent Lower (48-41 | 31-38)
                              _buildTeethRow(
                                piezas,
                                [48, 47, 46, 45, 44, 43, 42, 41],
                                [31, 32, 33, 34, 35, 36, 37, 38],
                                isUpper: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // TOOL PALETTE
              if (_isEditing)
                Container(
                  height: 110,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 64,
                      vertical: 8,
                    ),
                    children: [
                      // GROUP 1: ERASE & SURFACE
                      _buildToolSection("Superficie", [
                        _buildToolItem(
                          selectedTool,
                          OdontogramaTools.sano,
                          Theme.of(context).colorScheme.onSurface,
                          icon: Icons.cleaning_services,
                          label: "Borrar",
                        ),
                        _buildToolItem(
                          selectedTool,
                          OdontogramaTools.caries,
                          palette.caries,
                          label: "Caries",
                        ),
                        _buildToolItem(
                          selectedTool,
                          OdontogramaTools.obturacion,
                          palette.obturacion,
                          label: "Obturación",
                        ),
                        _buildToolItem(
                          selectedTool,
                          OdontogramaTools.fractura,
                          palette.caries,
                          icon: Icons.flash_on,
                          label: "Fractura",
                        ),
                        _buildToolItem(
                          selectedTool,
                          OdontogramaTools.restauracionFiltrada,
                          palette.obturacion,
                          borderColor: palette.caries,
                          label: "Rest. Filtrada",
                        ),
                      ]),
                      const VerticalDivider(),
                      // GROUP 2: INDEPENDENT
                      _buildToolSection("Indep.", [
                        _buildToolItem(
                          selectedTool,
                          OdontogramaTools.sellador,
                          palette.obturacion,
                          icon: Icons.security,
                          label: "Sellador",
                        ),
                      ]),
                      const VerticalDivider(),
                      // GROUP 3: GLOBAL
                      _buildToolSection("Global", [
                        _buildToolItem(
                          selectedTool,
                          OdontogramaTools.ausente,
                          palette.obturacion,
                          icon: Icons.cancel_outlined,
                          label: "Ausente",
                        ), // Blue /
                        _buildToolItem(
                          selectedTool,
                          OdontogramaTools.porExtraer,
                          palette.caries,
                          icon: Icons.cancel,
                          label: "P. Extraer",
                        ), // Red /
                        _buildToolItem(
                          selectedTool,
                          OdontogramaTools.erupcion,
                          palette.obturacion,
                          icon: Icons.arrow_upward,
                          label: "Erupción",
                        ),
                        _buildToolItem(
                          selectedTool,
                          OdontogramaTools.protesisFija,
                          Theme.of(context).colorScheme.onSurface,
                          icon: Icons.link,
                          label: "Puente",
                        ),
                      ]),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onPediatricToggled(bool value) async {
    if (value) {
      setState(() => _showPediatric = true);
      return;
    }

    final notifier = ref.read(
      odontogramaControllerProvider(widget.pacienteId).notifier,
    );

    if (notifier.hasPediatricData()) {
      final confirmed = await showAppConfirm(
        context,
        title: '¿Ocultar dentición temporal?',
        message:
            'Se eliminará el trabajo registrado en las piezas temporales '
            '(51-85). Esta acción no se puede deshacer.',
        confirmLabel: 'Eliminar',
        destructive: true,
      );
      if (!confirmed) return;
    }

    setState(() => _showPediatric = false);
    await notifier.cleanPediatricTeeth();
  }

  Widget _buildToolSection(String title, List<Widget> children) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).disabledColor,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(children: children),
      ],
    );
  }

  Widget _buildToolItem(
    String currentTool,
    String toolId,
    Color color, {
    IconData? icon,
    Color? borderColor,
    required String label,
  }) {
    final isSelected = currentTool == toolId;
    return GestureDetector(
      onTap: () {
        ref.read(selectedToolProvider.notifier).state = toolId;
        // Reset Bridge state if changing tool
        if (toolId != OdontogramaTools.protesisFija) {
          setState(() => _bridgeStartPiece = null);
        }
      },
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: AppOpacity.subtle)
                  : Theme.of(context).cardColor,
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : (borderColor ?? Theme.of(context).dividerColor),
            width: isSelected || borderColor != null ? 2.0 : 1.0,
          ),
          borderRadius: AppRadii.smAll,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon != null
                ? Icon(icon, color: color, size: 28)
                : Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(
                      color: borderColor ?? Theme.of(context).dividerColor,
                      width: borderColor != null ? 2.0 : 1.0,
                    ),
                  ),
                ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 0,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeethRow(
    List<PiezaDental> allTeeth,
    List<int> leftSideIsos,
    List<int> rightSideIsos, {
    required bool isUpper,
    double scale = 1.0,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isUpper ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        ...leftSideIsos.map(
          (iso) => _buildTooth(
            allTeeth,
            iso,
            scale,
            isUpper: isUpper,
            isLeftSideOfScreen: true,
          ),
        ),
        const SizedBox(width: 30),
        ...rightSideIsos.map(
          (iso) => _buildTooth(
            allTeeth,
            iso,
            scale,
            isUpper: isUpper,
            isLeftSideOfScreen: false,
          ),
        ),
      ],
    );
  }

  Widget _buildTooth(
    List<PiezaDental> allTeeth,
    int iso,
    double scale, {
    required bool isUpper,
    required bool isLeftSideOfScreen,
  }) {
    try {
      final pieza = allTeeth.firstWhere((p) => p.iso == iso);
      final selectedTool = ref.watch(selectedToolProvider);

      String surfaceTopName = isUpper ? 'vestibular' : 'lingual';
      String surfaceBottomName = isUpper ? 'lingual' : 'vestibular';
      String surfaceLeftName = isLeftSideOfScreen ? 'distal' : 'mesial';
      String surfaceRightName = isLeftSideOfScreen ? 'mesial' : 'distal';

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: ToothWidget(
          size: 40 * scale,
          isoNumber: iso.toString(),
          isUpper: isUpper,

          stateTop: _getSurfaceStatus(pieza, surfaceTopName),
          stateBottom: _getSurfaceStatus(pieza, surfaceBottomName),
          stateLeft: _getSurfaceStatus(pieza, surfaceLeftName),
          stateRight: _getSurfaceStatus(pieza, surfaceRightName),
          stateCenter: pieza.estadoOclusal,

          globalState: pieza.estadoGeneral,
          hasSellador: pieza.tieneSellador,
          isBridgeStart: _bridgeStartPiece?.iso == pieza.iso,

          onTapTop: () => _handleTap(pieza, surfaceTopName, selectedTool),
          onTapBottom: () => _handleTap(pieza, surfaceBottomName, selectedTool),
          onTapLeft: () => _handleTap(pieza, surfaceLeftName, selectedTool),
          onTapRight: () => _handleTap(pieza, surfaceRightName, selectedTool),
          onTapCenter: () => _handleTap(pieza, 'oclusal', selectedTool),
        ),
      );
    } catch (e) {
      // Placeholder con la misma altura total que una pieza real (etiqueta ISO
      // + cuerpo) para no desalinear la fila si falta una pieza.
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),
            SizedBox(width: 40 * scale, height: 40 * scale),
          ],
        ),
      );
    }
  }

  String _getSurfaceStatus(PiezaDental p, String surface) {
    switch (surface) {
      case 'vestibular':
        return p.estadoVestibular;
      case 'lingual':
        return p.estadoLingual;
      case 'mesial':
        return p.estadoMesial;
      case 'distal':
        return p.estadoDistal;
      default:
        return 'Sano';
    }
  }

  Future<void> _handleTap(
    PiezaDental pieza,
    String surface,
    String tool,
  ) async {
    if (!_isEditing) return;

    final controller = ref.read(
      odontogramaControllerProvider(widget.pacienteId).notifier,
    );

    // 1. Independent Toggle
    if (tool == OdontogramaTools.sellador) {
      controller.toggleSellador(pieza);
      return;
    }

    // 2. Global States
    if (tool == OdontogramaTools.ausente ||
        tool == OdontogramaTools.porExtraer ||
        tool == OdontogramaTools.erupcion) {
      controller.setGlobalState(pieza, tool);
      return;
    }

    // 3. Bridge Selection
    if (tool == OdontogramaTools.protesisFija) {
      if (_bridgeStartPiece == null) {
        setState(() => _bridgeStartPiece = pieza);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seleccione el diente final del puente'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        final created = await controller.createBridge(
          _bridgeStartPiece!,
          pieza,
        );
        if (mounted && !created) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Puente inválido: seleccione dos dientes de la misma arcada.',
              ),
            ),
          );
        }
        if (mounted) setState(() => _bridgeStartPiece = null);
      }
      return;
    }

    // 3.5 Bridge/Global Deletion Logic
    if (tool == OdontogramaTools.sano &&
        (pieza.estadoGeneral == OdontogramaTools.protesisFija ||
            pieza.estadoGeneral == OdontogramaTools.ausente ||
            pieza.estadoGeneral == OdontogramaTools.porExtraer ||
            pieza.estadoGeneral == OdontogramaTools.erupcion)) {
      controller.setGlobalState(pieza, OdontogramaTools.sano);
      return;
    }

    // 4. Surface States (Caries, Obturacion, Fractura, Sano)
    // Only allowed if not Bridge mode and not Global/Independent tool
    // Actually, Sano behaves as an eraser for surface too.
    controller.updateSurface(pieza, surface, tool);
  }
}
