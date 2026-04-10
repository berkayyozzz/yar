import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Geçiş reklamı (Interstitial Ad) yöneticisi.
/// İşlem eklendikten sonra gösterilir.
class InterstitialAdManager {
  static const String _adUnitId = 'ca-app-pub-6164147837428706/8386500943';

  InterstitialAd? _interstitialAd;
  bool _isLoadingAd = false;

  /// Reklamı önceden yükle (preload)
  void loadAd() {
    if (_isLoadingAd || _interstitialAd != null) return;
    _isLoadingAd = true;

    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoadingAd = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: ${error.message}');
          _isLoadingAd = false;
        },
      ),
    );
  }

  /// Reklamı göster, gösterildikten/kapatıldıktan sonra [onComplete] çağrılır.
  /// Reklam yüklü değilse direkt [onComplete] çağrılır.
  void showAd({VoidCallback? onComplete}) {
    if (_interstitialAd == null) {
      loadAd();
      onComplete?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadAd(); // Sonraki gösterim için yeni reklam yükle
        onComplete?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial ad failed to show: ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        loadAd();
        onComplete?.call();
      },
    );

    _interstitialAd!.show();
  }
}
