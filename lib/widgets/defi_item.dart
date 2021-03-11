import '../models/investment.model.dart';
import 'package:flutter/material.dart';

class DefiItem extends StatelessWidget {
  Investment _ivt;

  DefiItem(this._ivt);
  // TODO
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue[500], Colors.green[300]]),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(backgroundImage: NetworkImage(_ivt.iconUrl)),
          SizedBox(width: 16.0),
          Expanded(
            child: Text(_ivt.name,
                style: Theme.of(context).textTheme.headline2,
                textAlign: TextAlign.left),
          ),
          // Container(
          //   child: Icon(
          //     Icons.chevron_right,
          //     color: Theme.of(context).primaryColor,
          //   ),
          //   alignment: Alignment.centerRight,
          // )
        ],
      ),
    );
  }
}
