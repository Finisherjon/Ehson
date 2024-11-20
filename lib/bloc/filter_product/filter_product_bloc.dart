import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../api/models/category_model.dart';
import '../../api/models/chat_model.dart';
import '../../api/repository.dart';

part 'filter_product_event.dart';

part 'filter_product_state.dart';

class FilterProductBloc extends Bloc<FilterProductEvent, FilterProductState> {
  FilterProductBloc() : super(FilterProductInitial()) {
    on<FilterProductEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<FilterProductLoadingData>((event, emit) async {
      emit(FilterProductLoading());
      try {
        final result = await EhsonRepository().get_category();
        if (result != null) {
          emit(FilterProductSuccess(categoryModel: result));
        } else {
          emit(FilterProductError());
        }
      } catch (e) {
        print(e.toString());
        emit(FilterProductError());
      }
    });
  }
}
