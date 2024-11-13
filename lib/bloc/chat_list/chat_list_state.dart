part of 'chat_list_bloc.dart';

@immutable
sealed class ChatListState {}

final class ChatListInitial extends ChatListState {}

final class ChatListLoading extends ChatListState {}
final class ChatListSuccess extends ChatListState {
  ChatListModel chatListModel;
  ChatListSuccess({required this.chatListModel});
}
final class ChatListError extends ChatListState {}