import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/diagnosis/data/diagnosis_tree.dart';
import 'package:project_mmh/features/diagnosis/domain/models/node.dart';
import 'package:project_mmh/features/diagnosis/presentation/screens/diagnosis_result_screen.dart';

class DiagnosisWizardScreen extends StatefulWidget {
  const DiagnosisWizardScreen({super.key});

  @override
  State<DiagnosisWizardScreen> createState() => _DiagnosisWizardScreenState();
}

class _DiagnosisWizardScreenState extends State<DiagnosisWizardScreen> {
  // Stack to store history of visited nodes for "Back" functionality
  final List<QuestionNode> _history = [];

  // Current active node
  DiagnosisNode _currentNode = DiagnosisTree.root;

  void _answerQuestion(bool isYes) {
    if (_currentNode is! QuestionNode) return;

    final questionNode = _currentNode as QuestionNode;

    setState(() {
      _history.add(questionNode);
      _currentNode = isYes ? questionNode.yesNextStep : questionNode.noNextStep;
    });
  }

  void _goBack() {
    if (_history.isEmpty) {
      context.pop();
      return;
    }

    setState(() {
      _currentNode = _history.removeLast();
    });
  }

  void _restart() {
    setState(() {
      _history.clear();
      _currentNode = DiagnosisTree.root;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If the current node is a result, show the result screen
    if (_currentNode is DiagnosisResultNode) {
      return DiagnosisResultScreen(
        result: _currentNode as DiagnosisResultNode,
        onRestart: _restart,
      );
    }

    final questionNode = _currentNode as QuestionNode;
    final theme = Theme.of(context);

    // Preserva la semántica original de `_goBack`: si hay historial, retrocede
    // un paso en el árbol; si no lo hay, sale de la pantalla (equivalente al
    // `context.pop()` previo). PopScope intercepta tanto el botón atrás de la
    // cabecera como el gesto/botón atrás del sistema.
    return PopScope(
      canPop: _history.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _goBack();
      },
      child: AppScaffold(
        title: 'Diagnóstico Pulpar',
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    // Progress Indicator (Approximate)
                    LinearProgressIndicator(
                      value:
                          (_history.length + 1) /
                          5.0, // Rough estimate of max depth is 5
                      backgroundColor: theme.colorScheme.surface,
                      valueColor: AlwaysStoppedAnimation(
                        theme.colorScheme.primary,
                      ),
                      borderRadius: AppRadii.smAll,
                    ),
                    const Spacer(flex: 1),

                    // Question Card
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                      ) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.05),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: AppCard(
                        // Triggers animation on node change
                        key: ValueKey(_currentNode),
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.help_outline_rounded,
                              size: 48,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Text(
                              questionNode.question,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Answer Buttons
                    SizedBox(
                      width: double.infinity,
                      child: AppButton.primary(
                        label: questionNode.yesLabel,
                        onPressed: () => _answerQuestion(true),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton.secondary(
                        label: questionNode.noLabel,
                        onPressed: () => _answerQuestion(false),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
