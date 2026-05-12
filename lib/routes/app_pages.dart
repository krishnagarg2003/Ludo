import 'package:get/get.dart';
import '../views/splash_view.dart';
import '../views/welcome_view.dart';
import '../views/login_view.dart';
import '../views/main_wrapper.dart';
import '../views/ludo_view.dart';
import '../views/profile_view.dart';
import '../views/about_view.dart';

class AppRoutes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const login = '/login';
  static const main = '/main';
  static const ludo = '/ludo';
  static const profile = '/profile';
  static const about = '/about';

  static final routes = [
    GetPage(name: splash, page: () => const SplashView()),
    GetPage(name: welcome, page: () => const WelcomeView()),
    GetPage(name: login, page: () => const LoginView()),
    GetPage(name: main, page: () => const MainWrapper()),
    GetPage(name: ludo, page: () => const LudoView()),
    GetPage(name: profile, page: () => const ProfileView()),
    GetPage(name: about, page: () => const AboutView()),
  ];
}
