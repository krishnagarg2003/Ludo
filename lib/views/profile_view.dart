import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../constants.dart';
import '../routes/app_pages.dart';
import 'main_wrapper.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Settings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Obx(() {
        final user = authController.user.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildProfileHeader(authController),
              const SizedBox(height: 30),
              _buildStatsRow(user),
              const SizedBox(height: 40),
              _buildActionList(context, authController),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(AuthController authController) {
    final user = authController.user.value;
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: authController.updateProfileImage,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [LudoColors.yellow, LudoColors.yellow.withOpacity(0.2)],
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF1A1A2E),
                  backgroundImage: user?.profilePath != null 
                    ? FileImage(File(user!.profilePath!)) 
                    : null,
                  child: user?.profilePath == null 
                    ? const Icon(Icons.person, size: 50, color: Colors.white) 
                    : null,
                ),
              ),
            ),
            GestureDetector(
              onTap: authController.updateProfileImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: LudoColors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          user?.name ?? "Player",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildStatsRow(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Matches", user?.matchesPlayed.toString() ?? "0"),
          _buildStatItem("Wins", user?.matchesWon.toString() ?? "0"),
          _buildStatItem("Win %", "${user?.winPercentage.toStringAsFixed(0) ?? "0"}%"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _buildActionList(BuildContext context, AuthController authController) {
    return Column(
      children: [
        _buildActionTile(
          icon: Icons.history_rounded,
          title: "Game History",
          color: LudoColors.blue,
          onTap: () {
            final mainWrapperState = context.findAncestorStateOfType<MainWrapperState>();
            mainWrapperState?.changeTab(1);
          },
        ),
        _buildActionTile(
          icon: Icons.info_outline_rounded,
          title: "About Game",
          color: LudoColors.yellow,
          onTap: () => Get.toNamed(AppRoutes.about),
        ),
        _buildActionTile(
          icon: Icons.refresh_rounded,
          title: "Reset Progress",
          color: LudoColors.red,
          onTap: () => _showResetDialog(authController),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        tileColor: Colors.white.withOpacity(0.03),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
      ),
    );
  }

  void _showResetDialog(AuthController authController) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Reset Data", style: TextStyle(color: Colors.white)),
        content: const Text("This will clear all your match records. Are you sure?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel", style: TextStyle(color: Colors.white38))),
          TextButton(
            onPressed: () => authController.logout(),
            child: const Text("Reset", style: TextStyle(color: LudoColors.red)),
          ),
        ],
      ),
    );
  }
}
