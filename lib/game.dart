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

  static int DISPLAYED_CARDS_NUMBER = 25;
  static int TOTAL_CARDS_NUMBER = 52;

  PlayingCardViewStyle cardStyles = PlayingCardViewStyle(
    cardBackContentBuilder: (context) => Image.asset(
      "assets/card_back.png",
      fit: BoxFit.fill,
      filterQuality: FilterQuality.high
    )
  );
  
  @override
  void initState()
  {
    super.initState();
    initGame();
  }

  void initGame() {
    deck.shuffle();
    initDisplayedCards();
    initRemainingCards();
  }

  void initDisplayedCards() {
    setState(() {
      displayedCards = deck.take(DISPLAYED_CARDS_NUMBER).toList();
    });
  }

  void initRemainingCards() {
    setState(() {
      remainingCards = deck.reversed.take(TOTAL_CARDS_NUMBER - DISPLAYED_CARDS_NUMBER).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: GridView.count(
        crossAxisCount: 5,
        children: [
          for (MapEntry cardEntry in displayedCards.asMap().entries)
          GestureDetector(
            onTap: () {
              print('Suit: ${(cardEntry.value as PlayingCard).suit.name}');
              print('Value: ${(cardEntry.value as PlayingCard).value.name}');
              print('Index: ${cardEntry.key.toString()}');
            },
            child: Container(
              child: PlayingCardView(
                card: PlayingCard(cardEntry.value.suit, cardEntry.value.value),
                style: cardStyles
              )
            ),
          )
        ]
      ),
    );
  }
}
