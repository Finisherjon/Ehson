import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../api/models/chat_model.dart';
import '../../api/repository.dart';

part 'chat_event.dart';

part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatState()) {
    on<ChatEvent>((event, emit) async {
      if (event is ReloadchatEvent) {
        try{
          emit(state.copyWith(
              nextPageUrl: "",
              status: ChatProduct.loading,
              islast: false,
              products: []));
          final product_response =
          await EhsonRepository().getmavzu(state.nextPageUrl, event.date);

          return product_response!.feeds!.data!.isEmpty
              ? emit(state.copyWith(status: ChatProduct.success, islast: true))
              : emit(state.copyWith(
              nextPageUrl: product_response.feeds!.nextPageUrl,
              status: ChatProduct.success,
              products: List.of(state.products)
                ..addAll(product_response.feeds!.data!),
              islast: product_response.feeds!.nextPageUrl == null
                  ? true
                  : false));
        }
        catch (e) {
          if (state.status == ChatProduct.loading) {
            return emit(state.copyWith(
                status: ChatProduct.error,
                errorMessage: "failed to fetch posts"));
          } else {
            return emit(state.copyWith(
                status: ChatProduct.error,
                errorMessage: "failed to fetch posts"));
          }
        }
      }

      if (event is GetchatEvent) {
        if (state.islast) return;
        try {
          if (state.status == ChatProduct.loading) {
            final product_response =
                await EhsonRepository().getmavzu(state.nextPageUrl, event.date);

            return product_response!.feeds!.data!.isEmpty
                ? emit(
                    state.copyWith(status: ChatProduct.success, islast: true))
                : emit(state.copyWith(
                    status: ChatProduct.success,
                    nextPageUrl: product_response.feeds!.nextPageUrl,
                    products: product_response.feeds!.data!,
                    islast: product_response.feeds!.nextPageUrl == null
                        ? true
                        : false));
          } else {
            final product_response =
                await EhsonRepository().getmavzu(state.nextPageUrl, event.date);
            return product_response!.feeds!.data!.isEmpty
                ? emit(state.copyWith(islast: true))
                : emit(state.copyWith(
                    nextPageUrl: product_response.feeds!.nextPageUrl,
                    status: ChatProduct.success,
                    products: List.of(state.products)
                      ..addAll(product_response.feeds!.data!),
                    islast: product_response.feeds!.nextPageUrl == null
                        ? true
                        : false));
          }
        } catch (e) {
          if (state.status == ChatProduct.loading) {
            return emit(state.copyWith(
                status: ChatProduct.error,
                errorMessage: "failed to fetch posts"));
          } else {
            return emit(state.copyWith(
                status: ChatProduct.error,
                errorMessage: "failed to fetch posts"));
          }
        }
      }
    });
  }
}
