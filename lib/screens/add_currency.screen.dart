import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../blocs/add_currency/add_currency_bloc.dart';
import '../repositories/account_repository.dart';
import '../widgets/appBar.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/dialogs/dialog_controller.dart';
import '../widgets/dialogs/error_dialog.dart';
import '../widgets/dialogs/loading_dialog.dart';
import '../widgets/inputs/input.dart';
import '../helpers/i18n.dart';

final t = I18n.t;

class AddCurrencyScreen extends StatefulWidget {
  static const routeName = '/add-currency';
  @override
  _AddCurrencyScreenState createState() => _AddCurrencyScreenState();
}

class _AddCurrencyScreenState extends State<AddCurrencyScreen> {
  AddCurrencyBloc _bloc;
  AccountRepository _repo;
  TextEditingController _controller = TextEditingController();

  @override
  void didChangeDependencies() {
    _repo = Provider.of<AccountRepository>(context);
    _bloc = AddCurrencyBloc(_repo);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppbar(
        routeName: AddCurrencyScreen.routeName,
      ),
      body: BlocBuilder<AddCurrencyBloc, AddCurrencyState>(
        cubit: _bloc,
        builder: (context, state) {
          Widget result = SizedBox();
          bool addable =
              (state is BeforeAdd && state.valid && state.result != null);

          if (state is BeforeAdd) {
            Widget item(String _title, String _value) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  text: TextSpan(
                    text: '$_title：\n',
                    children: [
                      TextSpan(
                          text: _value,
                          style: Theme.of(context).textTheme.bodyText1)
                    ],
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2
                        .copyWith(height: 1.5),
                  ),
                ),
              );
            }

            if (state.result != null && state.valid) {
              result = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      state.result.imgUrl,
                      width: 80.0,
                      height: 80.0,
                    ),
                  ),
                  item(t('symbol'), state.result.symbol),
                  item(t('name'), state.result.name),
                  item(t('contract'), state.result.contract),
                  item(t('decimal'), state.result.decimal.toString()),
                  item(t('total_supply'), state.result.totalSupply.toString()),
                  item(t('description'), state.result.description),
                ],
              );
            }
          }

          return BlocListener<AddCurrencyBloc, AddCurrencyState>(
            cubit: _bloc,
            listener: (context, state) {
              if (state is BeforeAdd) {
                if (state.loading) {
                  DialogController.show(context, LoadingDialog());
                }
              }
              if (state is AddSuccess) {
                DialogController.dismiss(context);
                Navigator.of(context).pop();
              }

              if (state is AddFail) {
                DialogController.dismiss(context);
                DialogController.show(context, ErrorDialog(t('error_add')));
              }
            },
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(children: [
                Input(
                  labelText: t('enter_address'),
                  controller: _controller,
                  autovalidate: AutovalidateMode.always,
                  validator: (String v) {
                    if (!_repo.validateETHAddress(v) &&
                        _controller.text.isNotEmpty) {
                      return t('error_address');
                    }

                    return null;
                  },
                  onChanged: (String v) {
                    _bloc.add(EnterAddress(v));
                  },
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: result,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: PrimaryButton(
                    t('add'),
                    addable
                        ? () {
                            _bloc.add(AddToken());
                          }
                        : null,
                    disableColor: Theme.of(context).disabledColor,
                    borderColor: Colors.transparent,
                  ),
                )
              ]),
            ),
          );
        },
      ),
    );
  }
}
