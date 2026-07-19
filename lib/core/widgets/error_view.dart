import 'package:flutter/material.dart';

/// Freundliche, kindgerechte Fehleranzeige mit optionalem „Nochmal"-Knopf.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.onRetry,
    this.message = 'Ups, das hat nicht geklappt.',
  });

  final VoidCallback? onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🙈', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Nochmal'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
