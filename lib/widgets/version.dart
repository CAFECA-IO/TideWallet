import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class Version extends StatelessWidget {
  final Color color;
  final double fontSize;

  Version({
    this.color = Colors.black45,
    this.fontSize = 14.0
  });
  Future<String> getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return '${packageInfo.version} (${packageInfo.buildNumber})';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          getVersionNumber(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) =>
          snapshot.hasData
              ? Text(
                  'V ${snapshot.data}',
                  style: TextStyle(color: color, fontSize: fontSize),
                )
              : SizedBox(),
    );
  }
}
