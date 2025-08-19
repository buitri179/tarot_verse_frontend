import '../models/tarot_card.dart';

/// Đây chỉ là data mẫu, bạn có thể mở rộng thêm tất cả 78 lá Tarot.
final List<TarotCardModel> tarotCardsData = [
  TarotCardModel(
    id: 0,
    name: "The Fool",
    image: "https://i.imgur.com/5Z3Q2Zr.png", // link ảnh hoặc assets
    meanings: {
      "love": "Khởi đầu mới trong tình cảm.",
      "career": "Cơ hội mới, chưa chắc chắn.",
      "general": "Hành trình mới, sự ngây thơ, tò mò.",
    },
  ),
  TarotCardModel(
    id: 1,
    name: "The Magician",
    image: "https://i.imgur.com/JQ9p7xD.png",
    meanings: {
      "love": "Tự tin trong tình yêu.",
      "career": "Khả năng biến ý tưởng thành hiện thực.",
      "general": "Sức mạnh ý chí và sự sáng tạo.",
    },
  ),
  // TODO: thêm các lá khác vào đây...
];
