import 'tarot_card.dart';

class TarotResponse {
  final List<TarotCardModel> drawnCards;
  final Map<String, String>? cardsDetail;
  final String? conclusion;

  TarotResponse({
    required this.drawnCards,
    this.cardsDetail,
    this.conclusion,
  });

  factory TarotResponse.fromJson(Map<String, dynamic> json) {
    print('🔍 JSON received: $json');

    List<TarotCardModel> parsedCards = [];

    if (json.containsKey('drawn_cards')) {
      parsedCards = (json['drawn_cards'] as List<dynamic>?)
          ?.map((cardJson) =>
          TarotCardModel.fromJson(cardJson as Map<String, dynamic>))
          .toList() ??
          [];
    } else if (json.containsKey('cards')) {
      final names = List<String>.from(json['cards']);
      parsedCards = names.map((name) {
        return TarotCardModel(
          name: name,
          uprightMeaning: '',
          reversedMeaning: '',
          description: '',
          imageUrl: 'assets/images/default_card.png',
        );
      }).toList();
    }

    return TarotResponse(
      drawnCards: parsedCards,
      cardsDetail: json['cards_detail'] != null
          ? Map<String, String>.from(json['cards_detail'])
          : null,
      conclusion: json['conclusion'] as String?,
    );
  }
}
