import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CoinsText extends StatelessWidget {
  final int value;
  const CoinsText({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.monetization_on, color: Colors.yellow),
        Text('$value', style: GoogleFonts.pressStart2p(fontSize: 12)),
        const SizedBox(width: 12),
      ],
    );
  }
}
