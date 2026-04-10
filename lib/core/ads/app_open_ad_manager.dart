import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Uygulama açılışında ve ön plana geldiğinde App Open Ad gösterir.
class AppOpenAdManager {
  static const String _adUnitId = 'ca-app-pub-6164147837428706/5269383018';

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool _isLoadingAd = false;

  /// Reklamı yükle
  void loadAd() {
    if (_isLoadingAd || _appOpenAd != null) return;
    _isLoadingAd = true;

    AppOpenAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isLoadingAd = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('App Open Ad failed to load: ${error.message}');
          _isLoadingAd = false;
        },
      ),
    );
  }

  /// Reklamı göster
  void showAdIfAvailable() {
    if (_isShowingAd) return;
    if (_appOpenAd == null) {
      loadAd();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('App Open Ad failed to show: ${error.message}');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd(); // Sonraki gösterim için yeni reklam yükle
      },
    );

    _appOpenAd!.show();
  }
}

/// AppLifecycleState dinleyerek ön plana geldiğinde reklam gösterir.
class AppLifecycleReactor {
  final AppOpenAdManager appOpenAdManager;

  AppLifecycleReactor({required this.appOpenAdManager});

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.forEach((state) {
      if (state == AppState.foreground) {
        appOpenAdManager.showAdIfAvailable();
      }
    });
  }
}
