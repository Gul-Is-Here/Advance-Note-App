import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';

class AdService extends GetxService {
  static AdService get instance => Get.find<AdService>();

  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;
  final RxBool _isBannerAdReady = false.obs;
  final RxBool _isInterstitialAdReady = false.obs;

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
    await _initializeAds();
  }

  Future<void> _initializeAds() async {
    await MobileAds.instance.initialize();
    await _loadBannerAd();
    await _loadInterstitialAd();
  }

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
    await InterstitialAd.load(
      adUnitId: _getInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('Interstitial ad loaded successfully');
          _interstitialAd = ad;
          _isInterstitialAdReady.value = true;

          _interstitialAd!
              .fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              print('Interstitial ad showed full screen content');
            },
            onAdDismissedFullScreenContent: (ad) {
              print('Interstitial ad dismissed');
              ad.dispose();
              _isInterstitialAdReady.value = false;
              // Load a new ad for next time
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('Interstitial ad failed to show: $error');
              ad.dispose();
              _isInterstitialAdReady.value = false;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: $error');
          _isInterstitialAdReady.value = false;
          // Retry loading after a delay
          Future.delayed(const Duration(seconds: 30), () {
            _loadInterstitialAd();
          });
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_isInterstitialAdReady.value && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      print('Interstitial ad not ready');
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
