import 'package:flutter/material.dart';
import '../constants.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text("About Game", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.casino, size: 80, color: LudoColors.yellow),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                "Ludo Champions",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const Center(
              child: Text(
                "Version 1.0.0",
                style: TextStyle(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 40),
            _buildSectionTitle("How to Play"),
            _buildInfoCard(
              "Ludo is a strategy board game for two to four players, in which the players race their four tokens from start to finish according to the rolls of a single die.",
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("Rules"),
            _buildRuleItem("1", "Roll a 6 to bring a token out of the base."),
            _buildRuleItem("2", "A 6 gives you an extra roll."),
            _buildRuleItem("3", "Landing on an opponent's token sends it back home."),
            _buildRuleItem("4", "Landing on a Star cell is a safe spot."),
            _buildRuleItem("5", "Rolling three 6s in a row ends your turn."),
            const SizedBox(height: 40),
            _buildSectionTitle("Features"),
            _buildInfoCard(
              "• Full Offline Support\n• Smart AI Opponent\n• Local Multiplayer\n• Beautiful Animations\n• Detailed Match History",
            ),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                "Made with ❤️ for Ludo Lovers",
                style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: LudoColors.yellow),
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
      ),
    );
  }

  Widget _buildRuleItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$number. ",
            style: const TextStyle(color: LudoColors.yellow, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
