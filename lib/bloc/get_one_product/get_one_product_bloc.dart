import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../api/models/one_product_model.dart';
import '../../api/repository.dart';

part 'get_one_product_event.dart';

part 'get_one_product_state.dart';

class GetOneProductBloc extends Bloc<GetOneProductEvent, GetOneProductState> {
  GetOneProductBloc() : super(GetOneProductInitial()) {
    on<GetOneProductEvent>((event, emit) async {});

    on<GetOneProductLoadingData>((event, emit) async {
      emit(GetOneProductLoading());
      try {
        final result = await EhsonRepository().getoneproduct(event.product_id);
        if (result != null) {
          emit(GetOneProductSuccess(oneProductModel: result));
        } else {
          emit(GetOneProductError());
        }
      } catch (e) {
        print(e.toString());
        emit(GetOneProductError());
      }
    });
  }
}
