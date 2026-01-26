import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService extends GetxService {
  static AdService get instance => Get.find<AdService>();

  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;
  final RxBool _isBannerAdReady = false.obs;
  final RxBool _isInterstitialAdReady = false.obs;

  // Interstitial ads daily limit
  static const int _maxInterstitialAdsPerDay = 2;
  int _interstitialAdsShownToday = 0;

  // Your Ad Unit IDs
  static const String _interstitialAdUnitId =
      'ca-app-pub-2744970719381152/2955320728';
  static const String _bannerAdUnitId =
      'ca-app-pub-2744970719381152/4164102489';

  // Test Ad Unit IDs for development
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  bool get isBannerAdReady => _isBannerAdReady.value;
  bool get isInterstitialAdReady => _isInterstitialAdReady.value;
  BannerAd? get bannerAd => _bannerAd;

  @override
  Future<void> onInit() async {
    super.onInit();
    // MobileAds.instance.initialize() is now called in main.dart
    // Load daily ad count from storage
    await _loadInterstitialAdCount();
    // Load ads after a small delay to ensure everything is ready
    await Future.delayed(const Duration(milliseconds: 500));
    await _loadBannerAd();
    await _loadInterstitialAd();
  }

  // Load interstitial ad count for today
  Future<void> _loadInterstitialAdCount() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // Calculate 5 AM today
    final resetTime = DateTime(now.year, now.month, now.day, 5, 0, 0);

    // If current time is before 5 AM, use yesterday's 5 AM as the reset point
    final lastResetTime =
        now.isBefore(resetTime)
            ? resetTime.subtract(const Duration(days: 1))
            : resetTime;

    // Get the last reset timestamp
    final lastResetTimestamp = prefs.getInt('last_ad_reset_timestamp') ?? 0;
    final lastReset = DateTime.fromMillisecondsSinceEpoch(lastResetTimestamp);

    // Check if we need to reset (if last reset was before the last 5 AM)
    if (lastReset.isBefore(lastResetTime)) {
      print('🔄 Resetting ad count at 5 AM');
      _interstitialAdsShownToday = 0;
      await prefs.setInt(
        'last_ad_reset_timestamp',
        lastResetTime.millisecondsSinceEpoch,
      );
      await prefs.setInt('interstitial_ads_shown', 0);
    } else {
      _interstitialAdsShownToday = prefs.getInt('interstitial_ads_shown') ?? 0;
    }

    print(
      '📊 Ad count loaded: $_interstitialAdsShownToday/$_maxInterstitialAdsPerDay shown today',
    );
  }

  // Save interstitial ad count
  Future<void> _saveInterstitialAdCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('interstitial_ads_shown', _interstitialAdsShownToday);
  }

  // Check if we can show interstitial ad today
  bool get canShowInterstitialAd {
    return _interstitialAdsShownToday < _maxInterstitialAdsPerDay;
  }

  // Get remaining interstitial ads for today
  int get remainingInterstitialAds {
    return _maxInterstitialAdsPerDay - _interstitialAdsShownToday;
  }

  // Get total shown today
  int get interstitialAdsShownToday => _interstitialAdsShownToday;

  String get _getInterstitialAdUnitId {
    // Use test ads during development, real ads in production
    if (Platform.isAndroid) {
      return _interstitialAdUnitId; // Change to _testInterstitialAdUnitId for testing
    } else if (Platform.isIOS) {
      return _interstitialAdUnitId; // Add iOS ad unit ID when available
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  String get _getBannerAdUnitId {
    // Use test ads during development, real ads in production
    if (Platform.isAndroid) {
      return _bannerAdUnitId; // Change to _testBannerAdUnitId for testing
    } else if (Platform.isIOS) {
      return _bannerAdUnitId; // Add iOS ad unit ID when available
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  Future<void> _loadBannerAd() async {
    _bannerAd = BannerAd(
      adUnitId: _getBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner ad loaded successfully');
          _isBannerAdReady.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          ad.dispose();
          _isBannerAdReady.value = false;
          // Retry loading after a delay
          Future.delayed(const Duration(seconds: 30), () {
            _loadBannerAd();
          });
        },
        onAdOpened: (ad) => print('Banner ad opened'),
        onAdClosed: (ad) => print('Banner ad closed'),
      ),
    );

    await _bannerAd!.load();
  }

  Future<void> _loadInterstitialAd() async {
    // Don't load new ads if daily limit reached
    if (!canShowInterstitialAd) {
      print(
        '🚫 Not loading interstitial ad - daily limit reached ($_interstitialAdsShownToday/$_maxInterstitialAdsPerDay)',
      );
      return;
    }

    print('📢 Loading interstitial ad...');
    await InterstitialAd.load(
      adUnitId: _getInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ Interstitial ad loaded successfully');
          _interstitialAd = ad;
          _isInterstitialAdReady.value = true;

          _interstitialAd!
              .fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              print('📺 Interstitial ad showed full screen content');
            },
            onAdDismissedFullScreenContent: (ad) {
              print('👋 Interstitial ad dismissed');
              ad.dispose();
              _isInterstitialAdReady.value = false;
              // Only load a new ad if we haven't reached the limit
              if (canShowInterstitialAd) {
                _loadInterstitialAd();
              } else {
                print('🚫 Not loading new ad - daily limit reached');
              }
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('❌ Interstitial ad failed to show: $error');
              ad.dispose();
              _isInterstitialAdReady.value = false;
              // Only retry if we haven't reached the limit
              if (canShowInterstitialAd) {
                _loadInterstitialAd();
              }
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('❌ Interstitial ad failed to load: $error');
          _isInterstitialAdReady.value = false;
          // Only retry if we haven't reached the limit
          if (canShowInterstitialAd) {
            Future.delayed(const Duration(seconds: 30), () {
              _loadInterstitialAd();
            });
          }
        },
      ),
    );
  }

  void showInterstitialAd() {
    print('🎯 showInterstitialAd() called');
    print(
      '   - Daily limit check: $_interstitialAdsShownToday/$_maxInterstitialAdsPerDay',
    );
    print('   - Can show: $canShowInterstitialAd');
    print('   - Ad ready: ${_isInterstitialAdReady.value}');
    print('   - Ad exists: ${_interstitialAd != null}');

    // Check daily limit first
    if (!canShowInterstitialAd) {
      print(
        '❌ Daily interstitial ad limit reached ($_interstitialAdsShownToday/$_maxInterstitialAdsPerDay)',
      );
      return;
    }

    if (_isInterstitialAdReady.value && _interstitialAd != null) {
      print('✅ Showing interstitial ad now...');
      _interstitialAd!.show();
      // Increment counter and save
      _interstitialAdsShownToday++;
      _saveInterstitialAdCount();
      print(
        '✅ Interstitial ad shown ($_interstitialAdsShownToday/$_maxInterstitialAdsPerDay today)',
      );
    } else {
      print('⚠️ Interstitial ad not ready, loading new ad...');
      // Load a new ad
      _loadInterstitialAd();
    }
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdReady.value = false;
  }

  void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady.value = false;
  }

  @override
  void onClose() {
    disposeBannerAd();
    disposeInterstitialAd();
    super.onClose();
  }
}
