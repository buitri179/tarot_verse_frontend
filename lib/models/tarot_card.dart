import 'package:flutter/foundation.dart';

@immutable
class TarotCardModel {
  final String name;
  final String uprightMeaning;
  final String reversedMeaning;
  final String description;
  final String imageUrl;

  const TarotCardModel({
    required this.name,
    required this.uprightMeaning,
    required this.reversedMeaning,
    required this.description,
    required this.imageUrl,
  });

  // Factory constructor để tạo một instance từ JSON
  factory TarotCardModel.fromJson(Map<String, dynamic> json) {
    return TarotCardModel(
      name: json['name'] as String,
      uprightMeaning: json['uprightMeaning'] as String,
      reversedMeaning: json['reversedMeaning'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }
}
