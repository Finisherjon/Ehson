import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../api/models/search_model.dart';
import '../../api/repository.dart';

part 'search_product_event.dart';

part 'search_product_state.dart';

class SearchProductBloc extends Bloc<SearchProductEvent, SearchProductState> {
  SearchProductBloc() : super(SearchProductState()) {
    on<SearchProductEvent>((event, emit) async {
      if (event is ReloadSearchProductEvent) {
        emit(state.copyWith(
            nextPageUrl: "",
            status: SearchProduct.loading,
            islast: false,
            products: []));
        //block tayor ui ni tugirla
        //hoem ui bilan bir xil buladi
        final product_response =
        await EhsonRepository().searchproduct(event.text,state.nextPageUrl);
//tugirlab chiq
        return product_response!.products!.data!.isEmpty
            ? emit(state.copyWith(status: SearchProduct.success, islast: true))
            : emit(state.copyWith(
            nextPageUrl: product_response.products!.nextPageUrl,
            status: SearchProduct.success,
            products: List.of(state.products)
              ..addAll(product_response.products!.data!),
            islast: product_response.products!.nextPageUrl == null
                ? true
                : false));
      }

      if (event is GetSearchProductEvent) {
        if (state.islast) return;
        //buldi tugirlab chiqchi
        try {
          if (state.status == SearchProduct.loading) {
            // final result = await ParentRepository().getchildnotif(event.childuid,next_page_url);
            final product_response = await EhsonRepository()
                .searchproduct(event.text,state.nextPageUrl);

            return product_response!.products!.data!.isEmpty
                ? emit(state.copyWith(status: SearchProduct.success, islast: true))
                : emit(state.copyWith(
                status: SearchProduct.success,
                nextPageUrl: product_response.products!.nextPageUrl,
                products: product_response.products!.data,
                islast: product_response.products!.nextPageUrl == null
                    ? true
                    : false));
          } else {

            //product_response apiga murojaat qiladigan funksiya nimaga uzgartirmayopsan
            final product_response = await EhsonRepository()
                .searchproduct(event.text,state.nextPageUrl);
            return product_response!.products!.data!.isEmpty
                ? emit(state.copyWith(islast: true))
                : emit(state.copyWith(
                nextPageUrl: product_response.products!.nextPageUrl,
                status: SearchProduct.success,
                products: List.of(state.products)
                  ..addAll(product_response.products!.data!),
                islast: product_response.products!.nextPageUrl == null
                    ? true
                    : false));
          }
        } catch (e) {
          if (state.status == SearchProduct.loading) {
            return emit(state.copyWith(
                status: SearchProduct.error, errorMessage: "failed to fetch posts"));
          } else {
            return;
          }
        }
      }
    });
  }
}
