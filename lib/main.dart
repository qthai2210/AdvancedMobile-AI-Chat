import 'package:aichatbot/presentation/widgets/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/core/di/injection_container.dart' as di;
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/core/services/bloc_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();
  // remove debug banner
  // debugPaintSizeEnabled = false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get BlocManager instance
    final blocManager = di.sl<BlocManager>();

    // Only provide the AuthBloc at the root level
    // Post-login blocs will be provided by AuthWrapper based on auth state
    return BlocProvider<AuthBloc>.value(
      value: blocManager.getBloc<AuthBloc>(() => di.sl<AuthBloc>()),
      // Use AuthWrapper which will manage providing the correct blocs based on auth state
      child: const AuthWrapper(),
    );
  }
}
