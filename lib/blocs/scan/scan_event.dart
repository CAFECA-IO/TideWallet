part of 'scan_bloc.dart';

abstract class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object> get props => [];
}

class ScanQRCode extends ScanEvent {
  final String result;
  ScanQRCode(this.result);
}
