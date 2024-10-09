part of 'search_product_bloc.dart';

enum SearchProduct { loading, success, error }

class SearchProductState extends Equatable {
  final SearchProduct status;
  final List<Data> products;
  final bool islast;
  final String errorMessage;
  final String? nextPageUrl;

  const SearchProductState(
      {this.status = SearchProduct.loading,
      this.islast = false,
      this.products = const [],
      this.errorMessage = "",
      this.nextPageUrl = ""});

  SearchProductState copyWith({
    SearchProduct? status,
    List<Data>? products,
    bool? islast,
    String? errorMessage,
    String? nextPageUrl,
  }) {
    return SearchProductState(
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
