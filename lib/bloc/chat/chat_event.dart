part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  final String date;

  const ChatEvent({required this.date});

  @override
  List<Object> get props => [];
}

class GetchatEvent extends ChatEvent {
  GetchatEvent({required super.date});
}

class ReloadchatEvent extends ChatEvent {
  ReloadchatEvent({required super.date});
}
