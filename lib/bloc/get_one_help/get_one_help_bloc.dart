import 'package:bloc/bloc.dart';
import 'package:ehson/api/models/one_help_model.dart';
import 'package:ehson/api/repository.dart';
import 'package:meta/meta.dart';

part 'get_one_help_event.dart';

part 'get_one_help_state.dart';

class GetOneHelpBloc extends Bloc<GetOneHelpEvent, GetOneHelpState> {
  GetOneHelpBloc() : super(GetOneHelpInitial()) {
    on<GetOneHelpEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<GetOneHelpLoadingDate>((event, emit) async {
      emit(GetOneHelpLoading());
      try {
        final result = await EhsonRepository().getonehelp(event.help_id);
        if (result != null) {
          emit(GetOneHelpSuccess(oneHelpModel: result));
        } else {
          emit(GetOneHelpError());
        }
      } catch (e) {
        print(e.toString());
        emit(GetOneHelpError());
      }
    });
  }
}
