// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:meta/meta.dart';
//
// import '../../api/models/chat_model.dart';
// import '../../api/repository.dart';
// import '../search_product/search_product_bloc.dart';
// // import '../search_product/search_product_bloc.dart';
// // import '../search_product/search_product_bloc.dart';
//
// part 'get_filter_product_event.dart';
//
// part 'get_filter_product_state.dart';
//
// class GetFilterProductBloc
//     extends Bloc<GetFilterProductEvent, GetFilterProductState> {
//   GetFilterProductBloc() : super(GetFilterProductState()) {
//     on<GetFilterProductEvent>((event, emit) async {
//       if (event is ReloadGetFilterProductEvent) {
//         emit(state.copyWith(
//             nextPageUrl: "",
//             status: FilterProduct.loading,
//             islast: false,
//             products: []));
//         final product_response = await EhsonRepository().filter_product(
//             event.category_id as int, event.city_id as int, state.nextPageUrl);
//         return product_response!.products!.data!.isEmpty
//             ? emit(state.copyWith(status: FilterProduct.success, islast: true))
//             : emit(state.copyWith(
//                 nextPageUrl: product_response.products!.nextPageUrl,
//                 status: FilterProduct.success,
//                 products: List.of(state.products)
//                   ..addAll(product_response.products!.data! as Iterable<Data>),
//                 islast: product_response.products!.nextPageUrl == null
//                     ? true
//                     : false));
//       }
//
//       if (event is FilterProductGetEvent) {
//         if (state.islast) return;
//         try {
//           if (state.status == FilterProduct.loading) {
//             final product_response = await EhsonRepository().filter_product(
//                 event.category_id as int,
//                 event.city_id as int,
//                 state.nextPageUrl);
//
//             return product_response!.products!.data!.isEmpty
//                 ? emit(
//                     state.copyWith(status: FilterProduct.success, islast: true))
//                 : emit(state.copyWith(
//                     status: FilterProduct.success,
//                     nextPageUrl: product_response.products!.nextPageUrl,
//                     products: product_response.products!.data,
//                     islast: product_response.products!.nextPageUrl == null
//                         ? true
//                         : false));
//           } else {
//             final product_response = await EhsonRepository().filter_product(
//                 event.category_id as int,
//                 event.city_id as int,
//                 state.nextPageUrl);
//             return product_response!.products!.data!.isEmpty
//                 ? emit(state.copyWith(islast: true))
//                 : emit(state.copyWith(
//                     nextPageUrl: product_response.products!.nextPageUrl,
//                     status: FilterProduct.success,
//                     products: List.of(state.products)
//                       ..addAll(
//                           product_response.products!.data! as Iterable<Data>),
//                     islast: product_response.products!.nextPageUrl == null
//                         ? true
//                         : false));
//           }
//         } catch (e) {
//           if (state.status == FilterProduct.loading) {
//             return emit(state.copyWith(
//                 status: FilterProduct.error,
//                 errorMessage: "failed to fetch posts"));
//           } else {
//             return;
//           }
//         }
//       }
//     });
//   }
// }

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../api/models/get_filter_product_model.dart' as filter_model;
import '../../api/models/get_filter_product_model.dart';
import '../../api/repository.dart';

part 'get_filter_product_event.dart';
part 'get_filter_product_state.dart';

class GetFilterProductBloc extends Bloc<GetFilterProductEvent, GetFilterProductState> {
  GetFilterProductBloc() : super(GetFilterProductState()) {
    on<GetFilterProductEvent>((event, emit) async {
      if (event is ReloadGetFilterProductEvent) {
        emit(state.copyWith(
            nextPageUrl: "",
            status: FilterProduct.loading,
            islast: false,
            products: []));

        final product_response = await EhsonRepository().filter_product(
            event.category_id as int, event.city_id as int, state.nextPageUrl);

        return product_response!.products!.data!.isEmpty
            ? emit(state.copyWith(status: FilterProduct.success, islast: true))
            : emit(state.copyWith(
            nextPageUrl: product_response.products!.nextPageUrl,
            status: FilterProduct.success,
            products: List.of(state.products)
              ..addAll(product_response.products!.data! as List<filter_model.Data>),
            islast: product_response.products!.nextPageUrl == null ? true : false));
      }

      if (event is FilterProductGetEvent) {
        if (state.islast) return;

        try {
          if (state.status == FilterProduct.loading) {
            final product_response = await EhsonRepository().filter_product(
                event.category_id as int, event.city_id as int, state.nextPageUrl);

            return product_response!.products!.data!.isEmpty
                ? emit(state.copyWith(status: FilterProduct.success, islast: true))
                : emit(state.copyWith(
                status: FilterProduct.success,
                nextPageUrl: product_response.products!.nextPageUrl,
                products: product_response.products!.data as List<filter_model.Data>,
                islast: product_response.products!.nextPageUrl == null ? true : false));
          } else {
            final product_response = await EhsonRepository().filter_product(
                event.category_id as int, event.city_id as int, state.nextPageUrl);

            return product_response!.products!.data!.isEmpty
                ? emit(state.copyWith(islast: true))
                : emit(state.copyWith(
                nextPageUrl: product_response.products!.nextPageUrl,
                status: FilterProduct.success,
                products: List.of(state.products)
                  ..addAll(product_response.products!.data! as List<filter_model.Data>),
                islast: product_response.products!.nextPageUrl == null ? true : false));
          }
        } catch (e) {
          if (state.status == FilterProduct.loading) {
            return emit(state.copyWith(
                status: FilterProduct.error,
                errorMessage: "failed to fetch posts"));
          } else {
            return;
          }
        }
      }
    });
  }
}
