import 'package:flutter_bloc/flutter_bloc.dart';

/// BlocManager helps manage the lifecycle of Blocs in the application.
/// It stores instances of Blocs and prevents them from being automatically closed.
class BlocManager {
  // Map to store Bloc instances based on their type
  final Map<Type, dynamic> _blocs = {};

  /// Get a Bloc from cache or create a new one if it doesn't exist.
  ///
  /// [factory] is a function that creates a new instance of the Bloc if needed.
  ///
  /// This method ensures there's only one instance of each Bloc type
  /// and that instance won't be closed by BlocProvider.
  T getBloc<T extends Bloc>(T Function() factory) {
    if (!_blocs.containsKey(T) || _blocs[T] == null) {
      _blocs[T] = factory();
    }
    return _blocs[T] as T;
  }

  /// Close a specific Bloc and remove it from cache.
  void closeBloc<T extends Bloc>() {
    if (_blocs.containsKey(T)) {
      final bloc = _blocs[T] as T;
      bloc.close();
      _blocs.remove(T);
    }
  }

  /// Close all Blocs managed by the BlocManager.
  void dispose() {
    _blocs.forEach((_, bloc) {
      if (bloc is Bloc) {
        bloc.close();
      }
    });
    _blocs.clear();
  }
}
