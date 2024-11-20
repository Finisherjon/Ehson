part of 'get_one_product_bloc.dart';

@immutable
sealed class GetOneProductEvent {}

class GetOneProductLoadingData extends GetOneProductEvent{
  final int product_id;
  GetOneProductLoadingData(this.product_id);
}
