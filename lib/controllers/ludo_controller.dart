import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ludo_models.dart';
import '../constants.dart';
import 'auth_controller.dart';

enum PlayerColor { red, green, yellow, blue }
enum GameMode { computer, local }

class LudoController extends GetxController {
  var diceValue = 1.obs;
  var isRolling = false.obs;
  var currentPlayer = PlayerColor.red.obs;
  var playerCount = 4.obs;
  var gameMode = GameMode.local.obs;

  // Game State
  var tokens = <TokenModel>[].obs;
  var canRollDice = true.obs;
  var moveAbleTokens = <TokenModel>[].obs;
  var consecutiveSixes = 0;

  static const List<Offset> boardPath = [
    Offset(6, 0), Offset(6, 1), Offset(6, 2), Offset(6, 3), Offset(6, 4), Offset(6, 5), // 0-5
    Offset(5, 6), Offset(4, 6), Offset(3, 6), Offset(2, 6), Offset(1, 6), Offset(0, 6), // 6-11
    Offset(0, 7), // 12
    Offset(0, 8), Offset(1, 8), Offset(2, 8), Offset(3, 8), Offset(4, 8), Offset(5, 8), // 13-18
    Offset(6, 9), Offset(6, 10), Offset(6, 11), Offset(6, 12), Offset(6, 13), Offset(6, 14), // 19-24
    Offset(7, 14), // 25
    Offset(8, 14), Offset(8, 13), Offset(8, 12), Offset(8, 11), Offset(8, 10), Offset(8, 9), // 26-31
    Offset(9, 8), Offset(10, 8), Offset(11, 8), Offset(12, 8), Offset(13, 8), Offset(14, 8), // 32-37
    Offset(14, 7), // 38
    Offset(14, 6), Offset(13, 6), Offset(12, 6), Offset(11, 6), Offset(10, 6), Offset(9, 6), // 39-44
    Offset(8, 5), Offset(8, 4), Offset(8, 3), Offset(8, 2), Offset(8, 1), Offset(8, 0), // 45-50
    Offset(7, 0), // 51
  ];

  static const Map<PlayerColor, int> startIndices = {
    PlayerColor.red: 1,
    PlayerColor.green: 14,
    PlayerColor.yellow: 27,
    PlayerColor.blue: 40,
  };

  static const Map<PlayerColor, List<Offset>> homePaths = {
    PlayerColor.red: [Offset(7, 1), Offset(7, 2), Offset(7, 3), Offset(7, 4), Offset(7, 5)],
    PlayerColor.green: [Offset(1, 7), Offset(2, 7), Offset(3, 7), Offset(4, 7), Offset(5, 7)],
    PlayerColor.yellow: [Offset(7, 13), Offset(7, 12), Offset(7, 11), Offset(7, 10), Offset(7, 9)],
    PlayerColor.blue: [Offset(13, 7), Offset(12, 7), Offset(11, 7), Offset(10, 7), Offset(9, 7)],
  };

  static const List<Offset> safeSpots = [
    Offset(6, 1), Offset(2, 6), Offset(1, 8), Offset(6, 12),
    Offset(8, 13), Offset(12, 8), Offset(13, 6), Offset(8, 2)
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeGame();
  }

  void startGame(int count, GameMode mode) {
    playerCount.value = count;
    gameMode.value = mode;
    _initializeGame();
  }

  void _initializeGame() {
    tokens.clear();
    List<PlayerColor> activeColors = [
      PlayerColor.red,
      PlayerColor.green,
      PlayerColor.yellow,
      PlayerColor.blue
    ].sublist(0, playerCount.value);

    for (var color in activeColors) {
      for (int i = 0; i < 4; i++) {
        tokens.add(TokenModel(id: i, color: color, position: -1));
      }
    }
    currentPlayer.value = PlayerColor.red;
    canRollDice.value = true;
    moveAbleTokens.clear();
    consecutiveSixes = 0;
  }

  bool get isCurrentPlayerAI => 
      gameMode.value == GameMode.computer && currentPlayer.value != PlayerColor.red;

  void rollDice() async {
    if (!canRollDice.value || isRolling.value) return;

    isRolling.value = true;
    for (int i = 0; i < 10; i++) {
      diceValue.value = Random().nextInt(6) + 1;
      await Future.delayed(const Duration(milliseconds: 80));
    }
    diceValue.value = Random().nextInt(6) + 1;
    isRolling.value = false;
    canRollDice.value = false;

    if (diceValue.value == 6) {
      consecutiveSixes++;
      if (consecutiveSixes == 3) {
        consecutiveSixes = 0;
        await Future.delayed(const Duration(seconds: 1));
        nextTurn();
        return;
      }
    } else {
      consecutiveSixes = 0;
    }

    _calculateMoveableTokens();

    if (moveAbleTokens.isEmpty) {
      await Future.delayed(const Duration(seconds: 1));
      nextTurn();
    } else if (isCurrentPlayerAI) {
      await Future.delayed(const Duration(milliseconds: 500));
      _aiMoveToken();
    }
  }

  void _aiMoveToken() {
    if (moveAbleTokens.isEmpty) return;
    
    TokenModel? selectedToken;
    
    // AI Priority:
    // 1. Try to kill someone
    for (var token in moveAbleTokens) {
      int nextPos = token.position == -1 ? 0 : token.position + diceValue.value;
      if (nextPos < 51) {
        Offset futureOffset = getOffsetForPosition(token.color, nextPos);
        if (!safeSpots.contains(futureOffset)) {
          for (var other in tokens) {
            if (other.color != token.color && other.position >= 0 && other.position < 51) {
              if (getOffsetForToken(other) == futureOffset) {
                selectedToken = token;
                break;
              }
            }
          }
        }
      }
      if (selectedToken != null) break;
    }

    // 2. Try to reach finish line
    if (selectedToken == null) {
      selectedToken = moveAbleTokens.firstWhereOrNull((t) => t.position + diceValue.value == 56);
    }

    // 3. Bring out of base
    if (selectedToken == null) {
      selectedToken = moveAbleTokens.firstWhereOrNull((t) => t.position == -1);
    }

    // 4. Move furthest
    if (selectedToken == null) {
      selectedToken = moveAbleTokens.reduce((curr, next) => curr.position > next.position ? curr : next);
    }

    moveToken(selectedToken);
  }

  void _calculateMoveableTokens() {
    moveAbleTokens.clear();
    var currentTokens = tokens.where((t) => t.color == currentPlayer.value);

    for (var token in currentTokens) {
      if (token.position == -1) {
        if (diceValue.value == 6) {
          moveAbleTokens.add(token);
        }
      } else if (token.position != 100) {
        if (token.position + diceValue.value <= 56) {
          moveAbleTokens.add(token);
        }
      }
    }
  }

  void moveToken(TokenModel token) async {
    if (!moveAbleTokens.contains(token)) return;

    moveAbleTokens.clear();

    int initialPosition = token.position;
    int steps = diceValue.value;
    bool killed = false;

    if (initialPosition == -1) {
      token.position = 0;
      tokens.refresh();
    } else {
      for (int i = 0; i < steps; i++) {
        token.position++;
        token.steps++;
        token.score++;
        tokens.refresh();
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }

    if (token.position == 56) {
      token.position = 100;
    } else if (token.position < 51) {
      killed = _checkKill(token);
    }

    tokens.refresh();
    _checkWinner();

    if (killed || diceValue.value == 6 || token.position == 100) {
      canRollDice.value = true;
      consecutiveSixes = (diceValue.value == 6) ? consecutiveSixes : 0;
      if (isCurrentPlayerAI && token.position != 100) { 
         await Future.delayed(const Duration(seconds: 1));
         rollDice();
      }
    } else {
      nextTurn();
    }
  }

  bool _checkKill(TokenModel token) {
    Offset currentPos = getOffsetForToken(token);
    if (safeSpots.contains(currentPos)) return false;

    bool killed = false;
    for (var otherToken in tokens) {
      if (otherToken.color != token.color && otherToken.position >= 0 && otherToken.position < 51) {
        if (getOffsetForToken(otherToken) == currentPos) {
          otherToken.position = -1;
          otherToken.steps = 0;
          otherToken.score = otherToken.score >= 5
              ? otherToken.score - 5
              : 0;
          token.kills++;
          token.score += 10;
          killed = true;
        }
      }
    }
    return killed;
  }

  void _checkWinner() {
    var playerTokens = tokens.where((t) => t.color == currentPlayer.value);
    if (playerTokens.every((t) => t.position == 100)) {
      final authController = Get.find<AuthController>();
      bool isWin = currentPlayer.value == PlayerColor.red;
      String mode = gameMode.value == GameMode.computer ? "vs Computer" : "Local Multiplayer";
      authController.updateStats(isWin, mode, currentPlayer.value.name);

      Get.dialog(
        _buildWinnerDialog(isWin),
        barrierDismissible: false,
      );
    }
  }

  Widget _buildWinnerDialog(bool isWin) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF16213E), Color(0xFF1A1A2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: LudoColors.yellow.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: LudoColors.yellow.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded, size: 80, color: LudoColors.yellow),
            const SizedBox(height: 20),
            Text(
              isWin ? "CONGRATULATIONS!" : "GAME OVER",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isWin 
                ? "You have conquered the board!" 
                : "Player ${currentPlayer.value.name.toUpperCase()} has won the game!",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _initializeGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LudoColors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("PLAY AGAIN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("DASHBOARD", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Offset getOffsetForToken(TokenModel token) {
    return getOffsetForPosition(token.color, token.position, tokenId: token.id);
  }

  Offset getOffsetForPosition(PlayerColor color, int position, {int? tokenId}) {
    if (position == -1) {
      return _getHomeOffset(color, tokenId ?? 0);
    }
    if (position == 100) {
      return const Offset(7, 7);
    }

    if (position <= 50) {
      int startIndex = startIndices[color]!;
      int boardIndex = (startIndex + position) % 52;
      return boardPath[boardIndex];
    } else {
      int homeIndex = position - 51;
      return homePaths[color]![homeIndex];
    }
  }

  Offset _getHomeOffset(PlayerColor color, int id) {
    double baseRow = 0;
    double baseCol = 0;
    switch (color) {
      case PlayerColor.red: baseRow = 0; baseCol = 0; break;
      case PlayerColor.green: baseRow = 0; baseCol = 9; break;
      case PlayerColor.yellow: baseRow = 9; baseCol = 9; break;
      case PlayerColor.blue: baseRow = 9; baseCol = 0; break;
    }
    int rowOffset = id ~/ 2;
    int colOffset = id % 2;
    return Offset(baseRow + 2 + rowOffset, baseCol + 2 + colOffset);
  }

  void nextTurn() async {
    int nextIndex = (currentPlayer.value.index + 1) % playerCount.value;
    currentPlayer.value = PlayerColor.values[nextIndex];
    canRollDice.value = true;
    moveAbleTokens.clear();

    if (isCurrentPlayerAI) {
      await Future.delayed(const Duration(seconds: 1));
      rollDice();
    }
  }
}
