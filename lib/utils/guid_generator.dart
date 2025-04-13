import 'package:uuid/uuid.dart';

/// A utility class for generating globally unique identifiers (GUIDs)
class GuidGenerator {
  static const _uuid = Uuid();

  /// Generates a version 4 UUID (random) as a string
  ///
  /// This method returns a universally unique identifier as a string.
  /// The format follows the standard UUID v4 format (xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx)
  /// where x is any hexadecimal digit and y is one of 8, 9, A, or B.
  ///
  /// @return A String containing the generated UUID
  static String generate() {
    return _uuid.v4();
  }

  /// Checks if a string is a valid UUID format
  ///
  /// @param id The string to validate
  /// @return true if the string is a valid UUID, false otherwise
  static bool isValid(String id) {
    try {
      // Try to parse the string as UUID
      Uuid.parse(id);
      return true;
    } catch (e) {
      return false;
    }
  }
}
