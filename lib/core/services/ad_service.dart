import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';

class AdService {
  // Singleton pattern
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Test banner ad unit IDs - replace with your real ones in production
  static const String _androidBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _iosBannerAdUnitId =
      'ca-app-pub-3940256099942544/2934735716';

  // Getter for banner ad unit ID based on platform
  String get bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid ? _androidBannerAdUnitId : _iosBannerAdUnitId;
    } else {
      // TODO: Return your actual production ad unit IDs here
      return Platform.isAndroid ? _androidBannerAdUnitId : _iosBannerAdUnitId;
    }
  }

  // Initialize the Mobile Ads SDK with Firebase integration
  Future<InitializationStatus> initialize() async {
    // Initialize Firebase first if it hasn't been initialized already
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
        debugPrint('Firebase initialized successfully');
      }
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
      // Continue even if Firebase initialization fails, as ads can still work
    }

    // Then initialize Mobile Ads
    final status = await MobileAds.instance.initialize();

    // Enable test mode for debugging
    if (kDebugMode) {
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: ['kGADSimulatorID'],
        ),
      );
    }

    return status;
  }

  // Create a banner ad with enhanced error handling
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) =>
            debugPrint('Ad loaded successfully: ${ad.adUnitId}'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint(
              'Ad failed to load: ${ad.adUnitId}, Error: ${error.message}, Code: ${error.code}');
        },
        onAdOpened: (ad) => debugPrint('Ad opened: ${ad.adUnitId}'),
        onAdClosed: (ad) => debugPrint('Ad closed: ${ad.adUnitId}'),
      ),
    );
  }
}
