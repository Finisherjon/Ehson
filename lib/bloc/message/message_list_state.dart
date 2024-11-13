part of 'message_list_bloc.dart';


enum MessageList { loading, success, error }

class MessageListState extends Equatable {
  final MessageList status;
  final List<Data> messages;
  final bool islast;
  final String errorMessage;
  final String? nextPageUrl;

  //bera qaysi tartibga yozgasiz
  //qanoqa tartib
  //boshqachaku
  //shunay bera equatable qilingan block technalogiya buyam faqat boshqacharoq
  //scroll qigan payt boshqa tavarlaniyam olish uchun shunay qilish kerak
  //agar faqat bir marta serverdan malumot osan va o'zgarmasa eski yul bilan qisan buladi
  //agar scroll qigan payt serverdan malumot olib bor malumotni yonidan qushish kerak busa shunoqa yul qilinadi
  //xay buni birorota saytdan taxlasa buladimi xuddi json to dartday
  //mana tayor home block borku buni unoqa qimaysan uzin yozaman sanga tayor example home block xuddi shunay yozilgan

  const MessageListState({this.status = MessageList.loading,
    this.islast = false,
    this.messages = const [],
    this.errorMessage = "",
    this.nextPageUrl = ""
  });

  MessageListState copyWith({
    MessageList? status,
    List<Data>? products,
    bool? islast,
    String? errorMessage,
    String? nextPageUrl,
  }) {
    return MessageListState(
      status: status ?? this.status,
      messages: products ?? this.messages,
      islast: islast ?? this.islast,
      errorMessage: errorMessage ?? this.errorMessage,
      nextPageUrl: nextPageUrl,
    );
  }
  @override
  List<Object?> get props => [status, messages, islast, errorMessage,nextPageUrl];
}
