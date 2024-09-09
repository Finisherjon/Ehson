import 'package:bloc/bloc.dart';
import 'package:ehson/api/repository.dart';
import 'package:meta/meta.dart';

import '../../api/models/category_model.dart';

part 'add_product_event.dart';
part 'add_product_state.dart';

class AddProductBloc extends Bloc<AddProductEvent, AddProductState> {
  AddProductBloc() : super(AddProductInitial()) {
    on<AddProductEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<AddProductLoadingData>((event, emit) async {
      emit(AddProductLoading());
      // await Future.delayed(Duration(seconds: 3), () {
      //   // Your code
      // });
      try{
        final result = await EhsonRepository().get_category();
        if (result != null){
          emit(AddProductSuccess(categoryModel: result));
        }
        else{
          emit(AddProductError());
        }
      }
      catch(e){
        print(e.toString());
        emit(AddProductError());
      }
    });
  }
}
