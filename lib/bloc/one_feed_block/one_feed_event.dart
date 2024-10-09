part of 'one_feed_bloc.dart';

abstract class OneFeedEvent extends Equatable {
  final int feed_id;

  const OneFeedEvent({required this.feed_id});

  @override
  List<Object> get props => [];
}

class GetOneFeedEvent extends OneFeedEvent {
  GetOneFeedEvent({required super.feed_id});
}

class ReloadOneFeedEvent extends OneFeedEvent {
  ReloadOneFeedEvent({required super.feed_id});
}

