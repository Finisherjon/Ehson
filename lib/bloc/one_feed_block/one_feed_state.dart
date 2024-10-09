part of 'one_feed_bloc.dart';

enum OneFeed { loading, success, error }

class OneFeedState extends Equatable {
  final OneFeed status;
  final List<Data> feed_comment;
  final FeedOwner? feedOwner;
  final Feed? feed;
  final bool islast;
  final String errorMessage;
  final String? nextPageUrl;

  const OneFeedState(
      {this.status = OneFeed.loading,
        this.islast = false,
        this.feed_comment = const [],
        this.feedOwner = null,
        this.feed = null,
        this.errorMessage = "",
        this.nextPageUrl = ""});

  OneFeedState copyWith({
    OneFeed? status,
    List<Data>? feed_comment,
    FeedOwner? feedOwner,
    Feed? feed,
    bool? islast,
    String? errorMessage,
    String? nextPageUrl,
  }) {
    return OneFeedState(
      status: status ?? this.status,
      feed_comment: feed_comment ?? this.feed_comment,
      feedOwner: feedOwner ?? this.feedOwner,
      feed: feed ?? this.feed,
      islast: islast ?? this.islast,
      errorMessage: errorMessage ?? this.errorMessage,
      nextPageUrl: nextPageUrl,
    );
  }

  @override
  List<Object?> get props =>
      [status, feed_comment,feedOwner,feed, islast, errorMessage, nextPageUrl];
}

