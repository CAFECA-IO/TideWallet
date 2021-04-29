import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import '../blocs/buy_tide_point/buy_tide_point_bloc.dart';
import '../repositories/buy_tide_point_repository.dart';
import '../widgets/appBar.dart';
import '../widgets/dialogs/loading_dialog.dart';
import '../widgets/dialogs/dialog_controller.dart';
import '../widgets/dialogs/error_dialog.dart';
import '../helpers/logger.dart';

class BuyTidePointScreen extends StatefulWidget {
  static const routeName = '/buying';
  @override
  _BuyTidePointScreenState createState() => _BuyTidePointScreenState();
}

class _BuyTidePointScreenState extends State<BuyTidePointScreen> {
  BuyTidePointBloc _bloc;
  BuyTidePointRepository _repo;

  StreamSubscription<List<PurchaseDetails>> _subscription;
  @override
  void didChangeDependencies() {
    _repo = Provider.of<BuyTidePointRepository>(context);
    _bloc = BuyTidePointBloc(_repo);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BuyTidePointBloc, BuyTidePointState>(
      bloc: _bloc,
      listener: (context, state) {},
      child: BlocBuilder<BuyTidePointBloc, BuyTidePointState>(
        bloc: _bloc,
        builder: (context, state) {
          return Scaffold(
            appBar: GeneralAppbar(
              title: 'Buy TideWallet Point',
              routeName: BuyTidePointScreen.routeName,
            ),
          );
        },
      ),
    );
  }
}
