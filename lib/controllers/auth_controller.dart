import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../routes/app_pages.dart';

class AuthController extends GetxController {
  var isLogged = false.obs;
  var user = Rxn<UserModel>();
  var history = <GameHistory>[].obs;

  late Box userBox;
  late Box historyBox;

  @override
  void onInit() async {
    super.onInit();
    userBox = Hive.box('userBox');
    historyBox = Hive.box('historyBox');
    _loadUserData();
  }

  void _loadUserData() {
    final userData = userBox.get('user');
    if (userData != null) {
      user.value = UserModel.fromJson(Map<dynamic, dynamic>.from(userData));
      isLogged.value = true;
    }

    final historyData = historyBox.values;
    history.value = historyData
        .map((e) => GameHistory.fromJson(Map<dynamic, dynamic>.from(e)))
        .toList()
        .reversed
        .toList();
  }

  void login(String name) {
    user.value = UserModel(name: name);
    userBox.put('user', user.value!.toJson());
    isLogged.value = true;
    Get.offAllNamed(AppRoutes.main);
  }

  void register(String name, String email, String password) {
    login(name);
  }

  void updateProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null && user.value != null) {
      final updatedUser = UserModel(
        name: user.value!.name,
        matchesPlayed: user.value!.matchesPlayed,
        matchesWon: user.value!.matchesWon,
        profilePath: image.path,
      );
      user.value = updatedUser;
      userBox.put('user', updatedUser.toJson());
    }
  }

  void updateStats(bool isWin, String mode, String playerColor) {
    if (user.value == null) return;

    final updatedUser = UserModel(
      name: user.value!.name,
      matchesPlayed: user.value!.matchesPlayed + 1,
      matchesWon: isWin ? user.value!.matchesWon + 1 : user.value!.matchesWon,
      profilePath: user.value!.profilePath,
    );

    user.value = updatedUser;
    userBox.put('user', updatedUser.toJson());

    final newHistory = GameHistory(
      date: DateTime.now().toString(),
      mode: mode,
      isWin: isWin,
      playerColor: playerColor,
    );

    historyBox.add(newHistory.toJson());
    history.insert(0, newHistory);
  }

  void logout() {
    userBox.clear();
    historyBox.clear();
    isLogged.value = false;
    user.value = null;
    history.clear();
    Get.offAllNamed(AppRoutes.welcome);
  }
}
