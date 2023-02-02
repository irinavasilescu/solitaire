import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  List<PlayingCard> deck = standardFiftyTwoCardDeck();

  late List<PlayingCard> displayedCards;
  late List<PlayingCard> remainingCards;
  late List<PlayingCard> discardedCards;

  @override
  void initState()
  {
    super.initState();
    initGame();
  }

  void initGame() {
    deck.shuffle();
    initDisplayedCards();
  }

  void initDisplayedCards() {
    setState(() {
      displayedCards = deck.take(25).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 5,
      children: [
        for (var card in displayedCards)
        Container(
          height: 75,
          child: PlayingCardView(
            card: PlayingCard(card.suit, card.value)
          )
        )
      ]
    );
  }
}
