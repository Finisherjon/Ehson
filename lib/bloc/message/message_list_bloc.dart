import 'package:bloc/bloc.dart';
import 'package:ehson/api/models/message_list_model.dart';
import 'package:equatable/equatable.dart';

import '../../api/repository.dart';
part 'message_list_event.dart';
part 'message_list_state.dart';

class MessageListBloc extends Bloc<MessageListEvent, MessageListState> {
  MessageListBloc() : super(MessageListState()) {
    on<MessageListEvent>((event, emit) async{
      if (event is ReloadMessageListEvent) {
        try{
          emit(state.copyWith(
              nextPageUrl: "",
              status: MessageList.loading,
              islast: false,
              products: []));
          final product_response =
          await EhsonRepository().getmessages(event.chat_id,state.nextPageUrl);

          return product_response!.messages!.data!.isEmpty
              ? emit(state.copyWith(status: MessageList.success, islast: true))
              : emit(state.copyWith(
              nextPageUrl: product_response.messages!.nextPageUrl,
              status: MessageList.success,
              products: List.of(state.messages)
                ..addAll(product_response.messages!.data!),
              islast: product_response.messages!.nextPageUrl == null
                  ? true
                  : false));
        }
        catch (e) {
          if (state.status == MessageList.loading) {
            return emit(state.copyWith(
                status: MessageList.error, errorMessage: "failed to fetch posts"));
          } else {
            return emit(state.copyWith(
                status: MessageList.error, errorMessage: "failed to fetch posts"));
          }
        }
      }
      if (event is GetMessageListEvent) {
        if (state.islast) return;
        try {
          if (state.status == MessageList.loading) {
            // final result = await ParentRepository().getchildnotif(event.childuid,next_page_url);
            final product_response = await EhsonRepository()
                .getmessages(event.chat_id,state.nextPageUrl);

            return product_response!.messages!.data!.isEmpty
                ? emit(state.copyWith(status: MessageList.success, islast: true))
                : emit(state.copyWith(
                status: MessageList.success,
                nextPageUrl: product_response.messages!.nextPageUrl,
                products: product_response.messages!.data!,
                islast: product_response.messages!.nextPageUrl == null
                    ? true
                    : false));
          } else {
            final product_response = await EhsonRepository()
                .getmessages(event.chat_id,state.nextPageUrl);
            return product_response!.messages!.data!.isEmpty
                ? emit(state.copyWith(islast: true))
                : emit(state.copyWith(
                nextPageUrl: product_response.messages!.nextPageUrl,
                status: MessageList.success,
                products: List.of(state.messages)
                  ..addAll(product_response.messages!.data!),
                islast: product_response.messages!.nextPageUrl == null
                    ? true
                    : false));
          }
        } catch (e) {
          if (state.status == MessageList.loading) {
            return emit(state.copyWith(
                status: MessageList.error, errorMessage: "failed to fetch posts"));
          } else {
            return;
          }
        }
      }
    });
  }
}
