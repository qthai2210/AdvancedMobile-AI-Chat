import 'package:flutter/material.dart';
import 'package:aichatbot/presentation/widgets/banner_ad_widget.dart';

/// A widget that adds an ad banner at the bottom of the screen
class AdBannerWrapper extends StatelessWidget {
  final Widget child;

  const AdBannerWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main content expands to fill available space
        Expanded(child: child),

        // Ad banner at the bottom
        const SizedBox(
          height: 50, // Standard banner height
          child: BannerAdWidget(),
        ),
      ],
    );
  }
}
