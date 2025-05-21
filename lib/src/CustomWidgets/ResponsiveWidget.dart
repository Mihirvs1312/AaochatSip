import 'package:flutter/cupertino.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var deviceWidth = MediaQuery.of(context).size.width;
        var deviceHeight = MediaQuery.of(context).size.height;
        var orientation = MediaQuery.of(context).orientation;

        if (deviceWidth < 600) {
          return mobile;
        } else if (deviceWidth >= 600 && deviceWidth < 900) {
          return tablet;
        } else {
          return desktop;
        }
      },
    );
  }
}
