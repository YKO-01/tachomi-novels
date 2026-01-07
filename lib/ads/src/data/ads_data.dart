
import 'package:tachomi_novel/ads/src/data/applovin_data.dart';

import '../../networks.dart';
import 'admob_data.dart';
import 'settings_data.dart';

class AdsData {
  final AdmobData admobData;
  final Settings settings;
  final ApplovinData applovinData;

  AdsData.fromJson(Map<String, dynamic> json)
      : admobData = AdmobData.fromJson(json["ads"][Networks.admob]),
        applovinData = ApplovinData.fromJson(json["ads"][Networks.applovin]),
        settings = Settings.fromJson(json["ads"]["settings"]);
}
