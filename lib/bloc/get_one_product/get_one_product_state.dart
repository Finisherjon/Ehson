part of 'get_one_product_bloc.dart';

@immutable
sealed class GetOneProductState {}

final class GetOneProductInitial extends GetOneProductState {}

final class GetOneProductLoading extends GetOneProductState {}
final class GetOneProductSuccess extends GetOneProductState {
  OneProductModel oneProductModel;
  GetOneProductSuccess({required this.oneProductModel});
}
final class GetOneProductError extends GetOneProductState {}