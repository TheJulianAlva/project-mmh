# Estrategia Freemium — Klinik

> **Fecha:** Mayo 2026  
> **Objetivo:** Convertir Klinik en un producto vendible a estudiantes de odontología y a instituciones educativas, usando un modelo freemium sostenible.

---

## 1. Contexto de Mercado

### Quiénes son los usuarios actuales
- **Estudiantes de odontología** (pregrado y posgrado) que deben documentar sus prácticas clínicas como requisito académico.
- **Facultades de odontología** que evalúan el avance de sus alumnos por número de tratamientos completados por tipo.

### Por qué Klinik es vendible
1. **Problema real y continuo:** Cada generación de estudiantes enfrenta el mismo problema — documentar decenas de pacientes, sesiones y tratamientos durante sus años de clínica.
2. **Sin competencia directa offline:** Las soluciones clínicas existentes (Softdent, Dentisoft, etc.) son caras, pensadas para consultorios, no para estudiantes, y requieren internet o licencias institucionales.
3. **Datos sensibles locales:** Los pacientes de práctica pueden ser familiares o conocidos; muchos estudiantes preferirán una app que NO sincronice con la nube.
4. **Ciclo de uso largo:** Un estudiante usa la app 2–4 años (duración del periodo clínico). El LTV (valor por usuario) justifica una suscripción modesta.

### Tamaño estimado del mercado
- México: ~40 facultades de odontología con ~2,000 alumnos en semestres clínicos cada año.
- Latinoamérica: ×8–10 ese número.
- Un precio de **MXN $99/semestre (~5 USD)** aplicado al 10% del mercado mexicano = **~$10,000 USD/año** como baseline.

---

## 2. Propuesta de Modelo Freemium

### Principio rector
> El tier gratuito debe ser **genuinamente útil** para que los usuarios lo usen y compartan la app. El tier de pago resuelve los puntos de dolor de los usuarios más avanzados o más exigentes.

### Tier Gratuito — "Klinik Básico"

| Feature | Límite |
|---|---|
| Pacientes activos | Hasta **15 pacientes** |
| Tratamientos por paciente | Sin límite |
| Sesiones por tratamiento | Sin límite |
| Odontograma interactivo | ✅ Sin límite |
| Búsqueda de pacientes | ✅ Incluida |
| 1 período académico / 1 clínica | ✅ Sin límite |
| Recordatorios de citas | ✅ Incluidos |
| Wizard de diagnóstico endodóntico | ✅ Incluido |
| Temas (claro/oscuro) | ✅ Incluido |
| Fotos por paciente | Hasta **2 fotos** por paciente |
| Dashboard de metas | Solo el período activo |
| Exportar/respaldar datos | ❌ No incluido |
| Múltiples períodos académicos | ❌ No incluido |

**Razonamiento del límite de 15 pacientes:** Un alumno en semestres iniciales atiende 5–10 pacientes. El límite es generoso para empezar, pero se alcanza naturalmente al avanzar en la carrera — creando el momento orgánico de conversión.

---

### Tier de Pago — "Klinik Pro"

**Precio sugerido:** MXN $99/semestre (~5 USD) o MXN $149/año (~7.50 USD)

**Clínico:**

| Feature | Detalle |
|---|---|
| Pacientes activos | **Sin límite** |
| Fotos por paciente | **Sin límite** |
| Múltiples períodos académicos | Historial completo, comparativas entre semestres |
| Dashboard avanzado | Gráficas de progreso por tipo de tratamiento, totales por período |
| Exportar a PDF | Expediente completo del paciente como PDF profesional |
| Respaldo y restauración | Exportar / importar base de datos local (para cambio de dispositivo) |
| Notas de sesión | Campo de notas enriquecido por sesión (texto + fotos) |
| Recordatorios avanzados | Notificaciones personalizables por tipo de tratamiento |

**Estudiantil:**

| Feature | Detalle |
|---|---|
| Flashcards personalizables | Mazos adicionales + creador de tarjetas propias |
| Horario con recordatorios | Notificaciones de clase + integración con agenda de pacientes |
| Gestor de tareas completo | Sin límite + recordatorios + adjuntos |
| Checklists extendidos | Todos los procedimientos + historial de uso |
| Glosario extendido | +500 términos con imágenes clínicas y sinónimos en inglés |
| Temporizador + flashcards | Historial de estudio + flashcards aleatorias en descansos |
| Calculadora de materiales | Todos los materiales dentales |
| Bloc de notas completo | Sin límite de materias/notas + búsqueda de texto completo |
| Soporte prioritario | Acceso a canal de soporte directo |

---

### Tier Institucional — "Klinik Facultad" *(futuro)*

**Precio sugerido:** MXN $X/alumno/semestre (negociado con la institución)

Este tier es a largo plazo y requiere infraestructura de sincronización, pero se puede diseñar la app para soportarlo desde ahora.

| Feature adicional | Detalle |
|---|---|
| Portal web del docente | El profesor ve el avance de todos sus alumnos en tiempo real |
| Validación de tratamientos | El docente aprueba o rechaza un tratamiento registrado |
| Reportes de cohorte | Comparativas entre grupos, semestres e indicadores de completitud |
| Plantillas de clínica | El docente define los objetivos y la app los precarga en todos los alumnos |
| SSO institucional | Login con correo universitario |

---

## 3. Features Adicionales para Aumentar el Valor Percibido

Estas son funciones que aumentan la disposición a pagar sin requerir infraestructura de servidor.

### 3.1 Exportación de Expediente en PDF ⭐ Alto impacto
Los estudiantes necesitan entregar documentación a sus profesores. Un PDF generado automáticamente con:
- Datos del paciente, odontograma visual, lista de tratamientos y sesiones
- Firma/sello del alumno
- Generado localmente (sin internet)

**Paquete sugerido:** `pdf` + `printing` (ya disponibles en pub.dev, sin dependencias de servidor).

### 3.2 Respaldo y Restauración Local ⭐ Alto impacto
Actualmente si el usuario cambia de celular **pierde todo**. Un flujo sencillo de:
1. Exportar → genera un archivo `.klinik` (ZIP del SQLite + carpeta de imágenes)
2. Restaurar → importa el archivo

No requiere nube. Puede compartirse vía WhatsApp, Drive o correo.

### 3.3 Notas Enriquecidas por Sesión
Agregar un campo `notas TEXT` a la tabla `sesiones` y un widget de texto multilínea en la pantalla de detalle de sesión. Los estudiantes anotan observaciones clínicas, materiales usados o indicaciones post-tratamiento.

**Costo de implementación:** Bajo — una migración de DB + campo en el formulario.

### 3.4 Recordatorio de Control Preventivo
Si un paciente tiene diagnóstico de "Gingivitis" o "Caries inicial", la app puede sugerir automáticamente una fecha de revisión (ej: 6 meses). Implementable como una sesión especial de tipo `"control_preventivo"` con una notificación programada.

### 3.5 Galería de Radiografías por Pieza Dental
En lugar de solo adjuntar fotos al paciente, permitir que cada pieza del odontograma tenga sus propias imágenes (radiografías). Esto aumenta la utilidad del odontograma significativamente para estudiantes de endodoncia y periodoncia.

### 3.6 Estadísticas de Progreso Gamificadas
Un dashboard mejorado que muestre:
- **Racha de sesiones:** "Llevas 3 semanas seguidas registrando sesiones"
- **Porcentaje del semestre completado:** barra global por todos los objetivos de todas las clínicas
- **Tratamiento más frecuente:** insight sobre el tipo de tratamiento donde más practica el alumno

Esto aumenta la retención diaria de la app.

### 3.7 Wizard de Diagnóstico Expandible
El árbol de diagnóstico actual solo cubre endodoncia. Agregar módulos para:
- **Diagnóstico periodontal** (Gingivitis, Periodontitis estadios I–IV)
- **Diagnóstico de oclusión** (Clase I, II, III de Angle)
- **Odontopediatría** (caries de infancia temprana, erupción)

Cada módulo puede desbloquearse individualmente o incluirse en Pro. Esto diferencia la app de cualquier alternativa genérica.

### 3.8 Plantillas de Tratamiento
Permitir guardar tratamientos frecuentes como plantillas (ej: "Endodoncia de un conducto — molar inferior") con el nombre, clínica y número de sesiones típicas precargados. Ahorra tiempo en el registro diario.

### 3.9 Modo Compartir con Compañero
Exportar el perfil de un paciente para enviarlo a un compañero (ej: cuando dos estudiantes comparten un caso complejo). El receptor importa el expediente en su app con un QR o código de 6 dígitos.

### 3.10 Widget de Agenda en la Pantalla de Inicio (Android)
Un widget nativo que muestre las próximas 2–3 sesiones del día directamente en el launcher del teléfono, sin abrir la app. Alto impacto en retención diaria.

---

## 4. Features de Vida Estudiantil

Klinik no debería ser solo una app clínica — debería ser **el compañero académico del estudiante de odontología**. Estas funciones no están relacionadas con los pacientes, sino con el día a día del alumno dentro de la universidad. Un estudiante que usa la app para estudiar, organizar su semestre y calcular dosis la abre todos los días, no solo cuando tiene paciente.

> **Principio:** Cada feature de esta sección convierte a Klinik de una herramienta de documentación clínica en una app que el alumno instala el primer día de carrera y no desinstala hasta graduarse.

---

### 4.1 Calculadora de Anestesia Local ⭐ Alto impacto / Alta diferenciación

Una de las herramientas más buscadas por estudiantes de odontología. Calcula la dosis máxima segura de anestésico según el peso del paciente, el tipo de anestésico y la concentración del cartucho.

**Flujo propuesto:**
1. El alumno ingresa: peso del paciente (kg), anestésico (lidocaína 2%, articaína 4%, mepivacaína 3%…), concentración del vasoconstrictor
2. La app calcula: dosis máxima en mg, número máximo de cartuchos, advertencia si el paciente tiene algún padecimiento registrado (ej: cardiopatía → evitar vasoconstrictor)
3. Resultado visible de un vistazo, con código de color (verde / amarillo / rojo)

**Por qué diferencia a Klinik:** No existe ninguna calculadora de anestesia offline integrada en un expediente de paciente. El alumno puede abrir la ficha del paciente y calcular la dosis en la misma pantalla.

**Costo de implementación:** Muy bajo — lógica puramente matemática, sin DB ni providers nuevos.

---

### 4.2 Checklists de Procedimientos Clínicos ⭐ Alto impacto

Guías paso a paso que el alumno puede revisar durante o antes de un procedimiento, como una lista de verificación. Reduce errores y sirve como referencia de consulta rápida.

**Procedimientos propuestos en la versión gratuita:**
- Extracción dental simple
- Obturación con resina compuesta
- Profilaxis y detartraje básico

**Procedimientos Pro (desbloqueables):**
- Endodoncia uniradicular / multiradicular
- Colocación de implante (etapas)
- Cirugía de terceros molares
- Tallado de corona completa
- Toma de impresiones / modelos de estudio
- Sutura y puntos (tipos y técnica)

Cada checklist incluye: materiales necesarios, pasos ordenados con checkbox, notas de error común, y tiempo estimado del procedimiento.

**Costo de implementación:** Bajo — datos estáticos en JSON; pantalla de lista con checkboxes locales (no persistentes entre sesiones, o con opción de guardar el historial en Pro).

---

### 4.3 Flashcards de Repaso Odontológico

Tarjetas de memoria para estudiar conceptos, anatomía, farmacología y materiales. El alumno puede revisar un mazo de tarjetas antes de un examen desde la app que ya tiene en el teléfono.

**Mazos incluidos por defecto (gratuito):**
- Anatomía dental (corona, raíz, cámara pulpar — 30 tarjetas)
- Clasificación de Black de caries (6 tarjetas clásicas)
- Anestésicos locales (nombre, mecanismo, contraindicaciones — 15 tarjetas)

**Pro — mazos adicionales y personalizables:**
- Farmacología odontológica (analgésicos, antibióticos, dosis)
- Instrumentos endodónticos (limas, tipo, uso)
- Cementos y materiales de obturación
- Periodoncia (índices de Löe, clasificación de Armitage)
- Radiología dental (técnicas, interpretación)
- **Creador de tarjetas propias:** el alumno añade sus propias preguntas/respuestas para exámenes específicos

**Mecánica de repaso:** Sistema de repetición espaciada simplificado — las tarjetas que el alumno marca como "difícil" aparecen más seguido.

---

### 4.4 Horario Académico Semanal

Vista semanal con las materias del semestre actual: hora, salón, docente. El alumno lo configura una vez al inicio del semestre.

**Funciones incluidas:**
- Vista de semana con bloques de color por materia
- Recordatorios de clase (notificación 15 min antes)
- Campo de notas por materia (apuntes rápidos, tareas pendientes)
- Indicador visual de "día clínico" integrado con la agenda de pacientes

**Por qué es útil como feature de Klinik:** Un alumno de clínica tiene días de materias teóricas intercalados con días en la clínica. Tener ambos calendarios en la misma app evita el cambio constante entre aplicaciones.

**Nivel de acceso:** Gratuito (horario básico) / Pro (recordatorios + notas por materia + sincronización con agenda de pacientes)

---

### 4.5 Gestor de Tareas y Entregas Académicas

Lista de pendientes académicos con fechas límite y prioridad. Diferente a los recordatorios de citas — este módulo es para trabajos, exámenes, presentaciones y lecturas.

**Campos por tarea:**
- Materia, descripción, fecha de entrega
- Prioridad (alta / media / baja) con color
- Estado: pendiente / en progreso / entregado
- Adjunto de referencia (foto de la indicación del profesor, un PDF de la tarea)

**Features Pro:**
- Recordatorio configurable días antes de la entrega
- Estadística de tareas completadas a tiempo vs. tarde (habit tracker académico)
- Vista de calendario con las entregas superpuestas sobre el horario

**Por qué aumenta retención:** El alumno abre la app no solo para registrar pacientes, sino también para revisar sus pendientes del día.

---

### 4.6 Contador de Horas Clínicas Requeridas

Muchas facultades exigen un mínimo de horas clínicas por semestre (ej: 120 horas en Clínica Integral). Klinik puede calcularlas automáticamente a partir de las sesiones ya registradas.

**Funcionamiento:**
- El alumno configura el mínimo de horas requerido por clínica/semestre
- La app suma la duración de cada sesión registrada (`fecha_fin - fecha_inicio`)
- Barra de progreso: "78 de 120 horas completadas (65%)"
- Proyección: "A tu ritmo actual, alcanzarás las 120 horas en semana 14"

**Valor:** No requiere funcionalidad nueva más allá de lo que ya existe en la DB — solo un cálculo sobre los campos `fecha_inicio` / `fecha_fin` de las sesiones, más una pantalla de configuración.

---

### 4.7 Glosario Odontológico Integrado

Diccionario de términos clínicos accesible sin internet, con definición, imagen ilustrativa y contexto de uso.

**Contenido base (gratuito):** ~150 términos esenciales (endodoncia, periodoncia, operatoria, cirugía básica).  
**Pro:** +500 términos, imágenes clínicas y radiográficas de referencia, sinónimos en inglés (útil para leer literatura científica).

**Búsqueda inteligente:** El alumno escribe "pulpitis" y encuentra la definición, los tipos, el diagnóstico diferencial y el enlace al wizard de diagnóstico del módulo correspondiente.

**Por qué es valioso:** Integrar el glosario con el wizard de diagnóstico y los checklists crea una red de conocimiento dentro de la app — la convierte en una referencia clínica, no solo en un gestor de datos.

---

### 4.8 Temporizador de Estudio (Técnica Pomodoro)

Temporizador configurable para sesiones de estudio enfocado. Simple pero altamente utilizado por estudiantes universitarios.

**Configuración:** Tiempo de trabajo (25 min default), descanso corto (5 min), descanso largo (15 min cada 4 pomodoros).  
**Integración con Klinik:** Mientras el temporizador corre, puede mostrar una flashcard aleatoria de la materia seleccionada en los descansos cortos — convirtiendo el descanso en micro-repaso.  
**Historial:** Registro de sesiones de estudio del día/semana (horas dedicadas por materia).

---

### 4.9 Calculadora de Materiales Dentales

Calcula proporciones de mezcla para materiales de uso común, eliminando el desperdicio y los errores de proporción.

**Materiales incluidos:**
- Cemento de ionómero de vidrio (polvo/líquido según marca: GC Fuji, Ketac)
- Óxido de zinc-eugenol (ZOE) para base y obturación temporal
- Alginato (agua/polvo por número de alveólos)
- Yeso para modelos de estudio (tipo II, tipo III)
- Silicona por adición / condensación (A y B)

**Flujo:** El alumno selecciona el material y la cantidad a preparar; la app muestra gramos exactos de cada componente.

---

### 4.10 Bloc de Notas por Materia

Cuaderno digital organizado por materia con soporte para texto enriquecido básico (negritas, listas, subrayado).

**Diferencia de una app de notas genérica:** Las notas están vinculadas al horario académico del alumno — al seleccionar una materia en el horario, las notas correspondientes aparecen automáticamente. Además, puede vincular una nota a un tratamiento o paciente específico ("Nota de clase de Endodoncia II vinculada al caso #P-042").

**Gratuito:** 3 materias / 10 notas.  
**Pro:** Sin límite, con búsqueda de texto completo y etiquetas.

---

### Impacto en el posicionamiento del producto

La adición de estos features transforma la propuesta de valor:

| Antes | Después |
|---|---|
| "App para documentar pacientes de práctica" | "Compañero académico para estudiantes de odontología" |
| Se abre 2–3 veces por semana (días de clínica) | Se abre todos los días (horario, tareas, flashcards, temporizador) |
| Compite con Excel y cuadernos | Compite con Notion + Anki + Calculadoras + App de horario |
| Fácil de reemplazar al terminar el semestre clínico | Difícil de abandonar porque concentra toda la vida académica |

### Distribución por tier de los nuevos features

| Feature estudiantil | Gratuito | Pro |
|---|---|---|
| Calculadora de anestesia | ✅ Completa | — |
| Checklists de procedimientos | 3 procedimientos básicos | Todos + historial |
| Flashcards | 3 mazos predefinidos | Mazos adicionales + creador |
| Horario semanal | Vista básica | + Recordatorios + integración agenda |
| Gestor de tareas | Hasta 20 tareas | Sin límite + recordatorios + adjuntos |
| Contador de horas clínicas | ✅ Completo | — |
| Glosario odontológico | ~150 términos | +500 términos + imágenes |
| Temporizador Pomodoro | ✅ Básico | + Historial + flashcards en descansos |
| Calculadora de materiales | 3 materiales básicos | Todos los materiales |
| Bloc de notas | 3 materias / 10 notas | Sin límite + búsqueda |

---

## 5. Estrategia de Lanzamiento y Conversión

### Fase 1 — Validación (0–3 meses)
- Publicar en Google Play y App Store como app **completamente gratuita** (sin límites aún)
- Distribuir en 1–2 facultades piloto
- Medir retención a 30 días, features más usadas, puntos de abandono
- Corregir bugs críticos identificados (ver doc de análisis)

### Fase 2 — Activación del freemium (3–6 meses)
- Introducir el límite de 15 pacientes para nuevas instalaciones
- Lanzar Klinik Pro con exportación PDF y respaldo local
- Usuarios anteriores al corte → "Acceso Pro de por vida" (early adopters)
- Precio de lanzamiento: MXN $69/semestre (descuento del 30%)

### Fase 3 — Crecimiento orgánico (6–18 meses)
- Programa de referidos: "Invita a un compañero y ambos reciben 1 mes gratis"
- Convenios con asociaciones estudiantiles de odontología (OFEM, ANUIE-ODONTO)
- Versión web de solo lectura para entregar reportes a profesores
- Módulos adicionales del wizard de diagnóstico como add-ons

### Fase 4 — Institucional (18 meses+)
- Portal del docente como PWA (Progressive Web App)
- Licencias institucionales negociadas directamente con facultades
- Integración con sistemas académicos (SIAE, plataformas Moodle)

---

## 6. Cambios Técnicos Necesarios para Monetización

### 5.1 Validación de tier en la app (sin servidor)
Para el modelo freemium sin backend:
- Almacenar el estado de licencia en SharedPreferences (`klinik:pro_status`, `klinik:pro_expiry`)
- Usar validación local de recibo de compra in-app (`in_app_purchase` package)
- Para licencias institucionales: código de activación cifrado con clave pública de la institución

### 5.2 In-App Purchase
Integrar el paquete `in_app_purchase` (Flutter official):
- Google Play Billing API para Android
- StoreKit para iOS
- Suscripciones: semestral y anual
- Compras únicas: módulos de diagnóstico adicionales

### 5.3 Pantalla de Paywall
Diseñar una pantalla `KlinikProScreen` que se muestra al alcanzar el límite (ej: al intentar crear el paciente 16) con:
- Listado de beneficios Pro
- Precio con descuento de lanzamiento
- Opción "Probar gratis 7 días"

### 5.4 Analytics básico (offline-first)
Para entender comportamiento sin comprometer privacidad:
- Usar `shared_preferences` para contar eventos locales (sesiones creadas, pacientes añadidos, features usadas)
- En el momento de upgrade, el usuario puede optar por compartir estadísticas anónimas de uso

---

## 7. Resumen de Roadmap

```
Q3 2026 │ [Clínico]     Corrección de bugs críticos (iOS, N+1, soft-delete)
        │ [Clínico]     Respaldo/restauración local
        │ [Clínico]     Notas en sesión
        │ [Estudiantil] Calculadora de anestesia local
        │ [Estudiantil] Contador de horas clínicas requeridas
        │ [Estudiantil] Checklists de procedimientos (3 básicos)
        │               Publicación en stores como app gratuita
        │
Q4 2026 │ [Clínico]     Exportación a PDF
        │ [Clínico]     Dashboard gamificado
        │ [Estudiantil] Horario académico semanal
        │ [Estudiantil] Gestor de tareas y entregas
        │ [Estudiantil] Glosario odontológico (150 términos)
        │               Límite freemium activado (15 pacientes)
        │               Lanzamiento de Klinik Pro (MXN $69/semestre)
        │
Q1 2027 │ [Clínico]     Wizard de diagnóstico periodontal
        │ [Clínico]     Galería de imágenes por pieza dental
        │ [Clínico]     Plantillas de tratamiento
        │ [Estudiantil] Flashcards de repaso + mazos adicionales Pro
        │ [Estudiantil] Calculadora de materiales dentales
        │ [Estudiantil] Temporizador Pomodoro + integración flashcards
        │               Widget de agenda en pantalla de inicio (Android)
        │
Q2 2027 │ [Clínico]     Módulos de diagnóstico como add-ons
        │ [Estudiantil] Bloc de notas por materia (Pro)
        │ [Estudiantil] Glosario extendido +500 términos (Pro)
        │               Programa de referidos
        │               Versión web de reportes (solo lectura)
        │
2028+   │ Portal del docente
        │ Licencias institucionales
        │ Integración con sistemas académicos
```

---

## 8. Estimación de Ingresos (Caso Base)

| Métrica | Valor |
|---|---|
| Instalaciones año 1 (México) | 500 |
| Tasa de conversión a Pro | 15% |
| Usuarios Pro año 1 | 75 |
| Precio promedio por usuario | MXN $99/semestre × 2 = $198/año |
| **Ingreso año 1** | **~MXN $14,850 (~$750 USD)** |
| Instalaciones año 2 (LATAM) | 3,000 |
| Tasa de conversión | 12% |
| **Ingreso año 2** | **~MXN $71,280 (~$3,600 USD)** |

> Nota: Estos números son conservadores. Un convenio con una sola facultad de 300 alumnos a MXN $49/alumno/semestre generaría MXN $14,700 por cohorte.

---

*Documento de estrategia. Las estimaciones de mercado son orientativas y deben validarse con investigación de usuarios real antes de implementar el modelo de cobro.*
