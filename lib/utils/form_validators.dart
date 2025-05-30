import 'package:reactive_forms/reactive_forms.dart';
import '../constants/constants.dart';

/// Utility class for form validation
/// Provides reusable validators for reactive forms
class FormValidators {
  FormValidators._(); // Private constructor to prevent instantiation

  /// Validator for note title
  static ValidatorFunction get titleValidator {
    return (AbstractControl<dynamic> control) {
      final value = control.value as String?;

      if (value == null || value.trim().isEmpty) {
        return {'required': AppStrings.titleRequired};
      }

      if (value.trim().length < 5) {
        return {'minLength': AppStrings.titleTooShort};
      }

      if (value.trim().length > 100) {
        return {'maxLength': AppStrings.titleTooLong};
      }

      return null;
    };
  }

  /// Validator for note content
  static ValidatorFunction get contentValidator {
    return (AbstractControl<dynamic> control) {
      final value = control.value as String?;

      if (value == null || value.trim().isEmpty) {
        return {'required': AppStrings.contentRequired};
      }

      if (value.trim().length < 10) {
        return {'minLength': AppStrings.contentTooShort};
      }

      return null;
    };
  }

  /// Validator for category (optional but if provided must be valid)
  static ValidatorFunction get categoryValidator {
    return (AbstractControl<dynamic> control) {
      final value = control.value as String?;

      // Category is optional, so null/empty is valid
      if (value == null || value.trim().isEmpty) {
        return null;
      }

      // Check if category is in the allowed list
      final validCategories = [
        AppStrings.categoryWork,
        AppStrings.categoryPersonal,
        AppStrings.categoryIdeas,
        AppStrings.categoryArchive,
      ];

      if (!validCategories.contains(value.trim())) {
        return {'invalidCategory': 'Invalid category selected'};
      }

      return null;
    };
  }

  /// Validator for search query (minimum length when not empty)
  static ValidatorFunction get searchValidator {
    return (AbstractControl<dynamic> control) {
      final value = control.value as String?;

      // Search is optional, so null/empty is valid
      if (value == null || value.trim().isEmpty) {
        return null;
      }

      if (value.trim().length < 2) {
        return {'minLength': 'Search query must be at least 2 characters'};
      }

      return null;
    };
  }

  /// Combined validator for multiple validation rules
  static ValidatorFunction combine(List<ValidatorFunction> validators) {
    return (AbstractControl<dynamic> control) {
      for (final validator in validators) {
        final result = validator(control);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }

  /// Custom validator for required fields
  static Map<String, dynamic>? required(AbstractControl<dynamic> control) {
    final value = control.value;

    if (value == null) {
      return {'required': 'This field is required'};
    }

    if (value is String && value.trim().isEmpty) {
      return {'required': 'This field is required'};
    }

    return null;
  }

  /// Custom validator for minimum length
  static ValidatorFunction minLength(int minLength, [String? customMessage]) {
    return (AbstractControl<dynamic> control) {
      final value = control.value as String?;

      if (value == null || value.length < minLength) {
        return {
          'minLength':
              customMessage ?? 'Minimum length is $minLength characters'
        };
      }

      return null;
    };
  }

  /// Custom validator for maximum length
  static ValidatorFunction maxLength(int maxLength, [String? customMessage]) {
    return (AbstractControl<dynamic> control) {
      final value = control.value as String?;

      if (value != null && value.length > maxLength) {
        return {
          'maxLength':
              customMessage ?? 'Maximum length is $maxLength characters'
        };
      }

      return null;
    };
  }

  /// Custom validator for pattern matching
  static ValidatorFunction pattern(String pattern, [String? customMessage]) {
    return (AbstractControl<dynamic> control) {
      final value = control.value as String?;

      if (value == null || value.isEmpty) {
        return null; // Let required validator handle empty values
      }

      final regex = RegExp(pattern);
      if (!regex.hasMatch(value)) {
        return {'pattern': customMessage ?? 'Invalid format'};
      }

      return null;
    };
  }

  /// Custom validator for whitespace trimming
  static ValidatorFunction noWhitespaceOnly([String? customMessage]) {
    return (AbstractControl<dynamic> control) {
      final value = control.value as String?;

      if (value != null && value.isNotEmpty && value.trim().isEmpty) {
        return {
          'whitespace': customMessage ?? 'Field cannot contain only whitespace'
        };
      }

      return null;
    };
  }

  /// Validator for note form group
  static FormGroup createNoteFormGroup({
    String? initialTitle,
    String? initialContent,
    String? initialCategory,
  }) {
    return FormGroup({
      'title': FormControl<String>(
        value: initialTitle ?? '',
        validators: [
          Validators.required,
          Validators.minLength(5),
          Validators.maxLength(100),
        ],
      ),
      'content': FormControl<String>(
        value: initialContent ?? '',
        validators: [
          Validators.required,
          Validators.minLength(10),
        ],
      ),
      'category': FormControl<String>(
        value: initialCategory,
        validators: [],
      ),
    });
  }

  /// Validator for search form group
  static FormGroup createSearchFormGroup() {
    return FormGroup({
      'query': FormControl<String>(
        value: '',
        validators: [Validators.minLength(2)],
      ),
      'category': FormControl<String>(
        value: '',
        validators: [], // No validation for category filter
      ),
    });
  }

  /// Get error message from validation result
  static String? getErrorMessage(Map<String, dynamic>? errors) {
    if (errors == null || errors.isEmpty) {
      return null;
    }

    // Return the first error message
    final errorKey = errors.keys.first;
    final errorValue = errors[errorKey];

    if (errorValue is String) {
      return errorValue;
    }

    // Default error messages based on error key
    switch (errorKey) {
      case 'required':
        return 'This field is required';
      case 'minLength':
        return 'Input is too short';
      case 'maxLength':
        return 'Input is too long';
      case 'pattern':
        return 'Invalid format';
      case 'whitespace':
        return 'Field cannot contain only whitespace';
      default:
        return 'Invalid input';
    }
  }

  /// Check if form group has any errors
  static bool hasErrors(FormGroup formGroup) {
    return formGroup.errors.isNotEmpty ||
        formGroup.controls.values.any((control) => control.errors.isNotEmpty);
  }

  /// Get all error messages from form group
  static List<String> getAllErrorMessages(FormGroup formGroup) {
    final errors = <String>[];

    // Add form-level errors
    if (formGroup.errors.isNotEmpty) {
      final errorMessage = getErrorMessage(formGroup.errors);
      if (errorMessage != null) {
        errors.add(errorMessage);
      }
    }

    // Add control-level errors
    for (final control in formGroup.controls.values) {
      if (control.errors.isNotEmpty) {
        final errorMessage = getErrorMessage(control.errors);
        if (errorMessage != null) {
          errors.add(errorMessage);
        }
      }
    }

    return errors;
  }
}
