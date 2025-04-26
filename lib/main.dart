import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/core/di/injection_container.dart' as di;
import 'package:aichatbot/core/services/ad_service.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/widgets/auth_wrapper.dart';
import 'package:firebase_analytics/observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await AdService().initialize();
  await Firebase.initializeApp();

  final analytics = FirebaseAnalytics.instance;
  await analytics.setAnalyticsCollectionEnabled(true);

  runApp(MyApp(analytics: analytics));
}

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics;
  const MyApp({Key? key, required this.analytics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      // nếu bạn chưa có BlocManager, khởi trực tiếp AuthBloc từ DI:
      value: di.sl<AuthBloc>(),
      child: AuthWrapper(
        analytics: analytics,
        navigatorObserver: FirebaseAnalyticsObserver(analytics: analytics),
      ),
    );
  }
}
