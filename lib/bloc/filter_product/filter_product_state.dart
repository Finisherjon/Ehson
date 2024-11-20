part of 'filter_product_bloc.dart';

@immutable
sealed class FilterProductState {}

final class FilterProductInitial extends FilterProductState {}

final class FilterProductLoading extends FilterProductState {}

final class FilterProductSuccess extends FilterProductState {
  CategoryModel categoryModel;

  FilterProductSuccess({required this.categoryModel});
}

final class FilterProductError extends FilterProductState {}