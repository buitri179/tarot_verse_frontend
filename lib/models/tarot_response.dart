// File: models/tarot_response.dart
import 'tarot_card.dart';

/// Class mô tả cấu trúc dữ liệu mà API trả về.
/// Bao gồm các lá bài đã rút, diễn giải chi tiết và kết luận chung.
class TarotResponse {
  final List<TarotCardModel> drawnCards; // Các lá bài được backend rút
  final Map<String, String>? cardsDetail; // Diễn giải chi tiết từng lá bài theo AI
  final String? conclusion;               // Kết luận chung

  TarotResponse({
    required this.drawnCards,
    this.cardsDetail,
    this.conclusion,
  });

  /// Factory constructor để tạo đối tượng TarotResponse từ JSON.
  factory TarotResponse.fromJson(Map<String, dynamic> json) {
    // In ra toàn bộ JSON nhận được để dễ debug
    print('🔍 JSON received: $json');

    // Chuyển đổi danh sách JSON của các lá bài thành List<TarotCardModel>
    // Giả sử backend trả về key 'drawn_cards' chứa list các object lá bài
    final List<TarotCardModel> parsedCards = (json['drawn_cards'] as List<dynamic>?)
            ?.map((cardJson) =>
                TarotCardModel.fromJson(cardJson as Map<String, dynamic>))
            .toList() ??
        [];

    return TarotResponse(
      drawnCards: parsedCards,
      // Lấy chi tiết từng lá bài từ key 'cards_detail'
      cardsDetail: json['cards_detail'] != null
          ? Map<String, String>.from(json['cards_detail'])
          : null,
      // Lấy kết luận từ key 'conclusion'
      conclusion: json['conclusion'] as String?,
    );
  }
}
