import 'package:flutter/material.dart';

/// Base class for any node in the diagnosis decision tree.
abstract class DiagnosisNode {
  const DiagnosisNode();
}

/// A node representing a binary question.
class QuestionNode extends DiagnosisNode {
  final String question;
  final DiagnosisNode yesNextStep;
  final DiagnosisNode noNextStep;
  final String yesLabel;
  final String noLabel;

  const QuestionNode({
    required this.question,
    required this.yesNextStep,
    required this.noNextStep,
    this.yesLabel = 'Sí',
    this.noLabel = 'No',
  });
}

/// A node representing a leaf/result in the tree.
class DiagnosisResultNode extends DiagnosisNode {
  final String title;
  final String description;
  final Color color;
  final String? treatmentRecommendation;

  const DiagnosisResultNode({
    required this.title,
    required this.description,
    required this.color,
    this.treatmentRecommendation,
  });
}
