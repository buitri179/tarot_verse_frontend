import 'package:flutter/material.dart';
import 'flip_card.dart';

class TarotCardWidget extends StatelessWidget {
  final Map<String, String> cardData;
  final bool isFlipped;
  final int index;
  final VoidCallback? onTap;

  const TarotCardWidget({
    super.key,
    required this.cardData,
    this.isFlipped = false,
    this.index = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final back = Container(
      width: 150,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 20)],
        image: const DecorationImage(
          image: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/5/53/RWS_Tarot_Back.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );

    final front = Container(
      width: 150,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 20)],
        image: DecorationImage(
          image: NetworkImage(cardData['img'] ?? ''),
          fit: BoxFit.cover,
        ),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: FlipCard(
        duration: const Duration(milliseconds: 700),
        front: isFlipped ? front : back,
        back: isFlipped ? back : front,
      ),
    );
  }
}
