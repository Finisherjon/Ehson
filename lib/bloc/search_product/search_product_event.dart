part of 'search_product_bloc.dart';

abstract class SearchProductEvent extends Equatable {
  final String text;

  const SearchProductEvent({required this.text});

  @override
  List<Object> get props => [];
}

class GetSearchProductEvent extends SearchProductEvent {
  GetSearchProductEvent({required super.text});
}

class ReloadSearchProductEvent extends SearchProductEvent {
  ReloadSearchProductEvent({required super.text});
}

