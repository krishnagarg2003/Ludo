import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/ludo_controller.dart';
import '../routes/app_pages.dart';
import '../constants.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final ludoController = Get.put(LudoController());

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 10,
              child: Opacity(
                opacity: 0.2,
                child: Image.asset('assets/images/ludo_tactics_logo.png', width: 80),
              ),
            ),
            Column(
              children: [
                _buildAppBar(authController),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          "CHOOSE MODE",
                          style: TextStyle(
                            color: Colors.white38,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildModeCard(
                          title: "Play vs AI",
                          subtitle: "Challenge the computer",
                          icon: Icons.computer_rounded,
                          color: LudoColors.red,
                          onTap: () => _showPlayerCountDialog(ludoController, GameMode.computer),
                        ),
                        const SizedBox(height: 20),
                        _buildModeCard(
                          title: "Local Play",
                          subtitle: "Play with friends nearby",
                          icon: Icons.people_alt_rounded,
                          color: LudoColors.green,
                          onTap: () => _showPlayerCountDialog(ludoController, GameMode.local),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "YOUR PROGRESS",
                          style: TextStyle(
                            color: Colors.white38,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Obx(() => _buildStatsBanner(authController)),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPlayerCountDialog(LudoController controller, GameMode mode) {
    Get.dialog(
      Dialog(
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
            border: Border.all(color: LudoColors.blue.withOpacity(0.3), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "SELECT PLAYERS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPlayerOption(2, controller, mode),
                  _buildPlayerOption(3, controller, mode),
                  _buildPlayerOption(4, controller, mode),
                ],
              ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("CANCEL", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerOption(int count, LudoController controller, GameMode mode) {
    return GestureDetector(
      onTap: () {
        controller.startGame(count, mode);
        Get.toNamed(AppRoutes.ludo);
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [LudoColors.blue, LudoColors.blue.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: LudoColors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Center(
              child: Text(
                "$count",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "PLAYERS",
            style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(AuthController authController) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome back,", style: TextStyle(color: Colors.white54, fontSize: 14)),
                Obx(() => Text(
                      authController.user.value?.name ?? "Player",
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    )),
              ],
            ),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.profile),
            child: Obx(() {
              final user = authController.user.value;
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: LudoColors.yellow.withOpacity(0.5), width: 2),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  backgroundImage: user?.profilePath != null ? FileImage(File(user!.profilePath!)) : null,
                  child: user?.profilePath == null ? const Icon(Icons.person, color: Colors.white, size: 24) : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_arrow_rounded, color: Colors.white24, size: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBanner(AuthController authController) {
    final user = authController.user.value;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickStat("Played", user?.matchesPlayed.toString() ?? "0", LudoColors.blue),
          _buildQuickStat("Won", user?.matchesWon.toString() ?? "0", LudoColors.green),
          _buildQuickStat("Win Rate", "${user?.winPercentage.toStringAsFixed(0) ?? "0"}%", LudoColors.yellow),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }
}
