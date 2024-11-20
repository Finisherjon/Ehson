part of 'filter_product_bloc.dart';

@immutable
sealed class FilterProductEvent {}

class FilterProductLoadingData extends FilterProductEvent {}
