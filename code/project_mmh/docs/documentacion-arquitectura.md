# DOCUMENTO DE CONTEXTO TÉCNICO: PROYECTO "ASISTENTE DENTAL ACADÉMICO"

## 1. Visión del Proyecto

Aplicación móvil nativa Flutter con arquitectura Offline-First diseñada para estudiantes de odontología. El objetivo es gestionar pacientes, agenda clínica y progreso académico (metas) sin dependencia de internet. La persistencia es local mediante SQLite.

## 2. Stack Tecnológico (Estricto)

La IA debe utilizar exclusivamente las siguientes librerías y patrones:

- **Framework:** Flutter.
- **Lenguaje:** Dart.
- **Gestión de Estado:** flutter_riverpod (Uso de NotifierProvider y AsyncValue).
- **Base de Datos:** sqflite + path.
- **Modelos e Inmutabilidad:** freezed_annotation, json_annotation (Generación de código).
- **Navegación:** go_router.
- **UI/Calendario:** table_calendar, flutter_svg, font_awesome_flutter.
- **Formularios:** flutter_form_builder.
- **Dev Tools:** build_runner, freezed, json_serializable.

## 3. Estructura del Proyecto (Feature-First)

Se debe respetar la siguiente estructura de directorios para mantener el orden:

```
lib/
├── core/                   # Utilidades compartidas
│   ├── constants/          # Enums y constantes globales
│   ├── database/           # Configuración de SQLite (DatabaseHelper)
│   ├── router/             # Configuración de GoRouter
│   └── theme/              # Tema de la app
├── features/               # Módulos funcionales
│   ├── agenda/             # Calendario, Citas, Lógica de Confirmación
│   ├── clinicas_metas/     # Gestión de Clínicas y Objetivos Académicos
│   ├── dashboard/          # Visualización de progreso y estadísticas
│   └── pacientes/          # CRUD Pacientes y Odontogramas
│       ├── data/           # Repositorios y fuentes de datos locales
│       ├── domain/         # Modelos (Freezed) y Entidades
│       └── presentation/   # Widgets, Screens y Riverpod Providers
└── main.dart
```

## 4. Patrón de Diseño de Datos (Repositorio + Riverpod)

Para cada entidad (ej. Paciente), la implementación debe seguir este flujo:

1. **Entidad (Domain):** Clase anotada con @freezed y @JsonSerializable.
2. **DatabaseHelper (Core):** Métodos rawQuery o insert directos a SQLite.
3. **Repository (Data):** Clase que abstrae las llamadas a la BD.
4. **Provider (Presentation):** AutoDisposeAsyncNotifier de Riverpod que expone el estado a la UI.

## 5. Reglas de Generación de Código

Cada vez que se defina un modelo, se asume la ejecución de: 
```flutter pub run build_runner build --delete-conflicting-outputs```