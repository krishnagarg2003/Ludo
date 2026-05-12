import 'package:flutter/material.dart';
import '../controllers/ludo_controller.dart';

class TokenModel {
  final int id;
  final PlayerColor color;
  int position; // -1: Home, 0-51: Main Path, 52-57: Home Stretch, 100: Finished
  bool isSafe;

  TokenModel({
    required this.id,
    required this.color,
    this.position = -1,
    this.isSafe = true,
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
