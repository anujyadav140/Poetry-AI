import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';

class RateAppInitWidget extends StatefulWidget {
  final Widget Function(RateMyApp) builder;

  const RateAppInitWidget({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RateAppInitWidgetState createState() => _RateAppInitWidgetState();
}

class _RateAppInitWidgetState extends State<RateAppInitWidget> {
  RateMyApp? rateMyApp;

  static const playStoreId = 'com.anujyadav.poetryai';
  static const appstoreId = 'com.anujyadav.poetryai';

  @override
  Widget build(BuildContext context) => RateMyAppBuilder(
        rateMyApp: RateMyApp(
          googlePlayIdentifier: playStoreId,
          appStoreIdentifier: appstoreId,
          minDays: 0,
          minLaunches: 2,
          // remindDays: 1,
          // remindLaunches: 1,
        ),
        onInitialized: (context, rateMyApp) {
          setState(() => this.rateMyApp = rateMyApp);

          if (rateMyApp.shouldOpenDialog) {
            rateMyApp.showRateDialog(context);
          }
        },
        builder: (context) => rateMyApp == null
            ? const Center(child: CircularProgressIndicator())
            : widget.builder(rateMyApp!),
      );
}
