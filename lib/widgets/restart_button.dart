import 'package:daily_pokemon_app/widgets/coins_text.dart';
import 'package:flutter/material.dart';
import '../helper/local_storage.dart';

class ResetButton extends StatelessWidget {
  final VoidCallback onReset;
  final bool isGameWon;

  const ResetButton({super.key, required this.onReset, required this.isGameWon});

  void _showConfirmationSheet(BuildContext context) async {
    final coins = await LocalStorage.getCoins();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext ctx) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber[700], size: 48),
          const SizedBox(height: 16),
          const Text(
          'Resetar tentativa?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
              'Isso custará',
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
              ),
              const SizedBox(width: 8),
              CoinsText(value: 15)
            ],
          ),
          const SizedBox(height: 8),
          Text(
          'Você tem $coins moedas.',
          style: TextStyle(fontSize: 15, color: Colors.grey),
          textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Row(
          children: [
            Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
              backgroundColor: coins >= 15
                ? Colors.redAccent
                : Colors.grey[400],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              ),
              onPressed: coins >= 15
                ? () async {
                  await LocalStorage.addCoins(-15);
                  Navigator.of(context).pop();
                  onReset();
                }
                : null,
              icon: const Icon(Icons.check),
              label: const Text('Confirmar'),
            ),
            ),
            const SizedBox(width: 16),
            Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: Colors.redAccent,
              ),
              ),
              onPressed: () {
              Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ),
          ],
          ),
        ],
        ),
      );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: isGameWon ? null : () => _showConfirmationSheet(context),
    );
  }
}
