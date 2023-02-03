import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

class SelectedCard {
  final PlayingCard card;
  final int position;

  SelectedCard(this.card, this.position);
}

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  List<PlayingCard> deck = standardFiftyTwoCardDeck();

  List<PlayingCard> displayedCards = [];
  List<PlayingCard> remainingCards = [];
  List<PlayingCard> discardedCards = [];

  Map<int, double> elevations = {};

  SelectedCard? selectedCard1;
  SelectedCard? selectedCard2;

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
    initElevations();
  }

  void initGame() {
    deck.shuffle();
    initDisplayedCards();
    initRemainingCards();
  }

  void initElevations() {
    for (var i = 0; i < DISPLAYED_CARDS_NUMBER; i++) {
      elevations[i] = 0;
    }
  }

  void initDisplayedCards() {
    setState(() {
      displayedCards = deck.take(DISPLAYED_CARDS_NUMBER).toList();
    });
  }

  void updateDisplayedCards() {
    displayedCards = displayedCards.where((card) => card.suit != Suit.joker).toList();
    
    int necessaryCardsNumber = DISPLAYED_CARDS_NUMBER - displayedCards.length;

    displayedCards = [
      ...displayedCards,
      ...remainingCards.take(necessaryCardsNumber)
    ];

    remainingCards = remainingCards.sublist(necessaryCardsNumber);
  }

  void initRemainingCards() {
    setState(() {
      remainingCards = deck.reversed.take(TOTAL_CARDS_NUMBER - DISPLAYED_CARDS_NUMBER).toList();
    });
  }

  // x-6 x-5 x-4
  // x-1  x  x+1
  // x+4 x+5 x+6
  bool arePositionsAdjacent(int position1, int position2) {
    List<int> adjacentPositions = [
      position1 - 6,
      position1 - 5,
      position1 - 4,
      position1 - 1,
      position1 + 1,
      position1 + 4,
      position1 + 5,
      position1 + 6
    ];

    return adjacentPositions.contains(position2);
  }

  bool areValuesIdentical(PlayingCard card1, PlayingCard card2) {
    return card1.value == card2.value;
  }

  void selectCard(PlayingCard card, int position) {
    if (selectedCard1 == null) {
      selectedCard1 = new SelectedCard(card, position);
      setState(() {
        elevations[position] = 10;
      });
      return;
    }

    if (selectedCard1?.card?.suit.name != card.suit.name || selectedCard1?.card?.value.name != card.value.name) {
      selectedCard2 = new SelectedCard(card, position);
      setState(() {
        elevations[position] = 10;
      });
    }

    print('selected card 1: ${selectedCard1?.card.suit.name}, ${selectedCard1?.card.value.name}');
    print('selected card 2: ${selectedCard2?.card.suit.name}, ${selectedCard2?.card.value.name}');
    
    if (selectedCard1?.position != null && selectedCard2?.position != null) {
      int pos1 = selectedCard1?.position as int;
      int pos2 = selectedCard2?.position as int;

      PlayingCard card1 = selectedCard1?.card as PlayingCard;
      PlayingCard card2 = selectedCard2?.card as PlayingCard;

      if (arePositionsAdjacent(pos1, pos2) && areValuesIdentical(card1, card2)) {
        print('adjacent!');
        // replace them with joker

        discardedCards.add(card1);
        discardedCards.add(card2);

        displayedCards[pos1] = PlayingCard(Suit.joker, CardValue.joker_1);
        displayedCards[pos2] = PlayingCard(Suit.joker, CardValue.joker_1);
      } else {
        print('NOT adjacent!');
      }

      selectedCard1 = null;
      selectedCard2 = null;

      initElevations();
    }
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
              print('Card: ${(cardEntry.value as PlayingCard).suit.name}, ${(cardEntry.value as PlayingCard).value.name}');
              print('Index: ${cardEntry.key.toString()}');
              selectCard(cardEntry.value as PlayingCard, cardEntry.key);
            },
            child: Container(
              child: PlayingCardView(
                card: PlayingCard(cardEntry.value.suit, cardEntry.value.value),
                style: cardStyles,
                elevation: elevations[cardEntry.key]
              )
            ),
          )
        ]
      ),
    );
  }
}
