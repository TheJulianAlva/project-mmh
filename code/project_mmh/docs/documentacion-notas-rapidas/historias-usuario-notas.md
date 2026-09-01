# Historias de Usuario: Módulo de Notas

Este documento cubre las historias de usuario para la nueva sección de **Notas**, que incluye tres variantes construidas sobre el mismo modelo base: notas generales, prepacientes y listas de materiales (con sus cotizaciones).

**Modelo de datos de referencia:**

```
Notas
- id
- tipo: 'general' | 'prepaciente' | 'lista_materiales' | 'cotizacion'
- contenido (TEXT libre, usado en tipo 'general')
- fecha
- id_paciente (FK, nullable) -- notas 'general' ligadas a un paciente existente
- id_clinica (FK, nullable) -- usado en 'lista_materiales'
- id_nota_relacionada (FK a Notas, nullable) -- 'cotizacion' apunta a su 'lista_materiales' padre
- items_json (TEXT, nullable) -- usado en 'lista_materiales' y 'cotizacion'
- proveedor (TEXT, nullable) -- usado en 'cotizacion'
- origen: 'manual' | 'imagen' | 'pdf'
- nombre_contacto, telefono, tratamiento_probable (usados en 'prepaciente')
- convertido (BOOLEAN, default false) -- usado en 'prepaciente'
- id_paciente_convertido (FK, nullable) -- usado en 'prepaciente'
```

---

## Épica 1: Notas rápidas (generales)

### HU-01 — Crear una nota rápida
**Como** estudiante de odontología,
**quiero** poder crear una nota de texto libre en segundos,
**para** capturar información importante sin interrumpir mi flujo de trabajo.

**Criterios de aceptación:**
- Existe un acceso directo desde el dashboard para crear una nota nueva.
- La nota se guarda con `tipo = 'general'`, `contenido` y `fecha` automática.
- No se exige ningún campo adicional para guardar (solo el contenido).
- La nota queda disponible sin conexión a internet (persistencia local).

### HU-02 — Ligar una nota a un paciente
**Como** estudiante,
**quiero** poder asociar una nota a un paciente específico,
**para** encontrar después información relevante dentro de su expediente.

**Criterios de aceptación:**
- Al crear o editar una nota, puedo buscar y seleccionar un paciente ya registrado.
- La nota se guarda con `id_paciente` apuntando al paciente elegido.
- Desde el detalle del paciente puedo ver todas las notas asociadas a él, ordenadas por fecha.
- Puedo desligar una nota de un paciente sin borrarla (dejar `id_paciente` en null).

### HU-03 — Listar y buscar notas
**Como** estudiante,
**quiero** ver todas mis notas generales en una sola pantalla y poder buscarlas,
**para** encontrar rápido algo que anoté antes.

**Criterios de aceptación:**
- Existe una pantalla de listado de notas ordenadas por fecha (más reciente primero).
- Puedo filtrar por texto (búsqueda dentro de `contenido`).
- Puedo filtrar por si están o no ligadas a un paciente.
- Cada elemento de la lista muestra un extracto del contenido y la fecha.

### HU-04 — Editar y eliminar una nota
**Como** estudiante,
**quiero** poder modificar o borrar una nota existente,
**para** corregir errores o eliminar información que ya no necesito.

**Criterios de aceptación:**
- Puedo editar el `contenido` de una nota tipo `general` en cualquier momento.
- Al eliminar, se pide confirmación antes de borrar definitivamente.
- La eliminación no afecta a otras entidades (paciente, tratamiento) más allá de quitar la referencia.

---

## Épica 2: Prepacientes

### HU-05 — Registrar un prepaciente
**Como** estudiante,
**quiero** anotar los datos mínimos de una persona con la que tuve contacto pero que aún no se ha registrado formalmente,
**para** no perder el seguimiento sin tener que crear un expediente completo.

**Criterios de aceptación:**
- Existe una opción para crear una nota de `tipo = 'prepaciente'`, distinta visualmente de una nota general.
- Los campos disponibles son: `nombre_contacto`, `telefono`, `tratamiento_probable` (opcional) y `contenido` libre para observaciones adicionales.
- No se crea ningún registro en la tabla `Pacientes` ni se inicializa odontograma al guardar un prepaciente.
- La nota se guarda con `convertido = false` por defecto.

### HU-06 — Listar prepacientes
**Como** estudiante,
**quiero** ver en una lista separada a todos mis prepacientes activos,
**para** dar seguimiento a quiénes debo contactar o agendar.

**Criterios de aceptación:**
- Existe una vista filtrada que muestra solo notas `tipo = 'prepaciente'` con `convertido = false`.
- Cada elemento muestra nombre, teléfono y tratamiento probable (si existe).
- Los prepacientes ya convertidos no aparecen en esta lista por defecto, pero pueden consultarse con un filtro adicional ("mostrar convertidos").

### HU-07 — Convertir un prepaciente en paciente formal
**Como** estudiante,
**quiero** transformar un prepaciente en un paciente real cuando decide agendarse,
**para** iniciar su expediente clínico sin volver a capturar los datos que ya tenía.

**Criterios de aceptación:**
- Desde el detalle del prepaciente existe un botón "Registrar como paciente".
- Al presionarlo, se abre la pantalla de "Nuevo Paciente" prellenada con `nombre_contacto`, `telefono` y `tratamiento_probable`.
- Al guardar el nuevo paciente, se ejecuta la lógica normal de inicialización de odontograma (32/52 piezas).
- La nota de prepaciente se actualiza automáticamente: `convertido = true` y `id_paciente_convertido` apuntando al nuevo registro.
- Desde el detalle del paciente convertido es posible ver la nota original de prepaciente como referencia histórica.

### HU-08 — Contactar a un prepaciente por WhatsApp
**Como** estudiante,
**quiero** poder escribirle por WhatsApp a un prepaciente directamente desde su nota,
**para** confirmar su interés o coordinar una cita sin salir de la app.

**Criterios de aceptación:**
- Si el prepaciente tiene `telefono` capturado, se muestra un botón de WhatsApp en el detalle de la nota.
- Al presionarlo, se abre WhatsApp con el número precargado (vía enlace `wa.me`).
- Si no hay `telefono` capturado, el botón no se muestra.

---

## Épica 3: Listas de materiales

### HU-09 — Crear una lista de materiales manualmente
**Como** estudiante,
**quiero** capturar una lista de materiales necesarios para una clínica,
**para** tener claro qué debo conseguir o llevar.

**Criterios de aceptación:**
- Existe una opción para crear una nota de `tipo = 'lista_materiales'`.
- Puedo agregar ítems con nombre, cantidad y unidad; se guardan en `items_json`.
- Puedo asociar opcionalmente la lista a una clínica (`id_clinica`).
- El `origen` se guarda como `'manual'`.

### HU-10 — Crear una lista de materiales a partir de una imagen o PDF
**Como** estudiante,
**quiero** generar una lista de materiales a partir de una foto o un PDF que ya tengo,
**para** no tener que transcribir todo a mano.

**Criterios de aceptación:**
- Puedo seleccionar una imagen o un PDF desde el dispositivo (o recibirlo por Share Intent).
- El sistema extrae texto (OCR local) e intenta reconocer ítems, cantidades y unidades.
- Antes de guardar, se muestra una pantalla de revisión donde puedo corregir o eliminar ítems mal reconocidos.
- Al confirmar, se guarda como nota `tipo = 'lista_materiales'` con `origen = 'imagen'` o `'pdf'` según corresponda.
- Ningún dato se guarda automáticamente sin pasar por la revisión manual.

### HU-11 — Registrar una cotización sobre una lista de materiales
**Como** estudiante,
**quiero** anotar la cotización de un proveedor para una lista de materiales existente,
**para** llevar el registro de precios ofrecidos.

**Criterios de aceptación:**
- Desde el detalle de una lista de materiales existe la opción "Agregar cotización".
- La cotización se guarda como nota `tipo = 'cotizacion'`, con `id_nota_relacionada` apuntando a la lista de materiales original.
- Incluye campo `proveedor` y sus propios `items_json` con precios.
- Puede capturarse manualmente o mediante imagen/PDF, igual que en HU-10.

### HU-12 — Comparar cotizaciones de una lista de materiales
**Como** estudiante,
**quiero** ver lado a lado las distintas cotizaciones recibidas para una misma lista de materiales,
**para** decidir con qué proveedor conviene comprar.

**Criterios de aceptación:**
- Desde el detalle de una lista de materiales, puedo ver todas las cotizaciones (`tipo = 'cotizacion'`) ligadas a ella mediante `id_nota_relacionada`.
- Se muestran una junto a otra (por proveedor), cada una con su propia lista de ítems y precios, sin intentar cruzar automáticamente los ítems entre cotizaciones.
- Puedo ver el total sumado de cada cotización individual.
- La comparación es de lectura visual: el usuario decide manualmente qué proveedor le conviene según lo mostrado.

### HU-13 — Listar y filtrar listas de materiales
**Como** estudiante,
**quiero** ver todas mis listas de materiales en una pantalla,
**para** encontrar rápido la que necesito según la clínica.

**Criterios de aceptación:**
- Existe una vista filtrada que muestra solo notas `tipo = 'lista_materiales'`.
- Puedo filtrar por clínica (`id_clinica`).
- Cada elemento muestra nombre/fecha y cuántas cotizaciones tiene asociadas.

---

## Fuera de alcance (para esta iteración)

- Cruce/matching automático de ítems entre distintas cotizaciones (quedó descartado a favor de comparación visual simple).
- Extracción de datos vía IA con visión (queda como posible mejora futura sobre OCR local).
- Notificaciones o recordatorios automáticos para prepacientes sin respuesta.
