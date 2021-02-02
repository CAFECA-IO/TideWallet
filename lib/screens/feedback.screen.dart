import 'package:flutter/material.dart';
import 'dart:core';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/appBar.dart';
import '../helpers/i18n.dart';

class FeedbackScreen extends StatelessWidget {
  static const routeName = '/feedback';
  final t = I18n.t;
  final Uri _emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'info@tidewallet.io',
    // queryParameters: {'subject': 'Example Subject & Symbols are allowed!'}
  );
  @override
  Widget build(BuildContext context) {
    Widget _section(String title, List<Widget> items) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.only(left: 20.0),
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                right: 20.0,
                left: 4.0,
                top: 10.0,
                bottom: 10.0,
              ),
              width: double.infinity,
              child: Text(
                title,
                style: Theme.of(context).textTheme.subtitle2,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
            ),
            ...items
          ],
        ),
      );
    }

    Widget _item(String _title, Function _onTap) {
      return InkWell(
        onTap: _onTap,
        child: Container(
          padding: const EdgeInsets.only(
            right: 20.0,
            left: 4.0,
            top: 10.0,
            bottom: 10.0,
          ),
          // decoration: BoxDecoration(
          //   border: Border(
          //     bottom: BorderSide(color: Theme.of(context).dividerColor),
          //   ),
          // ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_title),
              ImageIcon(
                AssetImage('assets/images/icons/ic_arrow_right_normal.png'),
                color: Theme.of(context).textTheme.subtitle2.color,
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: GeneralAppbar(
        title: t('setting_feedback'),
        routeName: FeedbackScreen.routeName,
      ),
      body: ListView(
        padding: const EdgeInsets.all(0),
        shrinkWrap: true,
        children: [
          _section(t('contact_way'), [
            _item(t('email'), () {
              launch(_emailLaunchUri.toString());
            }),
          ])
        ],
      ),
    );
  }
}
