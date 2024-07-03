import 'dart:math';
import 'card_model.dart';

class MemoryGameLogic {
  List<CardModel> _cards = [];
  bool _isPlayerTurn = true;
  int _playerScore = 0;
  int _botScore = 0;

  MemoryGameLogic() {
    _initializeCards();
  }

  void _initializeCards() {
    final identifiers = [
      '2_of_clubs', '2_of_diamonds', '2_of_hearts', '2_of_spades',
      '3_of_clubs', '3_of_diamonds', '3_of_hearts', '3_of_spades',
      // Add more Poker cards as needed
    ];
    _cards = [];
    for (var id in identifiers) {
      _cards.add(CardModel(identifier: id));
      _cards.add(CardModel(identifier: id));
    }
    _cards.shuffle();
  }

  List<CardModel> get cards => _cards;
  bool get isPlayerTurn => _isPlayerTurn;
  int get playerScore => _playerScore;
  int get botScore => _botScore;

  void flipCard(CardModel card) {
    card.isFaceUp = !card.isFaceUp;
  }

  bool checkForMatch() {
    List<CardModel> faceUpCards =
        _cards.where((card) => card.isFaceUp && !card.isMatched).toList();
    if (faceUpCards.length == 2) {
      if (faceUpCards[0].identifier == faceUpCards[1].identifier) {
        faceUpCards[0].isMatched = true;
        faceUpCards[1].isMatched = true;
        if (_isPlayerTurn) {
          _playerScore++;
        } else {
          _botScore++;
        }
        return true;
      } else {
        faceUpCards[0].isFaceUp = false;
        faceUpCards[1].isFaceUp = false;
        _isPlayerTurn = !_isPlayerTurn;
        return false;
      }
    }
    return true;
  }

  Future<List<CardModel>> botTurn() async {
    List<CardModel> botSelectedCards = [];
    while (!_isPlayerTurn) {
      List<CardModel> unmatchedCards =
          _cards.where((card) => !card.isMatched && !card.isFaceUp).toList();
      if (unmatchedCards.length <= 1) {
        break;
      }

      Random random = Random();
      CardModel firstCard =
          unmatchedCards[random.nextInt(unmatchedCards.length)];
      CardModel secondCard;
      do {
        secondCard = unmatchedCards[random.nextInt(unmatchedCards.length)];
      } while (firstCard == secondCard);

      botSelectedCards.add(firstCard);
      botSelectedCards.add(secondCard);

      flipCard(firstCard);
      flipCard(secondCard);

      await Future.delayed(
          Duration(seconds: 1)); // Delay to show the bot's selection

      bool matched = checkForMatch();
      if (!matched) {
        break;
      }
    }
    return botSelectedCards;
  }

  bool isGameComplete() {
    return _cards.every((card) => card.isMatched);
  }
}
