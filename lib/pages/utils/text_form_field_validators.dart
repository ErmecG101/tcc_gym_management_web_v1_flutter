class TextFormFieldValidators {
  static String? validateStringEmpty(String? value) {
    if (value != null && value.isEmpty) {
      return "O campo não pode ser nulo.";
    }
    return null;
  }

  static String? onlyNumbers(String value) {
    final emptyValidation = validateStringEmpty(value);
    if (emptyValidation != null) return emptyValidation;

    if (value.toLowerCase() != value.toUpperCase()) {
      return "O campo só pode possuir números!";
    }
    return null;
  }
}
