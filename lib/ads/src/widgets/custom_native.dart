import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../networks/ads.dart';

class CustomNative extends StatefulWidget {
  final Ads ads;
  final TemplateType templateType;
  const CustomNative(
      {required Key key, required this.ads, required this.templateType})
      : super(key: key);

  @override
  _CustomNativeState createState() => _CustomNativeState();
}

class _CustomNativeState extends State<CustomNative> {
  @override
  void initState() {
    widget.ads.loadNativeAd(
        () => setState(() {}), widget.key ?? UniqueKey(), widget.templateType);
    super.initState();
  }

  @override
  void dispose() {
    widget.ads.disposeNative(widget.key ?? UniqueKey());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.ads.getNativeAdWidget(widget.key ?? UniqueKey(),
        widget.templateType == TemplateType.medium ? 200 : 100);
  }
}
