part of 'add_product_bloc.dart';

@immutable
sealed class AddProductState {}

final class AddProductInitial extends AddProductState {}

final class AddProductLoading extends AddProductState {}
final class AddProductSuccess extends AddProductState {
  CategoryModel categoryModel;
  AddProductSuccess({required this.categoryModel});
}
final class AddProductError extends AddProductState {}