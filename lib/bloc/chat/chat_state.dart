part of 'chat_bloc.dart';

enum ChatProduct { loading, success, error }

class ChatState extends Equatable {
  final ChatProduct status;
  final List<Data> products;
  final bool islast;
  final String errorMessage;
  final String? nextPageUrl;

  const ChatState(
      {this.status = ChatProduct.loading,
      this.islast = false,
      this.products = const [],
      this.errorMessage = "",
      this.nextPageUrl = ""});

  ChatState copyWith({
    ChatProduct? status,
    List<Data>? products,
    bool? islast,
    String? errorMessage,
    String? nextPageUrl,
  }) {
    return ChatState(
      status: status ?? this.status,
      products: products ?? this.products,
      islast: islast ?? this.islast,
      errorMessage: errorMessage ?? this.errorMessage,
      nextPageUrl: nextPageUrl,
    );
  }

  @override
  List<Object?> get props =>
      [status, products, islast, errorMessage, nextPageUrl];
}
