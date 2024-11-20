part of 'get_filter_product_bloc.dart';


abstract class GetFilterProductEvent extends Equatable {
  final int category_id;
  final int city_id;

  const GetFilterProductEvent({required this.category_id,required this.city_id});

  @override
  List<Object> get props => [];
}

class FilterProductGetEvent extends GetFilterProductEvent {
  FilterProductGetEvent({required super.category_id, required super.city_id});
}

class ReloadGetFilterProductEvent extends GetFilterProductEvent {
  ReloadGetFilterProductEvent({required super.category_id, required super.city_id});
}
