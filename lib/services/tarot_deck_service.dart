import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tarot_card.dart';

class TarotDeckService {
  static const String _deckEndpoint = 'http://localhost:8080/api/tarot/random-cards';

  Future<List<TarotCardModel>> fetchRandomCards() async {
    final res = await http.post(Uri.parse(_deckEndpoint));
    if (res.statusCode != 200) {
      throw Exception('Không thể lấy bài từ backend. Status: ${res.statusCode}');
    }

    final body = json.decode(utf8.decode(res.bodyBytes));
    final List cardsJson = body['cards'] ?? [];

    return cardsJson.map<TarotCardModel>((j) => TarotCardModel.fromJson(j)).toList();
  }
}
