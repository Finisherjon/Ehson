part of 'home_bloc.dart';

abstract class ProductEvent extends Equatable {
  final String date;
  const ProductEvent({required this.date});

  @override
  List<Object> get props => [];
}

class GetProductEvent extends ProductEvent{
  GetProductEvent({required super.date});
}
class ReloadProductEvent extends ProductEvent{
  ReloadProductEvent({required super.date});
}