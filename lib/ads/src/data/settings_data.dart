import '../utils/log.dart';

class Settings {
  final List<String> banners;
  final List<String> inters;
  final List<String> nativees;
  final List<String> rewards;
  final String openads;

  Settings.fromJson(Map<String, dynamic> json)
      : banners = (json['banners'] ?? "").split(",") ?? [],
        inters = (json['inters'] ?? "").split(",") ?? [],
        nativees = (json['nativees'] ?? "").split(",") ?? [],
        openads = (json['openads'] ?? ""),
        rewards = (json['rewards'] ?? "").split(",") ?? [] {
    Log.log("openads: ------------------");
    Log.log(openads);
    Log.log("inters: ------------------");
    Log.log(inters);
    Log.log("banners: ------------------");
    Log.log(banners);
    Log.log("nativees: ------------------");
    Log.log(nativees);
    Log.log("rewards: ------------------");
    Log.log(rewards);
  }
}
