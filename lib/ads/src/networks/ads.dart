// ignore_for_file: unused_element, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract class Ads {
  Future<void> loadAppOpenAd();
  void showAdIfAvailableOpenAds();

  Future<void> loadBannerAd(Function? onLoaded, Key key);

  Widget getBannerAdWidget(Key key);
  Future<void> disposeBanner(Key key);

  Future<void> loadInterstitialAd();
  void showInterstitialAd();

  Future<void> loadRewardAd();
  void showRewardAd(Function rewarded);

  Future<void> loadNativeAd(
      Function? onLoaded, Key key, TemplateType templateType);
  Widget getNativeAdWidget(Key key, double height);
  Future<void> disposeNative(Key key);

  Future<void> init();
}
