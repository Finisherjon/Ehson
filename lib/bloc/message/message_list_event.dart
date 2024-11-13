part of 'message_list_bloc.dart';


abstract class MessageListEvent extends Equatable {
  final int chat_id;

  const MessageListEvent({required this.chat_id});

  @override
  List<Object> get props => [];
}

class GetMessageListEvent extends MessageListEvent {
  GetMessageListEvent({required super.chat_id});
}

class ReloadMessageListEvent extends MessageListEvent {
  ReloadMessageListEvent({required super.chat_id});
}
