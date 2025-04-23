import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:aichatbot/core/services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _checkCacheDirectory();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  // Check if cache directory exists and is accessible
  Future<void> _checkCacheDirectory() async {
    try {
      if (Platform.isAndroid) {
        final directory =
            Directory('/data/user/0/${await _getPackageName()}/cache');
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
          debugPrint('Cache directory created successfully');
        }
      }
    } catch (e) {
      debugPrint('Error checking/creating cache directory: $e');
      // Continue anyway, as the ad system might still work
    }
  }

  Future<String> _getPackageName() async {
    // This is a simple implementation - in reality you'd get this from the
    // package_info_plus plugin or similar
    return 'com.example.aichatbot';
  }

  void _loadAd() {
    try {
      _bannerAd = AdService().createBannerAd()
        ..load().then((value) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _hasError = false;
            });
          }
        }).catchError((error) {
          if (mounted) {
            setState(() {
              _hasError = true;
              debugPrint('Ad load error: $error');
            });
          }
        });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          debugPrint('Ad initialization error: $e');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      // Instead of showing error to user, show a placeholder or nothing
      return const SizedBox(height: 50);
    }

    if (_bannerAd == null || !_isAdLoaded) {
      return Container(
        height: 50,
        color: Colors.transparent,
        alignment: Alignment.center,
        child: const SizedBox(), // Empty space while ad is loading
      );
    }

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
