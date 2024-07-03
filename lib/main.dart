import 'package:flutter/material.dart';
import 'memory_game_logic.dart';
import 'card_model.dart';

void main() {
  runApp(MemoryGameApp());
}

class MemoryGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blueGrey,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: MemoryGameScreen(),
    );
  }
}

class MemoryGameScreen extends StatefulWidget {
  @override
  _MemoryGameScreenState createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  late MemoryGameLogic _gameLogic;
  bool _isBotTurnInProgress = false;
  List<CardModel> _botSelectedCards = [];

  @override
  void initState() {
    super.initState();
    _gameLogic = MemoryGameLogic();
  }

  void _onCardTapped(CardModel card) {
    if (_isBotTurnInProgress || (!card.isFaceUp && _gameLogic.isPlayerTurn)) {
      setState(() {
        _gameLogic.flipCard(card);
        bool matched = _gameLogic.checkForMatch();
        if (_gameLogic.isGameComplete()) {
          _showGameCompleteDialog();
        } else if (!matched && !_gameLogic.isPlayerTurn) {
          _botPlay();
        }
      });
    }
  }

  void _botPlay() async {
    setState(() {
      _isBotTurnInProgress = true;
    });

    _botSelectedCards = await _gameLogic.botTurn();

    setState(() {
      _isBotTurnInProgress = false;
      _botSelectedCards = [];
    });

    if (_gameLogic.isGameComplete()) {
      _showGameCompleteDialog();
    }
  }

  void _showGameCompleteDialog() {
    String winner;
    if (_gameLogic.playerScore > _gameLogic.botScore) {
      winner = 'Player Wins!';
    } else if (_gameLogic.botScore > _gameLogic.playerScore) {
      winner = 'Bot Wins!';
    } else {
      winner = 'It\'s a Tie!';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('$winner\nDo you want to play again?'),
          actions: <Widget>[
            TextButton(
              child: Text('Retry'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _gameLogic = MemoryGameLogic();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard(CardModel card) {
    return GestureDetector(
      onTap: () => _onCardTapped(card),
      child: Container(
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: card.isFaceUp ? Colors.white : Colors.grey[300],
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: Center(
          child: card.isFaceUp
              ? Image.asset(
                  'assets/images/${card.identifier}.png',
                  fit: BoxFit.contain,
                  height: 80.0,
                )
              : Container(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Game'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _showRetryDialog();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _gameLogic.isPlayerTurn ? 'Player\'s Turn' : 'Bot\'s Turn',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Player Score: ${_gameLogic.playerScore} - Bot Score: ${_gameLogic.botScore}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 4, // Adjust according to your screen size
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                children:
                    _gameLogic.cards.map((card) => _buildCard(card)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Retry Game'),
          content: Text('Are you sure you want to retry the game?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Retry'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _gameLogic = MemoryGameLogic();
                });
              },
            ),
          ],
        );
      },
    );
  }
}
