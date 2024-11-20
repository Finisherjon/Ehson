part of 'get_one_help_bloc.dart';

@immutable
sealed class GetOneHelpEvent {}

class GetOneHelpLoadingDate extends GetOneHelpEvent {
  final int help_id;

  GetOneHelpLoadingDate(this.help_id);
}
