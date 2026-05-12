import 'package:flutter/material.dart';
import '../controllers/ludo_controller.dart';

class TokenModel {
  final int id;
  final PlayerColor color;

  int position;

  bool isSafe;

  /// Total steps moved
  int steps;

  /// Total kills
  int kills;

  /// Pawn power score
  int score;

  TokenModel({
    required this.id,
    required this.color,
    this.position = -1,
    this.isSafe = true,
    this.steps = 0,
    this.kills = 0,
    this.score = 0,
  });
}

class LudoGameState {
  final int playerCount;
  final List<TokenModel> tokens;
  PlayerColor currentPlayer;
  int diceValue;
  bool isDiceRolled;

  LudoGameState({
    required this.playerCount,
    required this.tokens,
    this.currentPlayer = PlayerColor.red,
    this.diceValue = 1,
    this.isDiceRolled = false,
  });
}
class PawnStats {
  int totalMoves;
  int kills;
  int currentSteps;

  PawnStats({
    this.totalMoves = 0,
    this.kills = 0,
    this.currentSteps = 0,
  });
}
