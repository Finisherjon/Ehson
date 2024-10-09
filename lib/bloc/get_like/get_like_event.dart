part of 'get_like_bloc.dart';

abstract class LikeEvent extends Equatable {
  final String date;

  const LikeEvent({required this.date});

  @override
  List<Object> get props => [];
}

class GetLikeEvent extends LikeEvent {
  GetLikeEvent({required super.date});
}


class ReloadLikeEvent extends LikeEvent {
  ReloadLikeEvent({required super.date});
}