part of 'get_one_help_bloc.dart';

@immutable
sealed class GetOneHelpState {}

final class GetOneHelpInitial extends GetOneHelpState {}

final class GetOneHelpLoading extends GetOneHelpState {}

final class GetOneHelpSuccess extends GetOneHelpState {
  OneHelpModel oneHelpModel;

  GetOneHelpSuccess({required this.oneHelpModel});
}

final class GetOneHelpError extends GetOneHelpState {}
