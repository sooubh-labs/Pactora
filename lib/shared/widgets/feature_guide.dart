import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class GuideStep {
  final GlobalKey targetKey;
  final String title;
  final String description;

  GuideStep({required this.targetKey, required this.title, required this.description});
}

class FeatureGuide extends StatefulWidget {
  final List<GuideStep> steps;
  final VoidCallback onComplete;

  const FeatureGuide({super.key, required this.steps, required this.onComplete});

  @override
  State<FeatureGuide> createState() => _FeatureGuideState();
}

class _FeatureGuideState extends State<FeatureGuide> {
  int _currentStepIndex = 0;

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentStepIndex];
    final RenderBox? renderBox = step.targetKey.currentContext?.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final size = renderBox?.size ?? Size.zero;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dark overlay with hole
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Positioned(
                  left: offset.dx - 8,
                  top: offset.dy - 8,
                  child: Container(
                    width: size.width + 16,
                    height: size.height + 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Instruction Bubble
          Positioned(
            left: 24,
            right: 24,
            top: offset.dy + size.height + 24, // Basic positioning, may need adjustment for bottom elements
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Gap(8),
                  Text(
                    step.description,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const Gap(24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: widget.onComplete,
                        child: const Text('Skip'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_currentStepIndex < widget.steps.length - 1) {
                            setState(() => _currentStepIndex++);
                          } else {
                            widget.onComplete();
                          }
                        },
                        child: Text(_currentStepIndex == widget.steps.length - 1 ? 'Finish' : 'Next'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
