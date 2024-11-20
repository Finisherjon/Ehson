part of 'get_filter_product_bloc.dart';

enum FilterProduct { loading, success, error }

class GetFilterProductState extends Equatable {
  final FilterProduct status;
  final List<Data> products;
  final bool islast;
  final String errorMessage;
  final String? nextPageUrl;

  const GetFilterProductState(
      {this.status = FilterProduct.loading,
        this.islast = false,
        this.products = const [],
        this.errorMessage = "",
        this.nextPageUrl = ""});

  GetFilterProductState copyWith({
    FilterProduct? status,
    List<Data>? products,
    bool? islast,
    String? errorMessage,
    String? nextPageUrl,
  }) {
    return GetFilterProductState(
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
