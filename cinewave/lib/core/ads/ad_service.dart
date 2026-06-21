import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _isAdLoaded = false;
  DateTime? _lastAdShowTime;
  static const int _adCooldownMinutes = 15;

  // Production Ad unit IDs
  static const String _prodRewardedId = 'ca-app-pub-8287945486916442/3524855180';
  static const String _prodBannerId = 'ca-app-pub-8287945486916442/9946793305';

  // Test Ad unit IDs (Standard Google Test IDs)
  static const String _testRewardedId = 'ca-app-pub-3940256099942544/5354046379';
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';

  String get rewardedInterstitialAdUnitId => kDebugMode ? _testRewardedId : _prodRewardedId;
  String get bannerAdUnitId => kDebugMode ? _testBannerId : _prodBannerId;

  Future<void> init() async {
    await MobileAds.instance.initialize();
    loadRewardedInterstitialAd();
  }

  void loadRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
      adUnitId: rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitialAd = ad;
          _isAdLoaded = true;
          
          _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isAdLoaded = false;
              loadRewardedInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isAdLoaded = false;
              loadRewardedInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
        },
      ),
    );
  }

  void showRewardedInterstitialAd(VoidCallback onAdFinished) {
    final now = DateTime.now();
    if (_lastAdShowTime != null && 
        now.difference(_lastAdShowTime!).inMinutes < _adCooldownMinutes) {
      debugPrint('Ad in cooldown. Skipping...');
      onAdFinished();
      return;
    }

    if (_isAdLoaded && _rewardedInterstitialAd != null) {
      _rewardedInterstitialAd!.show(
        onUserEarnedReward: (ad, reward) {
          _lastAdShowTime = DateTime.now();
        },
      );
      
      _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isAdLoaded = false;
          onAdFinished();
          loadRewardedInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isAdLoaded = false;
          onAdFinished();
          loadRewardedInterstitialAd();
        },
      );
    } else {
      onAdFinished();
      loadRewardedInterstitialAd();
    }
  }
}
