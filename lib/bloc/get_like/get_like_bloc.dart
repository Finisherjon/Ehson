import 'package:bloc/bloc.dart';
import 'package:ehson/api/models/get_like_model.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../api/repository.dart';
part 'get_like_event.dart';
part 'get_like_state.dart';

class GetLikeBloc extends Bloc<LikeEvent, GetLikeState> {
  GetLikeBloc() : super(GetLikeState()) {
    on<LikeEvent>((event, emit) async{
      if (event is ReloadLikeEvent) {
        emit(state.copyWith(
            nextPageUrl: "",
            status: GetLike.loading,
            islast: false,
            products: []));
        final product_response =
            await EhsonRepository().get_like(state.nextPageUrl);

        return product_response!.likedProducts!.data!.isEmpty
            ? emit(state.copyWith(status: GetLike.success, islast: true))
            : emit(state.copyWith(
            nextPageUrl: product_response.likedProducts!.nextPageUrl,
            status: GetLike.success,
            products: List.of(state.products)
              ..addAll(product_response.likedProducts!.data!),
            islast: product_response.likedProducts!.nextPageUrl == null
                ? true
                : false));
      }
      if (event is GetLikeEvent) {
        if (state.islast) return;
        try {
          if (state.status == GetLike.loading) {
            // final result = await ParentRepository().getchildnotif(event.childuid,next_page_url);
            final product_response = await EhsonRepository()
                .get_like(state.nextPageUrl);

            return product_response!.likedProducts!.data!.isEmpty
                ? emit(state.copyWith(status: GetLike.success, islast: true))
                : emit(state.copyWith(
                status: GetLike.success,
                nextPageUrl: product_response.likedProducts!.nextPageUrl,
                products: product_response.likedProducts!.data!,
                islast: product_response.likedProducts!.nextPageUrl == null
                    ? true
                    : false));
          } else {
            final product_response = await EhsonRepository()
                .get_like(state.nextPageUrl);
            return product_response!.likedProducts!.data!.isEmpty
                ? emit(state.copyWith(islast: true))
                : emit(state.copyWith(
                nextPageUrl: product_response.likedProducts!.nextPageUrl,
                status: GetLike.success,
                products: List.of(state.products)
                  ..addAll(product_response.likedProducts!.data!),
                islast: product_response.likedProducts!.nextPageUrl == null
                    ? true
                    : false));
          }
        } catch (e) {
          if (state.status == GetLike.loading) {
            return emit(state.copyWith(
                status: GetLike.error, errorMessage: "failed to fetch posts"));
          } else {
            return;
          }
        }
      }
    });
  }
}
