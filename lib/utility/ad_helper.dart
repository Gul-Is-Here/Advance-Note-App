import 'package:shared_preferences/shared_preferences.dart';

class AdHelper {
  static const String _lastInterstitialKey = 'last_interstitial_ad_time';
  static const String _adCounterKey = 'ad_counter';
  static const int minInterstitialInterval =
      60; // 60 seconds between interstitial ads

  // Check if enough time has passed since last interstitial ad
  static Future<bool> canShowInterstitialAd() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAdTime = prefs.getInt(_lastInterstitialKey) ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    return (currentTime - lastAdTime) > (minInterstitialInterval * 1000);
  }

  // Record that an interstitial ad was shown
  static Future<void> recordInterstitialAdShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastInterstitialKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Increment ad counter and check if we should show an ad
  static Future<bool> shouldShowAdOnAction(int frequency) async {
    final prefs = await SharedPreferences.getInstance();
    int counter = prefs.getInt(_adCounterKey) ?? 0;
    counter++;
    await prefs.setInt(_adCounterKey, counter);

    return counter % frequency == 0;
  }

  // Reset the counter
  static Future<void> resetAdCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_adCounterKey, 0);
  }
}
