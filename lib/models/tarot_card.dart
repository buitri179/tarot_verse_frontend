class TarotCardModel {
  final int id;
  final String name;
  final String image;
  final Map<String, String> meanings;

  const TarotCardModel({
    required this.id,
    required this.name,
    required this.image,
    required this.meanings,
  });

  TarotCardModel copyWith({
    int? id,
    String? name,
    String? image,
    Map<String, String>? meanings,
  }) {
    return TarotCardModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      meanings: meanings ?? this.meanings,
    );
  }
}