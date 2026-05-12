import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../models/ludo_models.dart';
import '../controllers/ludo_controller.dart';

class LudoView extends StatelessWidget {
  const LudoView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LudoController());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Colors.black],
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  right: 15,
                  child: Opacity(
                    opacity: 0.2,
                    child: Image.asset('assets/images/ludo_tactics_logo.png', width: 50),
                  ),
                ),
                Column(
                  children: [
                    _buildHeader(controller),
                    const Spacer(),
                    _buildBoard(controller),
                    const Spacer(),
                    _buildDiceSection(controller),
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(LudoController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "LUDO",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  "TACTICS",
                  style: TextStyle(
                    fontSize: 12,
                    color: LudoColors.yellow.withValues(alpha: 0.8),
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Obx(() => _buildTurnIndicator(controller.currentPlayer.value)),
        ],
      ),
    );
  }

  Widget _buildTurnIndicator(PlayerColor player) {
    Color color = _getPlayerColor(player);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 5,
                  spreadRadius: 1,
                )
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            player.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(LudoController controller) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double cellSize = constraints.maxWidth / 15;
                return Stack(
                  children: [
                    _buildBoardGrid(),
                    _buildHomes(),
                    _buildCenterTriangles(),
                    Obx(() {
                      Map<String, List<TokenModel>> groupedTokens = {};
                      for (var token in controller.tokens) {
                        Offset pos = controller.getOffsetForToken(token);
                        String key = "${pos.dx}_${pos.dy}";
                        groupedTokens.putIfAbsent(key, () => []).add(token);
                      }

                      List<Widget> tokenWidgets = [];
                      groupedTokens.forEach((key, tokensInPos) {
                        for (int i = 0; i < tokensInPos.length; i++) {
                          var token = tokensInPos[i];
                          Offset pos = controller.getOffsetForToken(token);
                          bool isMoveable = controller.moveAbleTokens.contains(token);
                          
                          double offsetX = 0;
                          double offsetY = 0;
                          if (tokensInPos.length > 1) {
                            if (i == 0) { offsetX = -cellSize * 0.18; offsetY = -cellSize * 0.18; }
                            else if (i == 1) { offsetX = cellSize * 0.18; offsetY = cellSize * 0.18; }
                            else if (i == 2) { offsetX = cellSize * 0.18; offsetY = -cellSize * 0.18; }
                            else if (i == 3) { offsetX = -cellSize * 0.18; offsetY = cellSize * 0.18; }
                          }

                          tokenWidgets.add(AnimatedPositioned(
                            key: ValueKey("token_${token.color.name}_${token.id}"),
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            top: pos.dx * cellSize + offsetX,
                            left: pos.dy * cellSize + offsetY,
                            width: cellSize,
                            height: cellSize,
                            child: GestureDetector(
                              onTap: controller.isCurrentPlayerAI ? null : () => controller.moveToken(token),
                              child: _buildToken(token, isMoveable, cellSize),
                            ),
                          ));
                        }
                      });
                      return Stack(children: tokenWidgets);
                    }),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToken(TokenModel token, bool isMoveable, double cellSize) {
    Color color = _getPlayerColor(token.color);
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isMoveable)
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 1.0, end: 1.5),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Container(
                  width: cellSize * 0.8 * value,
                  height: cellSize * 0.8 * value,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.1),
                        blurRadius: 4 * value,
                        spreadRadius: 2 * value,
                      )
                    ],
                  ),
                );
              },
              onEnd: () {},
            ),
          SizedBox(
            width: cellSize * 0.9,
            height: cellSize * 0.9,
            child: CustomPaint(
              painter: PremiumPawnPainter(color),
            ),
          ),
          if (isMoveable)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.touch_app, size: 10, color: color),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBoardGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 15,
      ),
      itemCount: 15 * 15,
      itemBuilder: (context, index) {
        int row = index ~/ 15;
        int col = index % 15;

        bool isPath = (row >= 6 && row <= 8) || (col >= 6 && col <= 8);
        if (!isPath) return Container();

        Color color = Colors.white;
        Widget? child;

        if (row == 7 && col > 0 && col < 6) color = LudoColors.red.withValues(alpha: 0.3);
        if (row == 7 && col > 8 && col < 14) color = LudoColors.yellow.withValues(alpha: 0.3);
        if (col == 7 && row > 0 && row < 6) color = LudoColors.green.withValues(alpha: 0.3);
        if (col == 7 && row > 8 && row < 14) color = LudoColors.blue.withValues(alpha: 0.3);

        bool isStar = (row == 6 && col == 1) || (row == 2 && col == 6) || 
                      (row == 8 && col == 13) || (row == 12 && col == 8) ||
                      (row == 1 && col == 8) || (row == 6 && col == 12) ||
                      (row == 13 && col == 6) || (row == 8 && col == 2);
        
        if (isStar) {
          child = const Icon(Icons.stars, size: 16, color: Colors.black12);
        }

        if (row == 6 && col == 1) color = LudoColors.red.withValues(alpha: 0.8);
        if (row == 1 && col == 8) color = LudoColors.green.withValues(alpha: 0.8);
        if (row == 8 && col == 13) color = LudoColors.yellow.withValues(alpha: 0.8);
        if (row == 13 && col == 6) color = LudoColors.blue.withValues(alpha: 0.8);

        return Container(
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey[300]!, width: 0.5),
          ),
          child: child,
        );
      },
    );
  }

  Widget _buildHomes() {
    return Stack(
      children: [
        Positioned(top: 0, left: 0, child: _buildHome(LudoColors.red)),
        Positioned(top: 0, right: 0, child: _buildHome(LudoColors.green)),
        Positioned(bottom: 0, left: 0, child: _buildHome(LudoColors.blue)),
        Positioned(bottom: 0, right: 0, child: _buildHome(LudoColors.yellow)),
      ],
    );
  }

  Widget _buildHome(Color color) {
    double size = (Get.width - 24) * (6 / 15);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black12, width: 2),
      ),
      child: Center(
        child: Container(
          width: size * 0.7,
          height: size * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            padding: const EdgeInsets.all(12),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: List.generate(4, (index) => Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterTriangles() {
    double size = (Get.width - 24) * (3 / 15);
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: CenterPainter(),
        ),
      ),
    );
  }

  Widget _buildDiceSection(LudoController controller) {
    return Column(
      children: [
        Obx(() => GestureDetector(
              onTap: controller.isCurrentPlayerAI ? null : controller.rollDice,
              child: AnimatedScale(
                scale: controller.isRolling.value ? 0.9 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: controller.isCurrentPlayerAI ? Colors.grey[200] : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: _getPlayerColor(controller.currentPlayer.value).withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Center(
                    child: controller.isRolling.value
                        ? _buildRollingDice()
                        : _buildDiceFace(controller.diceValue.value, _getPlayerColor(controller.currentPlayer.value)),
                  ),
                ),
              ),
            )),
        const SizedBox(height: 15),
        Obx(() {
          String text = "TAP TO ROLL";
          if (controller.isCurrentPlayerAI) {
            text = "COMPUTER ROLLING...";
          } else if (!controller.canRollDice.value) {
            text = "CHOOSE A PIECE";
          }
          return Text(
            text,
            style: const TextStyle(
              color: Colors.white60,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRollingDice() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 2 * 3.14159),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value,
          child: const Icon(Icons.casino, size: 50, color: Colors.grey),
        );
      },
    );
  }

  Widget _buildDiceFace(int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: CustomPaint(
        size: const Size(60, 60),
        painter: DicePainter(value, color),
      ),
    );
  }

  Color _getPlayerColor(PlayerColor player) {
    switch (player) {
      case PlayerColor.red: return LudoColors.red;
      case PlayerColor.blue: return LudoColors.blue;
      case PlayerColor.green: return LudoColors.green;
      case PlayerColor.yellow: return LudoColors.yellow;
    }
  }
}

class PremiumPawnPainter extends CustomPainter {
  final Color color;
  PremiumPawnPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Base Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(Rect.fromLTWH(w * 0.1, h * 0.8, w * 0.8, h * 0.2), shadowPaint);

    // Main Body Gradient
    final mainPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, color, color.withValues(alpha: 0.8)],
        stops: const [0.0, 0.5, 1.0],
        center: const Alignment(-0.3, -0.3),
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Draw Neck/Body
    final Path bodyPath = Path()
      ..moveTo(w * 0.5, h * 0.3)
      ..quadraticBezierTo(w * 0.3, h * 0.4, w * 0.2, h * 0.9)
      ..lineTo(w * 0.8, h * 0.9)
      ..quadraticBezierTo(w * 0.7, h * 0.4, w * 0.5, h * 0.3)
      ..close();
    canvas.drawPath(bodyPath, mainPaint);

    // Draw Head
    canvas.drawCircle(Offset(w * 0.5, h * 0.3), w * 0.25, mainPaint);

    // Shine/Highlight
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(Offset(w * 0.42, h * 0.22), w * 0.08, shinePaint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(w * 0.5, h * 0.3), w * 0.25, borderPaint);
    canvas.drawPath(bodyPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DicePainter extends CustomPainter {
  final int value;
  final Color color;

  DicePainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double dotRadius = size.width / 10;
    final double mid = size.width / 2;
    final double quarter = size.width / 4;
    final double threeQuarter = size.width * 3 / 4;

    List<Offset> dots = [];
    switch (value) {
      case 1: dots = [Offset(mid, mid)]; break;
      case 2: dots = [Offset(quarter, quarter), Offset(threeQuarter, threeQuarter)]; break;
      case 3: dots = [Offset(quarter, quarter), Offset(mid, mid), Offset(threeQuarter, threeQuarter)]; break;
      case 4: dots = [Offset(quarter, quarter), Offset(threeQuarter, quarter), Offset(quarter, threeQuarter), Offset(threeQuarter, threeQuarter)]; break;
      case 5: dots = [Offset(quarter, quarter), Offset(threeQuarter, quarter), Offset(mid, mid), Offset(quarter, threeQuarter), Offset(threeQuarter, threeQuarter)]; break;
      case 6: dots = [Offset(quarter, quarter), Offset(threeQuarter, quarter), Offset(quarter, mid), Offset(threeQuarter, mid), Offset(quarter, threeQuarter), Offset(threeQuarter, threeQuarter)]; break;
    }

    for (var dot in dots) {
      canvas.drawCircle(dot, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CenterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..style = PaintingStyle.fill;
    paint.color = LudoColors.green;
    var path1 = Path()..moveTo(0, 0)..lineTo(size.width, 0)..lineTo(size.width / 2, size.height / 2)..close();
    canvas.drawPath(path1, paint);
    paint.color = LudoColors.red;
    var path2 = Path()..moveTo(0, 0)..lineTo(0, size.height)..lineTo(size.width / 2, size.height / 2)..close();
    canvas.drawPath(path2, paint);
    paint.color = LudoColors.yellow;
    var path3 = Path()..moveTo(size.width, 0)..lineTo(size.width, size.height)..lineTo(size.width / 2, size.height / 2)..close();
    canvas.drawPath(path3, paint);
    paint.color = LudoColors.blue;
    var path4 = Path()..moveTo(0, size.height)..lineTo(size.width, size.height)..lineTo(size.width / 2, size.height / 2)..close();
    canvas.drawPath(path4, paint);
    var borderPaint = Paint()..color = Colors.black.withValues(alpha: 0.1)..style = PaintingStyle.stroke..strokeWidth = 1;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);
    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), borderPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), borderPaint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
