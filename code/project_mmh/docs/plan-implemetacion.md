# PLAN DE IMPLEMENTACIÓN POR BLOQUES

Instrucción para la IA: No intentes generar todo el código de una sola vez. Sigue este orden secuencial.

## BLOQUE 1: Cimientos y Configuración

**Objetivo:** Tener la app corriendo con la base de datos lista.

1. Implementar lib/core/database/database_helper.dart con el script SQL completo.
2. Crear la estructura de carpetas features/.

## BLOQUE 2: Módulo de Clínicas y Metas (Configuración Inicial)

**Objetivo:** Que el usuario pueda definir "Qué tengo que hacer este semestre".

1. Crear modelos Freezed: Periodo, Clinica, Objetivo.
2. Crear Repositorios y Providers para realizar CRUD de estas entidades.
3. UI: Pantalla de configuración donde se agregan clínicas y sus metas (ej. "Integral I -> 10 Endodoncias").
4. Validar que los datos persisten en SQLite.

## BLOQUE 3: Módulo de Pacientes (Expediente)

**Objetivo:** Gestión administrativa de pacientes.

1. Crear modelo Freezed: Paciente.
2. Implementar lógica de ImagePicker y guardado de rutas en database.
3. UI: Pantalla "Lista de Pacientes" (Buscador) y "Nuevo Paciente" (Formulario).
4. Conectar con base de datos y Riverpod.

## BLOQUE 4: El Odontograma (Gráficos y Lógica)

**Objetivo:** La funcionalidad visual compleja.

1. Crear modelos: Odontograma, PiezaDental.
2. Implementar la lógica de "Seed" (semilla) que inserta las 32 piezas iniciales en la BD.
3. UI: Widget OdontogramaView. Dibujar los dientes (SVG o CustomPaint).
4. Interacción: Al tocar un diente -> Abrir modal de estado -> Actualizar BD -> Redibujar diente (Riverpod).

## BLOQUE 5: Agenda y Tratamientos (El Core de Negocio)

**Objetivo:** Conectar Pacientes con Metas a través del tiempo.

1. Crear modelos: Tratamiento, Sesion.
2. UI: Implementar TableCalendar.
3. Flujo de Creación: Formulario de Cita que consulta Objetivos para llenar el dropdown de tratamientos.
4. Flujo de Confirmación: Modal que pregunta "¿Concluido?" y ejecuta la transacción de actualización de metas.

## BLOQUE 6: Dashboard y Pulido Final

**Objetivo:** Feedback al usuario.

1. UI: Pantalla principal con barras de progreso (Calculadas desde Objetivos).
2. Implementar notificaciones locales (Recordatorios).
3. Pruebas de flujo completo offline.