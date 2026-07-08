import 'package:formz/formz.dart';

enum SearchValidationError { invalid }

class SearchInput extends FormzInput<String, SearchValidationError> {
  const SearchInput.pure() : super.pure('');

  const SearchInput.dirty([super.value = '']) : super.dirty();
  @override
  SearchValidationError? validator(String value) {
    if (value.isEmpty) {
      return null;
    }

    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return SearchValidationError.invalid;
    }

    return null;
  }

  String? get errorMessage {
    switch (displayError) {
      case SearchValidationError.invalid:
        return 'Only alphabets are allowed';
      default:
        return null;
    }
  }
}
