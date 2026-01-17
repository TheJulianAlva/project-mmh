# Documentación de Diseño: Odontograma Universal

Este documento detalla la estructura lógica y visual para la representación de estados y condiciones dentales en el odontograma del sistema MMH.

## 1. Fundamentos del Odontograma

El odontograma sigue los estándares internacionales para la representación gráfica de la dentadura, permitiendo una lectura rápida del historial y estado actual del paciente.

---

## 2. Estructura de Estados y Condiciones

Los estados se dividen en dos categorías principales: **Globales** (afectan a todo el diente) y **Por Superficie** (específicos de una cara dental).

### 2.1 Estados Globales (Nivel Diente)

Afectan la integridad o posición de la pieza completa.

| Estado | Descripción | Representación Gráfica |
| :--- | :--- | :--- |
| **Sano** | Pieza sin patologías ni tratamientos. | Sin marcas adicionales. |
| **Ausente** | El diente no está presente en la boca. | Una "X" azul sobre el esquema del diente. |
| **Por Extraer** | Pieza con indicación de exodoncia. | Una "X" roja sobre el esquema del diente. |
| **Prótesis Fija** | Puente o estructura conectada. | Líneas que unen las piezas pilares con los pónticos. |
| **Erupción** | Diente en proceso de salida. | Flecha azul apuntando hacia oclusal. |

### 2.2 Estados por Superficie (Nivel Caras)

Se aplican a las 5 superficies: **Vestibular, Lingual/Palatina, Mesial, Distal y Oclusal/Incisal**.

| Condición | Descripción | Representación Gráfica |
| :--- | :--- | :--- |
| **Caries** | Lesión cariosa activa. | Superficie pintada de color **rojo** sólido. |
| **Obturación** | Resina, amalgama o restauración previa. | Superficie pintada de color **azul** sólido. |
| **Sellante** | Sellante de fosetas y fisuras. | Letra "S" azul sobre la cara. |
| **Fractura** | Pérdida de tejido por traumatismo. | Línea roja en zigzag sobre la zona afectada. |

---

## 3. Lógica de Interacción (UX)

Para garantizar consistencia en la captura de datos:

1. **Prioridad de Visualización:**
   - Si un diente está marcado como **Ausente**, se deshabilitan las interacciones por superficie.
2. **Practicidad:** Si se aplica un estado sobre el diente y se vuelve a aplicar, se deshace el estado anterior y vuelve al estado sano.
3. **Interacción con puente / prótesis fija:**
   - Si un diente está marcado como **Prótesis Fija**, se deshabilitan las interacciones por superficie.
   - Al seleccionar **Prótesis Fija**, la primer interacción es seleccionar el inicio del puente y la segunda es seleccionar el final del puente, todos los dientes entre los seleccionados se marcarán como prótesis fija con id del puente.
   - El inicio y final del puente deben pertenecer al mismo paladar (arriba / abajo); si se intenta seleccionar un inicio y final en paladares diferentes, se debe reiniciar la interacción y colocar la selección como primer interacción.
   - Los puentes solamente se ilustran como una línea o corchete cuadrado que une los dientes seleccionados.
