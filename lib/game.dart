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

  static int displayedCardsNumber = 25;
  static int totalCardsNumber = 52;
  static double cardAspectRatio = 64.0 / 89.0;

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
    for (var i = 0; i < displayedCardsNumber; i++) {
      elevations[i] = 0;
    }
  }

  void initDisplayedCards() {
    setState(() {
      displayedCards = deck.take(displayedCardsNumber).toList();
    });
  }

  void updateDisplayedCards() {
    List<PlayingCard> remainingDisplayedCards = displayedCards.where((card) {
      return card.suit != Suit.joker;
    }).toList();
    
    int necessaryCardsNumber = displayedCardsNumber - remainingDisplayedCards.length;

    setState(() {
      displayedCards = [
        ...remainingDisplayedCards,
        ...remainingCards.take(necessaryCardsNumber)
      ];

    });

    setState(() {
      remainingCards = remainingCards.sublist(necessaryCardsNumber);
    });
  }

  void initRemainingCards() {
    setState(() {
      remainingCards = deck.reversed.take(totalCardsNumber - displayedCardsNumber).toList();
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
      selectedCard1 = SelectedCard(card, position);
      setState(() {
        elevations[position] = 10;
      });
      return;
    }

    if (selectedCard1?.card?.suit.name != card.suit.name || selectedCard1?.card?.value.name != card.value.name) {
      selectedCard2 = SelectedCard(card, position);
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
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: GridView.count(
              childAspectRatio: cardAspectRatio,
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
                    child: cardEntry.value.suit != Suit.joker
                      ? PlayingCardView(
                        card: PlayingCard(cardEntry.value.suit, cardEntry.value.value),
                        style: cardStyles,
                        elevation: elevations[cardEntry.key]
                      )
                      : Container()
                  ),
                )
              ]
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: updateDisplayedCards,
                  child: Container(
                    child: Stack(
                      children: [
                        for (var card in remainingCards)
                        PlayingCardView(
                          card: PlayingCard(card.suit, card.value),
                          style: cardStyles,
                          showBack: true
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Stack(
                    children: [
                      for (var card in discardedCards)
                      PlayingCardView(
                        card: PlayingCard(card.suit, card.value),
                        style: cardStyles,
                        showBack: false
                      )
                    ]
                  )
                )
              ]
            )
          )
        ]
      ),
    );
  }
}
