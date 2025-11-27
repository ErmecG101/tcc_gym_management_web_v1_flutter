import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/utils/text_form_field_validators.dart';

class TextFormFieldCustom extends StatelessWidget {
  const TextFormFieldCustom({super.key,
  required this.controller,
  required this.hint,
  required this.name,
  this.readOnly = false,
  this.submitEmpty = false,
  this.inputType = TextInputType.text,
  this.validator});
  final TextEditingController controller;
  final String hint;
  final String name;
  final TextInputType inputType;
  final bool readOnly;
  final bool submitEmpty;
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
      readOnly: readOnly,
      obscureText: inputType == TextInputType.visiblePassword,
      keyboardType: inputType,
      validator: validator != null ? (value) =>  validator!(value!) : submitEmpty == false ? (value) => TextFormFieldValidators.validateStringEmpty(value) : null,
      controller: controller,
    );
  }
}