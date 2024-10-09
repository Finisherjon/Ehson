part of 'get_like_bloc.dart';

enum GetLike { loading, success, error }


class GetLikeState extends Equatable {
  final GetLike status;
  final List<Data> products;
  final bool islast;
  final String errorMessage;
  final String? nextPageUrl;

  const GetLikeState(
      {this.status = GetLike.loading,
        this.islast = false,
        this.products = const [],
        this.errorMessage = "",
        this.nextPageUrl = ""
      });

  GetLikeState copyWith({
    GetLike? status,
    List<Data>? products,
    bool? islast,
    String? errorMessage,
    String? nextPageUrl,
  }) {
    return GetLikeState(
      status: status ?? this.status,
      products: products ?? this.products,
      islast: islast ?? this.islast,
      errorMessage: errorMessage ?? this.errorMessage,
      nextPageUrl: nextPageUrl,
    );
  }

  @override
  List<Object?> get props => [status, products, islast, errorMessage,nextPageUrl];
}