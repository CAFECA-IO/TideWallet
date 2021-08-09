import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';
import '../constants/endpoint.dart';
import '../widgets/appBar.dart';
import '../helpers/i18n.dart';

class TermsScreen extends StatelessWidget {
  static const routeName = '/terms';
  final t = I18n.t;

  final emailAddress = Endpoint.EMAIL;

  final Uri _emailLaunchUri = Uri(
    scheme: 'mailto',
    path: Endpoint.EMAIL,
    // queryParameters: {'subject': 'Example Subject & Symbols are allowed!'}
  );

  @override
  Widget build(BuildContext context) {
    Widget _section(String title, String subtite, List<List> contents) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title.isNotEmpty
              ? Text(
                  title,
                  style: Theme.of(context).textTheme.headline2,
                )
              : SizedBox(),
          subtite.isNotEmpty
              ? Text(subtite,
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                      color: MyColors.secondary_01,
                      fontWeight: FontWeight.w400))
              : SizedBox(),
          ...contents
              .asMap()
              .map(
                (index, content) => MapEntry(
                  index,
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          contents.length > 1
                              ? Row(
                                  children: [
                                    Text('${index + 1}.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2!
                                            .copyWith(
                                                fontSize: 16,
                                                letterSpacing: 1)),
                                    SizedBox(width: 16),
                                  ],
                                )
                              : SizedBox(),
                          Expanded(
                            child: Text(
                              content[1],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                      fontSize: 16,
                                      letterSpacing: 1,
                                      color: !content[0]
                                          ? MyColors.secondary_01
                                          : MyColors.primary_04),
                              textAlign: TextAlign.justify,
                            ),
                          )
                        ],
                      ),
                      content[2].isNotEmpty
                          ? Column(children: [
                              ...content[2]
                                  .asMap()
                                  .map(
                                    (index, content) => MapEntry(
                                        index,
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(width: 40),
                                            Row(
                                              children: [
                                                Text(content[0],
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2!
                                                        .copyWith(
                                                            fontSize: 16,
                                                            letterSpacing: 1)),
                                                SizedBox(width: 16),
                                              ],
                                            ),
                                            Expanded(
                                              child: Text(
                                                content[1],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2!
                                                    .copyWith(
                                                        fontSize: 16,
                                                        letterSpacing: 1),
                                              ),
                                            )
                                          ],
                                        )),
                                  )
                                  .values
                                  .toList()
                            ])
                          : SizedBox()
                    ],
                  ),
                ),
              )
              .values
              .toList(),
        ],
      );
    }

    return Scaffold(
        appBar: GeneralAppbar(
          title: t('setting_term'),
          routeName: TermsScreen.routeName,
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 60, horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section(t('tidewallet_service_of_terms'), '', [
                  [false, t('service_of_terms_1'), []],
                  [false, t('service_of_terms_2'), []],
                  [false, t('service_of_terms_3'), []],
                  [false, t('service_of_terms_4'), []],
                  [false, t('service_of_terms_5'), []],
                  [false, t('service_of_terms_6'), []],
                  [false, t('service_of_terms_7'), []],
                ]),
                SizedBox(height: 20),
                _section(t('risk_and_responsibility'), '', [
                  [false, t('risk_and_responsibility_1'), []],
                  [false, t('risk_and_responsibility_2'), []],
                  [false, t('risk_and_responsibility_3'), []],
                  [false, t('risk_and_responsibility_4'), []],
                  [false, t('risk_and_responsibility_5'), []],
                  [false, t('risk_and_responsibility_6'), []],
                  [false, t('risk_and_responsibility_7'), []],
                ]),
                SizedBox(height: 20),
                _section(t('privacy_management'), t('collected_information'), [
                  [false, t('collected_information_1'), []],
                  [false, t('collected_information_2'), []],
                  [true, t('collected_information_3'), []],
                  [
                    false,
                    t('collected_information_4'),
                    [
                      ['a.', t('collected_information_4_1')],
                      ['b.', t('collected_information_4_2')],
                      ['c.', t('collected_information_4_3')],
                      ['d.', t('collected_information_4_4')],
                      ['e.', t('collected_information_4_5')],
                    ]
                  ],
                ]),
                _section('', t('collection_way'), [
                  [false, t('collection_way_1'), []],
                  [false, t('collection_way_2'), []],
                  [false, t('collection_way_3'), []],
                ]),
                _section('', t('manage_your_information'), [
                  [false, t('manage_your_information_1'), []],
                  [false, t('manage_your_information_2'), []],
                  [false, t('manage_your_information_3'), []],
                  [false, t('manage_your_information_4'), []],
                  [false, t('manage_your_information_5'), []],
                ]),
                SizedBox(height: 20),
                _section(t('law_compliance'), t('jurisdiction'), [
                  [false, t('jurisdiction_1'), []],
                ]),
                _section('', t('limitation_of_liability'), [
                  [false, t('limitation_of_liability_1'), []],
                ]),
                _section('', t('intellectual_property_rights'), [
                  [false, t('intellectual_property_rights_1'), []],
                ]),
                Text(
                  t('contact_us'),
                  style: Theme.of(context).textTheme.headline2,
                ),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: t('have_any_questions_please_contact_us'),
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2!
                            .copyWith(fontSize: 16, letterSpacing: 1)),
                    TextSpan(
                        text: emailAddress,
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            fontSize: 16,
                            color: Theme.of(context).accentColor,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch(_emailLaunchUri.toString());
                          }),
                    TextSpan(
                        text: t('update_time', values: {
                          'year': '2021',
                          'month': '1',
                          'day': '27'
                        }),
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2!
                            .copyWith(fontSize: 16, letterSpacing: 1)),
                  ]),
                ),
              ],
            )));
  }
}
