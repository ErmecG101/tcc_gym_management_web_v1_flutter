import 'package:flutter/widgets.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/default_notifier.dart';

class UserNotifier extends DefaultNotifier {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userNameController = TextEditingController();

  TextEditingController get nameController => _nameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;
  TextEditingController get userNameController => _userNameController;
}
