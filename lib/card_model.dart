  class CardModel {
  final String identifier;
  bool isFaceUp;
  bool isMatched;

  CardModel({required this.identifier, this.isFaceUp = false, this.isMatched = false});
}
