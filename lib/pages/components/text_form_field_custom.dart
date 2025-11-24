import 'package:flutter/material.dart';

class TextFormFieldCustom extends StatelessWidget {
  const TextFormFieldCustom({super.key,
  required this.controller,
  required this.hint,
  required this.name,
  this.inputType = TextInputType.text,
  this.validator});
  final TextEditingController controller;
  final String hint;
  final String name;
  final TextInputType inputType;
  final Function(String value)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        label: Text(name),
        hint: Text(hint),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      obscureText: inputType == TextInputType.visiblePassword,
      keyboardType: inputType,
      validator: validator != null ? (value) =>  validator!(value!) : null,
      controller: controller,
    );
  }
}