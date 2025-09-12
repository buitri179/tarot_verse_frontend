
import 'package:tarot_verse_frontend/models/tarot_card.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/star_field.dart';

class CardMeaningScreen extends StatefulWidget {
  const CardMeaningScreen({super.key});

  @override
  State<CardMeaningScreen> createState() => _CardMeaningScreenState();
}

class _CardMeaningScreenState extends State<CardMeaningScreen> {
  late Future<List<TarotCardModel>> tarotCardsFuture;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    tarotCardsFuture = loadTarotCards();
  }

  Future<List<TarotCardModel>> loadTarotCards() async {
    final String response =
    await rootBundle.loadString('assets/tarot_cards.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => TarotCardModel.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // body trải ra dưới AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.yellow),
          onPressed: () {
            Navigator.pop(context); // giống AuthScreen, pop về trang trước
          },
        ),
        title: const Text(
          'Ý Nghĩa Các Lá Bài Tarot',
          style: TextStyle(color: Colors.yellow),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const StarField(), // giữ background như LandingScreen
          SafeArea(
            child: FutureBuilder<List<TarotCardModel>>(
              future: tarotCardsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Lỗi khi tải dữ liệu: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có dữ liệu.'));
                }

                final tarotCards = snapshot.data!;
                final majorArcana = tarotCards.take(22).toList();
                final minorArcana = tarotCards.skip(22).toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60), // tránh AppBar
                      const Text(
                        'Ẩn Chính (Major Arcana)',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      _buildGrid(majorArcana, 0),
                      const SizedBox(height: 20),
                      const Text(
                        'Ẩn Phụ (Minor Arcana)',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      _buildGrid(minorArcana, 22),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<TarotCardModel> cards, int startIndex) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        final globalIndex = startIndex + index;
        final isSelected = selectedIndex == globalIndex;

        return FlipCardWidget(
          card: card,
          isSelected: isSelected,
          onSelected: () {
            setState(() {
              selectedIndex = globalIndex;
            });
          },
        );
      },
    );
  }
}

// FlipCardWidget giữ nguyên như trước, có nút "Xem chi tiết" và "Lật lại"
class FlipCardWidget extends StatefulWidget {
  final TarotCardModel card;
  final bool isSelected;
  final VoidCallback? onSelected;

  const FlipCardWidget({
    super.key,
    required this.card,
    this.isSelected = false,
    this.onSelected,
  });

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    setState(() {
      isFlipped = !isFlipped;
      if (isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onSelected?.call();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double angle = _controller.value * 3.1416;
          final isFront = _controller.value < 0.5;

          return Transform(
            transform: Matrix4.rotationY(angle),
            alignment: Alignment.center,
            child: isFront
                ? _buildCardFront()
                : Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.1416),
              child: _buildCardBack(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardFront() {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.isSelected)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        Card(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(widget.card.imageUrl, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    Text(widget.card.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    if (widget.isSelected)
                      ElevatedButton(
                        onPressed: _flipCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple[900],
                        ),
                        child: const Text('Xem chi tiết'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardBack() {
    return Card(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(widget.card.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text('Upright: ${widget.card.uprightMeaning}',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.green)),
                    const SizedBox(height: 4),
                    Text('Reversed: ${widget.card.reversedMeaning}',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.red)),
                    const SizedBox(height: 6),
                    Text(widget.card.description,
                        style: const TextStyle(fontSize: 12, color: Colors.white)),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _flipCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[900],
              ),
              child: const Text('Lật lại'),
            ),
          ],
        ),
      ),
    );
  }
}


