import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/action_enum.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/http/DefaultHttpClient.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/user_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/user_services/ac_user_service.dart';

class DialogUser extends StatefulWidget {
  const DialogUser({
    super.key,
    required this.action,
    required this.acUserService,
    this.user,
  });
  final ActionEnum action;
  final AcUserService acUserService;
  final UserModel? user;

  @override
  State<DialogUser> createState() => _DialogUserState();
}

class _DialogUserState extends State<DialogUser> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _userNameController.text = widget.user!.userName;
      _passwordController.text = widget.user!.password;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    final user = UserModel(
      id: widget.user?.id ?? '',
      name: _nameController.text.trim(),
      userName: _userNameController.text.trim(),
      password: _passwordController.text.trim(),
      document: widget.user?.document ?? '',
      email: _emailController.text.trim(),
      phoneNumber: widget.user?.phoneNumber ?? '',
      gymDto: widget.user?.gymDto ?? UserModel.empty().gymDto,
    );

    try {
      if (widget.action == ActionEnum.insert) {
        await widget.acUserService.createUser(user: user);
      } else {
        await widget.acUserService.updateUser(id: user.id, user: user);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on NoContentException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar usuário: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.action == ActionEnum.insert
        ? 'Adicionar Usuário'
        : 'Editar Usuário';
    return AlertDialog(
      title: Text(title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Nome é obrigatório'
                  : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Email é obrigatório'
                  : null,
            ),
            TextFormField(
              controller: _userNameController,
              decoration: const InputDecoration(labelText: 'Username'),
              enabled: widget.action == ActionEnum.insert,
              validator: (value) {
                if (widget.action == ActionEnum.insert &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Username é obrigatório';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
              enabled: widget.action == ActionEnum.insert,
              validator: (value) {
                if (widget.action == ActionEnum.insert &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Senha é obrigatória';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveUser,
          child: Text(
            widget.action == ActionEnum.insert ? 'Salvar' : 'Atualizar',
          ),
        ),
      ],
    );
  }
}
