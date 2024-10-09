import 'package:bloc/bloc.dart';
import 'package:ehson/api/models/yordam_model.dart';
import 'package:ehson/api/models/yordam_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../api/repository.dart';

part 'yordam_event.dart';

part 'yordam_state.dart';


//yordam blockga uxshagan qilishin kerak chunki bu ham scrool bo'ganiga qolgan like productlani olishi kerak bir marta ogan payt 10 tasini oladi keyen scroll buganga yana 10 tasini shu uchun yordam block qilinganday qilasan
class YordamBloc extends Bloc<YordamEvent, YordamState> {
  YordamBloc() : super(YordamState()) {
    on<YordamEvent>((event, emit) async {
      if (event is ReloadYordamEvent) {
        emit(state.copyWith(
            nextPageUrl: "",
            status: YordamProduct.loading,
            islast: false,
            products: []));
        final product_response =
        await EhsonRepository().getyordam(state.nextPageUrl, event.date);

        return product_response!.helps!.data!.isEmpty
            ? emit(state.copyWith(status: YordamProduct.success, islast: true))
            : emit(state.copyWith(
            nextPageUrl: product_response.helps!.nextPageUrl,
            status: YordamProduct.success,
            products: List.of(state.products)
              ..addAll(product_response.helps!.data!),
            islast: product_response.helps!.nextPageUrl == null
                ? true
                : false));
      }
      if (event is GetYordamEvent) {
        if (state.islast) return;
        try {
          if (state.status == YordamProduct.loading) {
            // final result = await ParentRepository().getchildnotif(event.childuid,next_page_url);
            final product_response = await EhsonRepository()
                .getyordam(state.nextPageUrl, event.date);

            return product_response!.helps!.data!.isEmpty
                ? emit(state.copyWith(status: YordamProduct.success, islast: true))
                : emit(state.copyWith(
                status: YordamProduct.success,
                nextPageUrl: product_response.helps!.nextPageUrl,
                products: product_response.helps!.data!,
                islast: product_response.helps!.nextPageUrl == null
                    ? true
                    : false));
          } else {
            final product_response = await EhsonRepository()
                .getyordam(state.nextPageUrl, event.date);
            return product_response!.helps!.data!.isEmpty
                ? emit(state.copyWith(islast: true))
                : emit(state.copyWith(
                nextPageUrl: product_response.helps!.nextPageUrl,
                status: YordamProduct.success,
                products: List.of(state.products)
                  ..addAll(product_response.helps!.data!),
                islast: product_response.helps!.nextPageUrl == null
                    ? true
                    : false));
          }
        } catch (e) {
          if (state.status == YordamProduct.loading) {
            return emit(state.copyWith(
                status: YordamProduct.error, errorMessage: "failed to fetch posts"));
          } else {
            return;
          }
        }
      }
    });
  }
}
