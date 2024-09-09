import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../api/models/product_model.dart';
import '../../api/repository.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<ProductEvent, ProductState> {
  HomeBloc() : super(ProductState()) {
    // on<HomeEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
    //shundan kuchirish kerak ed
    on<ProductEvent>((event, emit) async {
      if (event is ReloadProductEvent) {
        emit(state.copyWith(
            nextPageUrl: "",
            status: Product.loading,
            islast: false,
            products: []));
        final product_response =
            await EhsonRepository().getproduct(state.nextPageUrl, event.date);

        return product_response!.products!.data!.isEmpty
            ? emit(state.copyWith(status: Product.success, islast: true))
            : emit(state.copyWith(
                nextPageUrl: product_response.products!.nextPageUrl,
                status: Product.success,
                products: List.of(state.products)
                  ..addAll(product_response.products!.data!),
                islast: product_response.products!.nextPageUrl == null
                    ? true
                    : false));
      }

      if (event is GetProductEvent) {
        if (state.islast) return;
        try {
          if (state.status == Product.loading) {
            // final result = await ParentRepository().getchildnotif(event.childuid,next_page_url);
            final product_response = await EhsonRepository()
                .getproduct(state.nextPageUrl, event.date);

            return product_response!.products!.data!.isEmpty
                ? emit(state.copyWith(status: Product.success, islast: true))
                : emit(state.copyWith(
                    status: Product.success,
                    nextPageUrl: product_response.products!.nextPageUrl,
                    products: product_response.products!.data!,
                    islast: product_response.products!.nextPageUrl == null
                        ? true
                        : false));
          } else {
            final product_response = await EhsonRepository()
                .getproduct(state.nextPageUrl, event.date);
            return product_response!.products!.data!.isEmpty
                ? emit(state.copyWith(islast: true))
                : emit(state.copyWith(
                    nextPageUrl: product_response.products!.nextPageUrl,
                    status: Product.success,
                    products: List.of(state.products)
                      ..addAll(product_response.products!.data!),
                    islast: product_response.products!.nextPageUrl == null
                        ? true
                        : false));
          }
        } catch (e) {
          if (state.status == Product.loading) {
            return emit(state.copyWith(
                status: Product.error, errorMessage: "failed to fetch posts"));
          } else {
            return;
          }
        }
      }
    });
  }
}
