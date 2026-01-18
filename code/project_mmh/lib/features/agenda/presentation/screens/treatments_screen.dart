import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:project_mmh/features/agenda/domain/tratamiento_rich_model.dart';
import 'package:project_mmh/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:project_mmh/features/agenda/presentation/screens/treatment_detail_screen.dart';

class TreatmentsScreen extends ConsumerWidget {
  const TreatmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tratamientosAsync = ref.watch(allTratamientosRichProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tratamientos')),
      body: tratamientosAsync.when(
        data: (tratamientos) {
          if (tratamientos.isEmpty) {
            return const Center(
              child: Text('No hay tratamientos registrados.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tratamientos.length,
            itemBuilder: (context, index) {
              final item = tratamientos[index];
              return _TreatmentCard(item: item);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ideally navigate to agenda or appointment form, or stay.
          // User didn't specify creation from here, but probably useful.
          // For now, no action or maybe refresh.
          ref.invalidate(allTratamientosRichProvider);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  final TratamientoRichModel item;

  const _TreatmentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    // Parse color
    Color clinicaColor;
    try {
      clinicaColor = Color(
        int.parse(item.colorClinica.replaceAll('#', '0xFF')),
      );
    } catch (_) {
      clinicaColor = Colors.blue;
    }

    final nextSession = item.proximaSesion;
    final dateFormat = DateFormat('EEE d MMM, HH:mm', 'es_ES');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => TreatmentDetailScreen(
                    tratamientoId: item.tratamiento.idTratamiento!,
                  ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: clinicaColor, width: 6)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.tratamiento.nombreTratamiento,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: clinicaColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.nombreClinica,
                      style: TextStyle(
                        fontSize: 12,
                        color: clinicaColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.nombrePaciente,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    nextSession != null
                        ? 'Próxima: ${dateFormat.format(nextSession)}'
                        : 'Sin sesiones programadas',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          nextSession != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                      color: nextSession != null ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
