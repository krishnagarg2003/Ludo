import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../controllers/auth_controller.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text("Recent Matches", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (authController.history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_toggle_off_rounded, size: 80, color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 20),
                const Text(
                  "No matches played yet",
                  style: TextStyle(color: Colors.white38, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: authController.history.length,
          itemBuilder: (context, index) {
            final game = authController.history[index];
            bool isWin = game.isWin;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isWin 
                    ? LudoColors.green.withOpacity(0.2) 
                    : LudoColors.red.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isWin ? LudoColors.green : LudoColors.red).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      isWin ? Icons.workspace_premium_rounded : Icons.sentiment_very_dissatisfied_rounded,
                      color: isWin ? LudoColors.green : LudoColors.red,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isWin ? "VICTORY" : "DEFEAT",
                          style: TextStyle(
                            color: isWin ? LudoColors.green : LudoColors.red,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          game.mode,
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDate(game.date),
                        style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        game.playerColor.toUpperCase(),
                        style: TextStyle(
                          color: _getColorFromName(game.playerColor).withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Color _getColorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'red': return LudoColors.red;
      case 'blue': return LudoColors.blue;
      case 'green': return LudoColors.green;
      case 'yellow': return LudoColors.yellow;
      default: return Colors.white;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      if (date.day == now.day && date.month == now.month && date.year == now.year) {
        return "Today";
      }
      return "${date.day}/${date.month}";
    } catch (e) {
      return dateStr.split(' ')[0];
    }
  }
}
