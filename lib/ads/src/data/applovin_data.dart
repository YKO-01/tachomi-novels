class ApplovinData {
  final String bannerId;
  final String interId;
  final String nativeId;
  final String rewardId;
  final String sdk_key;
  final String openAdsId;

  ApplovinData.fromJson(Map<String, dynamic> json)
      : bannerId = json['bannerId'] ?? "",
        interId = json['interId'] ?? "",
        nativeId = json['nativeId'] ?? "",
        rewardId = json['rewardId'] ?? "",
        sdk_key = json['sdk_key'] ?? "",
        openAdsId = json['openAdsIds'] ?? "";
}
