import 'package:bloc/bloc.dart';
import 'package:ehson/api/models/chats_list_model.dart';
import 'package:meta/meta.dart';

import '../../api/repository.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  ChatListBloc() : super(ChatListInitial()) {
    on<ChatListEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<ChatListLoadingData>((event, emit) async {
      emit(ChatListLoading());
      // await Future.delayed(Duration(seconds: 3), () {
      //   // Your code
      // });
      try{
        final result = await EhsonRepository().get_chats();
        if (result != null){
          emit(ChatListSuccess(chatListModel: result));
        }
        else{
          emit(ChatListError());
        }
      }
      catch(e){
        print(e.toString());
        emit(ChatListError());
      }
    });
  }
}
