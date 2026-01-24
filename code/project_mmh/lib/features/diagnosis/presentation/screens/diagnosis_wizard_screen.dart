import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: _goBack,
        ),
        title: const Text('Diagnóstico Pulpar'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Progress Indicator (Approximate)
              LinearProgressIndicator(
                value:
                    (_history.length + 1) /
                    5.0, // Rough estimate of max depth is 5
                backgroundColor: theme.colorScheme.surface,
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(4),
              ),
              const Spacer(flex: 1),

              // Question Card
              // Question Card
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
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
                child: Container(
                  key: ValueKey(
                    _currentNode,
                  ), // Triggers animation on node change
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.help_outline_rounded,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
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
              Column(
                children: [
                  _OptionButton(
                    label: questionNode.yesLabel,
                    color: theme.colorScheme.primary,
                    textColor: theme.colorScheme.onPrimary,
                    onTap: () => _answerQuestion(true),
                  ),
                  const SizedBox(height: 16),
                  _OptionButton(
                    label: questionNode.noLabel,
                    color: theme.colorScheme.surface,
                    textColor: theme.colorScheme.onSurface,
                    isOutlined: true,
                    onTap: () => _answerQuestion(false),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final bool isOutlined;

  const _OptionButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: isOutlined ? 0 : 4,
          shadowColor:
              isOutlined ? Colors.transparent : color.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side:
                isOutlined
                    ? BorderSide(color: Colors.grey.withValues(alpha: 0.3))
                    : BorderSide.none,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
