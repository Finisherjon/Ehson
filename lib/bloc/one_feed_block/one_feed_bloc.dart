import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../api/models/one_feed_model.dart';
import '../../api/repository.dart';

part 'one_feed_event.dart';
part 'one_feed_state.dart';

class OneFeedBloc extends Bloc<OneFeedEvent, OneFeedState> {
  OneFeedBloc() : super(OneFeedState()) {

    //uzi jinni bugan manimcha ishlaydi xay
    on<OneFeedEvent>((event, emit) async {
      if (event is ReloadOneFeedEvent) {
        emit(state.copyWith(
            nextPageUrl: "",
            status: OneFeed.loading,
            islast: false,
            feed_comment: []));
        final product_response = await EhsonRepository().getonefeed(event.feed_id,state.nextPageUrl);

        return product_response!.feedData!.feedComments!.data!.isEmpty
            ? emit(state.copyWith(status: OneFeed.success, islast: true))
            : emit(state.copyWith(
            nextPageUrl: product_response.feedData!.feedComments!.nextPageUrl,
            status: OneFeed.success,
            feed_comment: List.of(state.feed_comment)
              ..addAll(product_response.feedData!.feedComments!.data!),
            feedOwner: product_response.feedData!.feedOwner,
            feed: product_response.feedData!.feed,
            islast: product_response.feedData!.feedComments!.nextPageUrl == null
                ? true
                : false));
      }

      //block tayyor endi ui ga uzin quwchi quwib xaybilasanmi? ha

      if (event is GetOneFeedEvent) {
        if (state.islast) return;
        try {
          if (state.status == OneFeed.loading) {
            final product_response =
                await EhsonRepository().getonefeed(event.feed_id,state.nextPageUrl);

            return product_response!.feedData!.feedComments!.data!.isEmpty
                ? emit(
                state.copyWith(status: OneFeed.success, islast: true))
                : emit(state.copyWith(
                status: OneFeed.success,
                nextPageUrl: product_response.feedData!.feedComments!.nextPageUrl,
                feed_comment: product_response.feedData!.feedComments!.data!,
                feedOwner: product_response.feedData!.feedOwner!,
                feed:product_response.feedData!.feed!,
                islast: product_response.feedData!.feedComments!.nextPageUrl == null
                    ? true
                    : false));
          } else {
            final product_response =
                await EhsonRepository().getonefeed(event.feed_id,state.nextPageUrl);
            return product_response!.feedData!.feedComments!.data!.isEmpty
                ? emit(state.copyWith(islast: true))
                : emit(state.copyWith(
                nextPageUrl: product_response.feedData!.feedComments!.nextPageUrl,
                status: OneFeed.success,
                feed_comment: List.of(state.feed_comment)
                  ..addAll(product_response.feedData!.feedComments!.data!),
                islast: product_response.feedData!.feedComments!.nextPageUrl == null
                    ? true
                    : false));
          }
        } catch (e) {
          if (state.status == OneFeed.loading) {
            return emit(state.copyWith(
                status: OneFeed.error,
                errorMessage: "failed to fetch posts"));
          } else {
            return;
          }
        }
      }
    });
  }
}
