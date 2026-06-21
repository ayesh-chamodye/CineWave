import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _isAdLoaded = false;

  // Reward interstitial ad unit IDs
  final String _rewardedInterstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-8287945486916442/3524855180'
      : 'ca-app-pub-8287945486916442/3524855180'; // Provided ID

  Future<void> init() async {
    await MobileAds.instance.initialize();
    loadRewardedInterstitialAd();
  }

  void loadRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
      adUnitId: _rewardedInterstitialAdUnitId,
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
    if (_isAdLoaded && _rewardedInterstitialAd != null) {
      _rewardedInterstitialAd!.show(
        onUserEarnedReward: (ad, reward) {
          // User earned reward
        },
      );
      // We call onAdFinished immediately or after dismissal? 
      // Usually, we want to play the video AFTER the ad is closed.
      
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
