import 'package:flutter/material.dart';
import '../../theme/platform_ui.dart';
import 'mobile_marketing_landing_screen.dart';
import 'web_marketing_landing_screen.dart';

class MarketingLandingScreen extends StatelessWidget {
  const MarketingLandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (PlatformUI.isWeb) {
      return const WebMarketingLandingScreen();
    }
    return const MobileMarketingLandingScreen();
  }
}
