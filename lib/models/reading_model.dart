import 'dart:convert';
import 'package:intl/intl.dart';

class Reading {
  final int id;
  final String question;
  final String cards;
  final String interpretation;
  final DateTime createdAt;

  const Reading({
    this.id = 0,
    required this.question,
    required this.cards,
    required this.interpretation,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'cards': cards,
      'interpretation': interpretation,
      'createdAt': DateFormat('yyyy-MM-ddTHH:mm:ss').format(createdAt),
    };
  }

  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      id: json['id'] as int,
      question: json['question'] as String,
      cards: json['cards'] as String,
      interpretation: json['interpretation'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
