import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  List<PlayingCard> deck = standardFiftyTwoCardDeck();

  @override
  Widget build(BuildContext context) {
    deck.shuffle();

    return GridView.count(
      crossAxisCount: 5,
      children: [
        for ( var card in deck )
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
