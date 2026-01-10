# Requisitos de la Aplicación de Gestión Odontológica

## Objetivo Principal

El objetivo de la aplicación es centralizar la gestión de pacientes, tratamientos, y citas de una estudiante de odontología, con un enfoque crucial en la **organización de las metas académicas** y la **agilización de la documentación clínica**.

## I. Flujo de Trabajo y Prioridades Operativas

Los datos indican una alta necesidad de acceso a la información y una baja tolerancia a la pérdida de tiempo clínico.

* **Consulta Rápida del Odontograma:** Es la tarea más frecuente (varias veces por semana), confirmando que el acceso al estado dental debe ser inmediato.

* **Gestión de Citas (Recordatorios):** La alta frustración por faltas se resuelve con la necesidad validada como **Esencial** de contar con envío automático de recordatorios de citas.

* **Simplicidad en el Registro:** Las tareas de "Registrar Nuevo Paciente" y "Documentar Tratamientos" se realizan ocasionalmente (una vez por semana), por lo que el proceso debe ser simple y sin fricción.

* **Acceso Instantáneo a Datos Críticos:** Es necesaria la **Búsqueda rápida de pacientes** (validada como Esencial) para localizar antecedentes e historial de tratamientos de forma inmediata.

## II. Requisitos de Datos y Expediente Parcial Digital

La aplicación debe contener los siguientes elementos:

* **Clínica:** Distingue los pacientes por clínica en la que tienen tratamientos.

* **Paciente:** Cada paciente debe representarse como una "carpeta" o ficha principal desde la pantalla de inicio. Es muy común que existan pacientes que tienen tratamientos para varias clínicas.

* **Datos de Identificación y Contacto:** Nombre completo, número de expediente, edad y número de teléfono.

* **Alerta Médica Obligatoria:** Es fundamental el registro y la alerta visible de **hipertensión o diabetes**. El sistema debe recordar la necesidad de que el paciente tome su medicamento antes de la sesión.

* **Anexos y Evidencia:** Capacidad **Esencial** para adjuntar y organizar **archivos de imagen** (fotos extraorales, radiografías).

## III. Requisitos de Funcionalidad Esencial

Las siguientes seis funcionalidades fueron calificadas como **Esenciales**:

1. **Módulo de Odontograma Interactivo:** Una representación visual y editable del estado dental, usada constantemente para la planificación.

2. **Sistema de Diferenciación de Tratamientos:** Debe diferenciar de forma clara y automática el tratamiento **Propuesto/Pendiente** (las metas académicas) del tratamiento **Realizado/Completado** (el historial clínico).

3. **Clasificación por Clínicas:** Funcionalidad **Esencial** para diferenciar y filtrar citas/tratamientos según la clínica o especialidad (Operatoria, Periodoncia, Oclusión, etc.).

4. **Envío Automático de Recordatorios:** Necesario para mitigar el dolor de cabeza de la inasistencia.

5. **Búsqueda Rápida de Pacientes:** Permite localizar al paciente por nombre o número de expediente de manera instantánea.

6. **Adjuntar Archivos de Imagen:** La capacidad de cargar y asociar fotos/radiografías es un requisito de documentación crítico.

### Requisito Adicional de Seguimiento

* **Control y Seguimiento:** La aplicación debe manejar el seguimiento a largo plazo. Si se realiza un control preventivo, el sistema debe registrarlo y **sugerir/alertar automáticamente** la próxima fecha de control (típicamente al año siguiente).

## IV. Requisitos de Agendamiento y Plataforma

* **Plataforma de Uso:** La aplicación debe ser diseñada con un enfoque **Mobile-First**, ya que el uso principal se dará a través del teléfono móvil en la clínica.

* **Estructura de Carpetas/Filtros:** La navegación principal debe agrupar a los pacientes por la clínica a la que están siendo atendidos.

* **Agendamiento:** Un calendario simple que muestre la disponibilidad de la estudiante.

* **Uso Personal:** La aplicación será inicialmente para uso individual.