import 'package:flutter/material.dart';

import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

class PersonalSign extends StatelessWidget {
  final Function submit;
  final Function cancel;
  final String message;

  PersonalSign({
    @required this.submit,
    @required this.cancel,
    @required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
      child: Wrap(alignment: WrapAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text('$message', textAlign: TextAlign.center,),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PrimaryButton(
              '發送',
              this.submit,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SecondaryButton(
              '取消',
              this.cancel,
            ),
          )
        ],
      ),
    );
  }
}
