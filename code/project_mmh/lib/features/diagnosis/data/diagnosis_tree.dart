import 'package:flutter/material.dart';
import 'package:project_mmh/features/diagnosis/domain/models/node.dart';

class DiagnosisTree {
  static const DiagnosisNode root = _hasPain;

  // --- LEAVES (Resultados) ---

  static const DiagnosisResultNode abscesoApicalAgudo = DiagnosisResultNode(
    title: 'Absceso Apical Agudo',
    description:
        'Dolor pulsátil y severo. Inflamación de tejidos blando. Pruebas térmicas negativas.',
    color: Color(0xFFE91E63), // Pink
  );

  static const DiagnosisResultNode pulpitisReversible = DiagnosisResultNode(
    title: 'Pulpitis Reversible',
    description:
        'Dolor agudo momentáneo. Cesa inmediatamente al retirar estímulo.',
    color: Color(0xFF8BC34A), // LightGreen
  );

  static const DiagnosisResultNode
  pulpitisIrreversibleSintomatica = DiagnosisResultNode(
    title: 'Pulpitis Irreversible Sintomática',
    description:
        'Dolor prolongado tras estímulo térmico. Reacción intensa / Dolor penetrante, punzante o nocturno.',
    color: Color(0xFFFF9800), // Orange
  );

  static const DiagnosisResultNode
  periodontitisApicalSintomatica = DiagnosisResultNode(
    title: 'Periodontitis Apical Sintomática',
    description:
        'Dolor severo localizado. Sensibilidad a la palpación/percusión. Sensación de "diente largo".',
    color: Color(0xFFFF5722), // OrangeRed
  );

  static const DiagnosisResultNode
  pulpitisIrreversibleAsintomatica = DiagnosisResultNode(
    title: 'Pulpitis Irreversible Asintomática',
    description:
        'Inflamación persistente sin síntomas agudos. Pruebas térmicas anormales.',
    color: Color(0xFFFFEB3B), // Yellow
  );

  static const DiagnosisResultNode osteitisCondensante = DiagnosisResultNode(
    title: 'Osteítis Condensante',
    description: 'Respuesta a inflamación leve crónica. Hallazgo radiográfico.',
    color: Color(0xFF03A9F4), // LightBlue
  );

  static const DiagnosisResultNode pulpaNormal = DiagnosisResultNode(
    title: 'Pulpa Normal',
    description: 'Sin síntomas. Responde normal a pruebas.',
    color: Color(0xFF4CAF50), // Green (similar to LightGreen but distinct)
  );

  static const DiagnosisResultNode
  periodontitisApicalAsintomatica = DiagnosisResultNode(
    title: 'Periodontitis Apical Asintomática',
    description:
        'Secuela de periodontitis sintomática. Cambios radiolúcidos perirradiculares.',
    color: Color(0xFFBDBDBD), // LightGray
  );

  static const DiagnosisResultNode necrosisPulpar = DiagnosisResultNode(
    title: 'Necrosis Pulpar',
    description:
        'Muerte pulpar. No responde a sensibilidad. Puede haber cambio de coloración.',
    color: Color(0xFF9E9E9E), // Gray
  );

  // --- DECISION TREE LOGIC ---

  // 1. ¿El paciente presenta DOLOR actualmente?
  static const QuestionNode _hasPain = QuestionNode(
    question: '¿El paciente presenta dolor actualmente?',
    yesNextStep: _hasSwellingOrFever,
    noNextStep: _hasResponseToTests,
    yesLabel: 'SÍ - Sintomático',
    noLabel: 'NO - Asintomático',
  );

  // --- BRANCH: SÍ - Sintomático ---

  // 1.1 ¿Existe inflamación visible, pus o fiebre?
  static const QuestionNode _hasSwellingOrFever = QuestionNode(
    question: '¿Existe inflamación visible, pus o fiebre?',
    yesNextStep: abscesoApicalAgudo,
    noNextStep: _isPainProvokedOrSpontaneous,
  );

  // 1.1.2 ¿El dolor es provocado o espontáneo?
  static const QuestionNode _isPainProvokedOrSpontaneous = QuestionNode(
    question: '¿El dolor es provocado o espontáneo?',
    yesNextStep: _painDurationAfterStimulus,
    noNextStep: _painLocalization,
    yesLabel: 'Solo Provocado',
    noLabel: 'Espontáneo / Constante',
  );

  // 1.1.2.1 (Provoked) -> Aplicar estímulo -> ¿Cuánto dura el dolor al retirar el estímulo?
  static const QuestionNode _painDurationAfterStimulus = QuestionNode(
    question:
        'Tras aplicar estímulo (frío/calor),\n¿cuánto dura el dolor al retirarlo?',
    yesNextStep: pulpitisReversible,
    noNextStep: pulpitisIrreversibleSintomatica,
    yesLabel: 'Segundos',
    noLabel: 'Minutos / Persistente',
  );

  // 1.1.2.2 (Spontaneous) -> ¿Dolor localizado al masticar o percusión?
  static const QuestionNode _painLocalization = QuestionNode(
    question: '¿Dolor localizado al masticar o percusión?',
    yesNextStep: periodontitisApicalSintomatica,
    noNextStep: pulpitisIrreversibleSintomatica,
    yesLabel: 'SÍ',
    noLabel: 'NO / Difuso',
  );

  // --- BRANCH: NO - Asintomático ---

  // 2. Realizar Pruebas de Sensibilidad -> ¿Hay respuesta a las pruebas?
  static const QuestionNode _hasResponseToTests = QuestionNode(
    question: 'Realiza pruebas de sensibilidad (Frío/Calor).\n¿Hay respuesta?',
    yesNextStep: _isResponseAbnormal,
    noNextStep: _radiolucentArea, // No Vital
    yesLabel: 'SÍ - Vital',
    noLabel: 'NO - No Vital/Negativa',
  );

  // 2.1 (Vital) -> ¿La respuesta es anormal o retardada?
  static const QuestionNode _isResponseAbnormal = QuestionNode(
    question: '¿La respuesta es anormal o retardada?',
    yesNextStep: pulpitisIrreversibleAsintomatica,
    noNextStep: _radiopaqueArea, // Respuesta Normal
  );

  // 2.1.2 (Normal Response) -> Evaluar Radiografía -> ¿Se observa zona radiopaca/condensada?
  static const QuestionNode _radiopaqueArea = QuestionNode(
    question: 'En la radiografía, ¿se observa zona radiopaca/condensada?',
    yesNextStep: osteitisCondensante,
    noNextStep: pulpaNormal,
  );

  // 2.2 (No Vital) -> Evaluar Radiografía -> ¿Se observa zona radiolúcida apical?
  static const QuestionNode _radiolucentArea = QuestionNode(
    question: 'En la radiografía, ¿se observa zona radiolúcida apical?',
    yesNextStep: periodontitisApicalAsintomatica,
    noNextStep: necrosisPulpar,
  );
}
