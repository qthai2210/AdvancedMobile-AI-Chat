import 'package:aichatbot/core/di/core_injection.dart';
import 'package:aichatbot/core/di/post_login_injection.dart';
import 'package:aichatbot/utils/logger.dart';

/// Export important functions and variables for use in the app
export 'package:aichatbot/core/di/core_injection.dart' show sl;
export 'package:aichatbot/core/di/post_login_injection.dart'
    show
        initPostLoginServices,
        resetPostLoginServices,
        arePostLoginServicesInitialized;

/// Main dependency injection initialization function
Future<void> init() async {
  AppLogger.i('Initializing dependency injection...');

  // Only initialize core services at app startup
  await initCoreServices();

  AppLogger.i('Dependency injection initialization completed');
}
