import 'dart:convert';


import 'package:tachomi_novel/ads/src/networks/applovinb.dart';

import '../networks.dart';
import 'data/ads_data.dart';
import 'globals/networkIndex.dart';
import 'networks/admob.dart';
import 'networks/ads.dart';
import 'networks/no_ads.dart';
import 'utils/log.dart';

class MultiAds {
  late final AdsData adsData;
  late final AdmobAD admobAD;
  late final ApplovinAD applovinAD;
  final _networks = <String>{};

  void _fillNetworks() {
    adsData.settings.banners.forEach((banner) => _networks.add(banner));
    adsData.settings.inters.forEach((inter) => _networks.add(inter));
    adsData.settings.nativees.forEach((nativee) => _networks.add(nativee));
    adsData.settings.rewards.forEach((reward) => _networks.add(reward));
    _networks.add(adsData.settings.openads);
    Log.log("filled networks: $_networks");
  }

  MultiAds(String json) {
    adsData = AdsData.fromJson(jsonDecode(json));
    admobAD = AdmobAD(adsData.admobData);
    applovinAD = ApplovinAD(adsData.applovinData, adsData.settings);
    _fillNetworks();
  }

  Future<void> init() async {
    if (_networks.contains(Networks.admob)) {
      await admobAD.init();
    }
    if (_networks.contains(Networks.applovin)) {
      await applovinAD.init();
    }
  }

  Future<void> loadAds() async {
    for (int i = 0; i < adsData.settings.inters.length; i++) {
      await interInstance.loadInterstitialAd();
    }
    for (int i = 0; i < adsData.settings.rewards.length; i++) {
      await rewardInstance.loadRewardAd();
    }
    await openAdsInstance.loadAppOpenAd();
  }

  Object get bannerInstance {
    NetworkIndex().incrementBannerIndex(adsData.settings.banners.length);
    if (adsData.settings.banners.isEmpty) {
      return NoAds();
    }
    if (adsData.settings.banners[NetworkIndex().bannerIndex] ==
        Networks.admob) {
      return admobAD;
    }
    if (adsData.settings.banners[NetworkIndex().bannerIndex] ==
        Networks.applovin) {
      return applovinAD;
    }
    return NoAds();
  }

  Ads get interInstance {
    NetworkIndex().incrementInterIndex(adsData.settings.inters.length);
    if (adsData.settings.inters.isEmpty) {
      return NoAds();
    }
    if (adsData.settings.inters[NetworkIndex().interIndex] == Networks.admob) {
      return admobAD;
    }
    if (adsData.settings.inters[NetworkIndex().interIndex] ==
        Networks.applovin) {
      return applovinAD;
    }
    return NoAds();
  }

  Ads get rewardInstance {
    NetworkIndex().incrementRewardIndex(adsData.settings.rewards.length);
    if (adsData.settings.rewards.isEmpty) {
      return NoAds();
    }
    if (adsData.settings.rewards[NetworkIndex().rewardIndex] ==
        Networks.admob) {
      return admobAD;
    }
    if (adsData.settings.rewards[NetworkIndex().rewardIndex] ==
        Networks.applovin) {
      return applovinAD;
    }
    return NoAds();
  }

  Ads get nativeInstance {
    NetworkIndex().incrementNativeeIndex(adsData.settings.nativees.length);
    if (adsData.settings.nativees.isEmpty) {
      return NoAds();
    }
    if (adsData.settings.nativees[NetworkIndex().nativeeIndex] ==
        Networks.admob) {
      return admobAD;
    }
    if (adsData.settings.nativees[NetworkIndex().nativeeIndex] ==
        Networks.applovin) {
      return applovinAD;
    }
    return NoAds();
  }

  Ads get openAdsInstance {
    if (adsData.settings.openads == Networks.admob) {
      return admobAD;
    }
    if (adsData.settings.openads.isEmpty) {
      return NoAds();
    }
    if (adsData.settings.openads == Networks.applovin) {
      return applovinAD;
    }
    return NoAds();
  }
}
