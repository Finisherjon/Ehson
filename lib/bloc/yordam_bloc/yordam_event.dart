part of 'yordam_bloc.dart';

abstract class YordamEvent extends Equatable {
  final String date;
  const YordamEvent({required this.date});

  @override
  List<Object> get props => [];
}

class GetYordamEvent extends YordamEvent{
  GetYordamEvent({required super.date});
}
class ReloadYordamEvent extends YordamEvent{
  ReloadYordamEvent({required super.date});
}
