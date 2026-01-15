# MODELO DE DATOS Y REGLAS DE NEGOCIO (VERSIÓN FINAL)

## 1. Esquema de Base de Datos (SQLite)

La base de datos se debe nombrar odontologia_student.db. Las tablas deben crearse respetando estrictamente los nombres (en plural) y tipos de datos definidos en el Diagrama E-R Final.

### A. Estructura Académica

- **Periodos**

    - `id_periodo` (INTEGER PK AutoIncrement)

    - `nombre_periodo` (TEXT)

- **Clinicas**

    - `id_clinica` (INTEGER PK AutoIncrement)

    - `id_periodo` (INTEGER FK) -> Ref: periodos.id_periodo

    - `nombre_clinica` (TEXT Unique) -> Debe ser único.

    - `color` (TEXT) -> HexString para UI.

    - `horarios` (TEXT Nullable) -> Puede ser nulo.

- **Objetivos**

    - `id_objetivo` (INTEGER PK AutoIncrement)

    - `id_clinica` (INTEGER FK) -> Ref: clinicas.id_clinica

    - `nombre_tratamiento` (TEXT)

    - `cantidad_meta` (INTEGER)

    - `cantidad_actual` (INTEGER) -> Contador de progreso.

### B. Gestión de Pacientes y Odontograma

- **Pacientes**

    - `id_expediente` (INTEGER PK) -> No es autoincrement, es ingresado manual (Nro Expediente Facultad).

    - `nombre` (TEXT), `primer_apellido` (TEXT), `segundo_apellido` (TEXT).

    - `edad` (INTEGER), `sexo` (TEXT), `telefono` (TEXT).

    - `padecimiento_relevante` (TEXT), `informacion_adicional` (TEXT).

    - `imagenes_paths` (TEXT) -> JSON Array String con rutas locales.

- **Odontogramas**

    - `id_odontograma` (INTEGER PK AutoIncrement)

    - `id_expediente` (INTEGER FK) -> Ref: pacientes.id_expediente. Relación 1:1 lógica.

- **PiezasDentales** (Tabla piezas_dentales o PiezasDentales)

    - `id_pieza` (TEXT PK) -> Identificador único generado (ej: "ODO1-P18").

    - `id_odontograma` (INTEGER FK) -> Ref: odontogramas.id_odontograma.

    - `numero_pieza` (INTEGER) -> ISO System (11-85).

    - `tipo_diente` (TEXT), `estado_general` (TEXT).

    - `id_grupo_puente` (TEXT) -> Identificador para agrupar puentes.

    - `superficies` (TEXT) -> Mapa JSON de estados por cara.

    - `tiene_sellador` (BOOLEAN) -> 0 o 1 en SQLite.

### C. Agenda y Ejecución

- **Tratamientos**

    - `id_tratamiento` (INTEGER PK AutoIncrement)

    - `id_clinica` (INTEGER FK) -> Ref: clinicas.id_clinica

    - `id_expediente` (INTEGER FK) -> Ref: pacientes.id_expediente

    - `id_objetivo` (INTEGER FK) -> Ref: objetivos.id_objetivo. (Puede ser NULL si no es meta).

    - `nombre_tratamiento` (TEXT)

    - `fecha_creacion` (DATETIME)

    - `estado` (TEXT) -> Valores sugeridos: 'PLANIFICADO', 'EN_CURSO', 'CONCLUIDO'.

- **Sesiones**

    - `id_sesion` (INTEGER PK AutoIncrement)

    - `id_tratamiento` (INTEGER FK) -> Ref: tratamientos.id_tratamiento.

    - `fecha_inicio` (DATETIME), `fecha_fin` (DATETIME).

    - `estado_asistencia` (TEXT).

## 2. Reglas de Negocio Críticas

### A. Lógica de Actualización de Metas (Basada en Estado)

Dado que la tabla `Tratamientos` controla la lógica mediante el campo estado:

1. Cuando el usuario finaliza la última sesión de un tratamiento, el sistema pregunta: "¿Se concluyó el tratamiento definitivamente?".

2. Si la respuesta es SÍ:

    - Se actualiza Tratamientos.estado = 'CONCLUIDO'.

    - Si Tratamientos.id_objetivo NO es NULL: Se busca el registro en la tabla Objetivos y se incrementa `cantidad_actual = cantidad_actual + 1`.

3. Si la respuesta es NO:

    - Se actualiza Tratamientos.estado = 'EN_CURSO'.

    - NO se modifica la tabla Objetivos.

### B. Inicialización del Odontograma

Al registrar un Paciente:

- El sistema debe insertar automáticamente 1 registro en Odontogramas.

- El sistema debe insertar en PiezasDentales las 32 (o 52) filas correspondientes a la dentadura inicial, con id_pieza generado (UUID o compuesto) y estado_general = 'SANO'.

- Esto es vital para que la UI pueda hacer SELECT * FROM PiezasDentales WHERE id_odontograma = X y dibujar inmediatamente.

### C. Relación Cita - Tratamiento

- La Sesión es la unidad de tiempo en el calendario.

- El Tratamiento es la unidad lógica clínica.

- Al crear una cita (Sesión), primero se debe asegurar que exista un Tratamiento (padre). Si es un procedimiento nuevo, se crea el registro en Tratamientos con estado 'PLANIFICADO' y luego se crea la Sesión vinculada.

- Al registrar un tratamiento nuevo, se debe poder registrar/agendar más de una sesión si el usuario así lo desea.