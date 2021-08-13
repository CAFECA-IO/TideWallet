part of 'scan_bloc.dart';

abstract class ScanState extends Equatable {
  const ScanState();

  @override
  List<Object> get props => [];
}

class ScanInitial extends ScanState {}

class ScannedAddress extends ScanState {
  final Account account;
  final String address;
  ScannedAddress(this.account, this.address);
}

class ScannedWalletConnect extends ScanState {
  final String uri;
  ScannedWalletConnect(this.uri);
}

class ErrorFormat extends ScanState {}
